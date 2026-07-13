#!/bin/bash
set -e

OS=$(uname -s)
echo "🛠️ Starting Lean Bootstrap on $OS..."

# 1. Install Homebrew if missing
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Activate brew for this session — path differs by OS
if [[ "$OS" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# 2. Install core dependencies
echo "Installing dependencies (Stow, uv, FZF, Zoxide)..."
if [[ "$OS" == "Darwin" ]]; then
    brew install stow uv fzf zoxide gettext bat
else
    # stow via apt on Ubuntu; brew for the rest
    sudo apt-get install -y stow xclip 2>/dev/null || brew install stow
    brew install uv fzf zoxide bat
fi

# 3. macOS only: fix Zsh directory permissions
# Prevents "permission denied" errors seen in completions on macOS
if [[ "$OS" == "Darwin" ]]; then
    echo "Applying Zsh permission fixes..."
    chmod -R 755 /usr/local/share/zsh 2>/dev/null || true
    if [ -d "/opt/homebrew/share/zsh" ]; then
        sudo chmod -R 755 /opt/homebrew/share/zsh
    fi
fi

# 4. Clear stale completion cache
echo "Cleaning stale completion cache..."
rm -f ~/.zcompdump*

# 5. Orchestrate links with GNU Stow
echo "Linking dotfiles with GNU Stow..."
cd ~/dev/dotfiles
stow -t ~ zsh vim git tmux

# 6. Generate skills.json from template ($HOME differs across macOS /Users/ and Linux /home/)
echo "Writing ~/.gemini/config/skills.json..."
mkdir -p ~/.gemini/config
envsubst '${HOME}' < ~/dev/dotfiles/templates/skills.json.tmpl \
  > ~/.gemini/config/skills.json

echo "✅ System ready. Run 'source ~/.zshrc' to start."