# Jerraill's Dotfiles

Personal development environment for macOS and Ubuntu, managed with
[GNU Stow](https://www.gnu.org/software/stow/). One repo, cloned to
`~/dev/dotfiles` on every machine.

## Tech stack

- **Shell:** Zsh with [Zinit](https://github.com/zdharma-continuum/zinit) and [Powerlevel10k](https://github.com/romkatv/powerlevel10k).
- **Terminal:** tmux (prefix `C-a`, TPM plugins, Tokyo Night status bar).
- **CLI:** `fzf`, `zoxide`, `ripgrep`, `bat`, `glow`, `gh`, `uv` — installed via Homebrew on macOS and Linuxbrew on Ubuntu, so versions match everywhere.
- **Editor:** Vim (minimal `.vimrc`), VS Code as `$EDITOR`.

## Bootstrap a new machine

The script needs only `sudo`, network access, and this repo. It is safe to re-run.

```bash
# Ubuntu only: git is not installed on a fresh system
sudo apt update && sudo apt install -y git

git clone https://github.com/JaydotMurf/dotfiles.git ~/dev/dotfiles
bash ~/dev/dotfiles/zsh/install.sh
```

What it does:

1. **Ubuntu:** installs system packages with apt — Homebrew's build prerequisites, `zsh`, `stow`, `tmux`, full `vim`, `gettext-base`, `wl-clipboard`/`xclip`, `gnupg`, `pass`.
2. Installs Homebrew (Linuxbrew on Ubuntu) if missing, then the core CLI tools.
3. **Ubuntu:** makes zsh the login shell. **macOS:** fixes zsh completion directory permissions.
4. Backs up any real file that would block a link to `<file>.pre-dotfiles.<timestamp>` — nothing is deleted.
5. Links everything with `stow --no-folding`.
6. Installs Claude Code if no `claude` is present — the Homebrew cask on macOS, the official native installer on Ubuntu.
7. Generates `~/.gemini/config/skills.json` from `templates/`.

Then, by hand, per machine:

- Open a new terminal (on Ubuntu, log out and back in so the login shell change applies).
- `gh auth login` — git uses `gh` as its HTTPS credential helper.
- `claude` — sign in to Claude Code on first run.
- Install a [Nerd Font](https://www.nerdfonts.com/) and select it in the terminal.
- Create the machine-local files below as needed.

zinit plugins and tmux plugins (TPM) install themselves on first launch.

### After pulling changes

```bash
cd ~/dev/dotfiles && stow --no-folding -R -t ~ zsh vim git tmux
```

Re-running `install.sh` does the same and also regenerates templated files.

## What gets linked

| Package | Source | Target |
|---------|--------|--------|
| `zsh` | `zsh/.zshrc` | `~/.zshrc` |
| `zsh` | `zsh/.p10k.zsh` | `~/.p10k.zsh` |
| `zsh` | `zsh/install.sh` | `~/install.sh` |
| `zsh` | `zsh/.local/bin/{tmux-sessionizer,agent-pane,agent-pane-state}` | `~/.local/bin/…` |
| `vim` | `vim/.vimrc` | `~/.vimrc` |
| `git` | `git/.gitconfig` | `~/.gitconfig` |
| `git` | `git/.gitconfig-openclaw` | `~/.gitconfig-openclaw` |
| `tmux` | `tmux/.tmux.conf` | `~/.tmux.conf` |

Not stowed:

| Path | Purpose |
|------|---------|
| `templates/skills.json.tmpl` | Rendered with `envsubst` to `~/.gemini/config/skills.json` — it needs an absolute path, and `$HOME` differs between macOS and Linux. |
| `brew/Brewfile` | macOS package manifest: `brew bundle --file=brew/Brewfile`. |
| `docs/cheatsheet.md` | Key-binding and alias reference; view with the `cheat` shell function. |

### Why `--no-folding`

Without it, Stow links a whole directory when the target does not exist yet —
`~/.local/bin` becomes a symlink into this repo, and every tool that installs a
binary there (`uv tool`, `pipx`, vendor CLIs) writes into a public repository.
`--no-folding` links file by file and keeps those directories real.
`install.sh` also repairs machines that were stowed the old way.

## Machine-local files (never tracked)

This repo is public. Anything specific to one machine, one employer, or one
account lives outside it:

| File | Use |
|------|-----|
| `~/.zsh_modules/*.zsh` | Env vars, API tokens, machine- or work-specific aliases and PATH entries. Sourced automatically by `.zshrc`. |
| `~/.gitconfig-work` | Work git identity, loaded only under `~/dev/work/`. |
| `~/.gitconfig-local` | Per-machine git transport overrides. |

Tool installers like to append PATH lines and tokens to `~/.zshrc`, which is a
symlink into this repo. When one does, move what it added into
`~/.zsh_modules/<tool>.zsh` before committing.

## Platform notes

| | macOS | Ubuntu |
|---|---|---|
| Homebrew prefix | `/opt/homebrew` | `/home/linuxbrew/.linuxbrew` |
| System packages | Homebrew | apt (see `install.sh`) |
| App manifest | `brew/Brewfile` | — |
| Clipboard | built in | `wl-clipboard` (Wayland), `xclip` (X11) |
| Login shell | zsh by default | set by `install.sh` |
