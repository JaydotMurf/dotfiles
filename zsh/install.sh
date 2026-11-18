#!/bin/bash
# Bootstrap a machine from this repo. Safe to re-run.
#
#   bash ~/dev/dotfiles/zsh/install.sh
#
# Works on macOS and on a bare Ubuntu install: the only prerequisites are
# sudo, network access, and this repo cloned to ~/dev/dotfiles.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dev/dotfiles}"
OS=$(uname -s)
STAMP=$(date +%Y%m%d-%H%M%S)
PACKAGES=(zsh vim git tmux)

echo "🛠️ Starting Lean Bootstrap on $OS..."

if [[ ! -d "$DOTFILES/zsh" ]]; then
    echo "dotfiles repo not found at $DOTFILES — clone it there first." >&2
    exit 1
fi

# 1. Linux: system packages via apt.
#    Everything Homebrew needs to build, plus the things that should come from
#    the distro rather than brew (login shell, editor, clipboard, gpg).
if [[ "$OS" == "Linux" ]]; then
    if ! command -v apt-get &> /dev/null; then
        echo "This script only knows apt-based distros (Ubuntu/Debian)." >&2
        exit 1
    fi
    APT_PACKAGES=(
        build-essential procps curl file git   # Homebrew prerequisites
        zsh stow tmux
        vim                                    # full vim; stock vim-tiny lacks syntax/colorschemes
        gettext-base                           # envsubst, for the templates/ step
        wl-clipboard xclip                     # Wayland + X11 clipboard (tmux-yank, pass -c)
        gnupg pass
    )
    echo "Installing system packages (apt)..."
    sudo apt-get update
    sudo apt-get install -y "${APT_PACKAGES[@]}"
fi

# 2. Homebrew (Linuxbrew on Linux) — same CLI tool versions on every machine.
find_brew() {
    local b
    for b in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$b" ]]; then echo "$b"; return 0; fi
    done
    return 1
}
if ! BREW=$(find_brew); then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    BREW=$(find_brew)
fi
eval "$("$BREW" shellenv)"

# 3. Core CLI dependencies — everything .zshrc, .tmux.conf, and this script
#    call. The full macOS app set lives in brew/Brewfile; this is the minimum.
echo "Installing CLI dependencies (brew)..."
BREW_PACKAGES=(uv fzf zoxide bat ripgrep glow gh)
if [[ "$OS" == "Darwin" ]]; then
    BREW_PACKAGES+=(stow gettext tmux)
fi
brew install "${BREW_PACKAGES[@]}"

# 4. macOS only: fix Zsh directory permissions
#    Prevents "permission denied" errors seen in completions on macOS
if [[ "$OS" == "Darwin" ]]; then
    echo "Applying Zsh permission fixes..."
    chmod -R 755 /usr/local/share/zsh 2>/dev/null || true
    if [[ -d /opt/homebrew/share/zsh ]]; then
        sudo chmod -R 755 /opt/homebrew/share/zsh
    fi
fi

# 5. Linux only: make zsh the login shell (macOS already defaults to it)
if [[ "$OS" == "Linux" ]]; then
    ME=$(id -un)
    ZSH_PATH=$(command -v zsh)
    if [[ "$(getent passwd "$ME" | cut -d: -f7)" != "$ZSH_PATH" ]]; then
        echo "Setting login shell to $ZSH_PATH..."
        sudo chsh -s "$ZSH_PATH" "$ME" \
            || echo "⚠️  chsh failed — run: chsh -s $ZSH_PATH" >&2
    fi
fi

# 6. Clear stale completion cache
echo "Cleaning stale completion cache..."
rm -f ~/.zcompdump*

# 7. Link dotfiles with GNU Stow
echo "Linking dotfiles with GNU Stow..."
cd "$DOTFILES"

# 7a. Un-fold directories an earlier bootstrap symlinked wholesale into the
#     repo. A folded ~/.local/bin means every installer that drops a binary
#     there writes into this (public) repo. Anything git doesn't track is
#     moved out to the real directory; tracked files are re-linked below.
unfold() {   # $1 = path relative to both $HOME and the zsh package
    local link="$HOME/$1" src="$DOTFILES/zsh/$1" f rel
    [[ -L "$link" && "$link" -ef "$src" ]] || return 0
    echo "  un-folding ~/$1 (was a symlink into the repo)"
    rm "$link"
    mkdir -p "$link"
    while IFS= read -r f; do
        f="${f%/}"
        rel="${f#"zsh/$1/"}"
        mkdir -p "$(dirname "$link/$rel")"
        mv "$DOTFILES/$f" "$link/$rel"
        echo "    moved out of repo: $rel"
    done < <(git -C "$DOTFILES" ls-files --others --directory -- "zsh/$1")
}
unfold .local
unfold .local/bin
mkdir -p "$HOME/.local/bin"

# 7b. Clear whatever would block a link. Real files (e.g. a ~/.gitconfig or
#     ~/.zshrc created before the first bootstrap) are backed up, never
#     deleted. Hand-made absolute symlinks that already point at the repo file
#     are dropped so stow can recreate them as links it owns — stow refuses to
#     touch absolute symlinks and aborts the whole run otherwise.
for pkg in "${PACKAGES[@]}"; do
    while IFS= read -r -d '' src; do
        target="$HOME/${src#"$DOTFILES/$pkg/"}"
        if [[ -L "$target" && "$target" -ef "$src" && "$(readlink "$target")" == /* ]]; then
            echo "  replacing hand-made absolute symlink $target"
            rm "$target"
        elif [[ -e "$target" && ! -L "$target" && ! "$target" -ef "$src" ]]; then
            echo "  backing up $target -> $target.pre-dotfiles.$STAMP"
            mv "$target" "$target.pre-dotfiles.$STAMP"
        fi
    done < <(find "$DOTFILES/$pkg" -type f ! -name .DS_Store -print0)
done

# 7c. --no-folding links file-by-file, so ~/.local/bin and friends stay real
#     directories. -R (restow) makes re-runs prune links to deleted files.
stow --no-folding --ignore='\.DS_Store' -R -t "$HOME" "${PACKAGES[@]}"

# 8. Generate skills.json from template ($HOME differs across macOS /Users/ and Linux /home/)
echo "Writing ~/.gemini/config/skills.json..."
mkdir -p ~/.gemini/config
envsubst '${HOME}' < "$DOTFILES/templates/skills.json.tmpl" \
  > ~/.gemini/config/skills.json

echo "✅ System ready."
echo
echo "Next steps (manual, per machine):"
echo "  • Open a new terminal (Linux: log out and back in for the zsh login shell)."
echo "  • gh auth login                   — HTTPS GitHub auth for git"
echo "  • ~/.zsh_modules/*.zsh            — machine-local env vars, secrets, aliases"
echo "  • ~/.gitconfig-work, ~/.gitconfig-local — machine-local git identity/transport (see CLAUDE.md)"
echo "  • Install a Nerd Font and select it in the terminal (Powerlevel10k glyphs)."
