#!/bin/bash
set -e

echo "🛠️ Starting Lean Bootstrap with Permission Fixes..."

# 1. Install Homebrew if missing
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Install core dependencies
echo "Installing dependencies (Stow, uv, FZF, Zoxide)..."
brew install stow uv fzf zoxide

# 3. FIX: Zsh Directory Permissions
# This prevents the "permission denied" errors seen in completions
echo "Applying Zsh permission fixes..."
chmod -R 755 /usr/local/share/zsh 2>/dev/null || true
if [ -d "/opt/homebrew/share/zsh" ]; then
    sudo chmod -R 755 /opt/homebrew/share/zsh
fi

# 4. FIX: Clear stale completion cache
# Removes the old dump file that might contain 'command not found' references
echo "Cleaning stale completion cache..."
rm -f ~/.zcompdump*

# 5. Orchestrate links with GNU Stow
echo "Linking dotfiles with GNU Stow..."
cd ~/dotfiles
stow zsh

echo "✅ System ready. Run 'source ~/.zshrc' to start."