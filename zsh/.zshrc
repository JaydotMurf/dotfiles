# ------------------------------------------------------------------------------
# 1. POWERLEVEL10K INSTANT PROMPT
# ------------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------------------------------------------------------
# 2. ZINIT BOOTSTRAP (Plugin Manager)
# ------------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Load Essential Plugins
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab

# Load Oh-My-Zsh Snippets (Optimized)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::docker
zinit snippet OMZP::kubectl

# ------------------------------------------------------------------------------
# 3. CORE SYSTEM SETTINGS
# ------------------------------------------------------------------------------
export EDITOR='code --wait'
export VISUAL='code --wait'

HISTSIZE=10000
SAVEHIST=10000
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_ignore_space

# Completion Styles
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -G $realpath'

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ------------------------------------------------------------------------------
# 4. STARTER ALIASES (The Engineering Toolkit)
# ------------------------------------------------------------------------------

# Navigation & Essentials
alias ..="cd .."
alias ...="cd ../.."
alias ls="ls -G" # Colored logs for macOS
alias ll="ls -alhG"
alias dot="cd ~/dotfiles"

# Configuration Management (High-Velocity)
alias zconf="code ~/dotfiles/zsh/.zshrc"
alias pconf="code ~/dotfiles/zsh/.p10k.zsh"
alias sz="source ~/.zshrc && echo 'Zsh config reloaded!'"

# AI & Dev Ops Workflow (MVP Approach)
alias venv="python3 -m venv .venv && source .venv/bin/activate"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias k=kubectl

# ------------------------------------------------------------------------------
# 5. EXTERNAL TOOL INITIALIZATION
# ------------------------------------------------------------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(zoxide init zsh)"
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# ------------------------------------------------------------------------------
# 6. MODULAR LOADER (For your AI Implementation Guides)
# ------------------------------------------------------------------------------
# This looks for any .zsh files in your module folder (managed by Stow)
if [ -d "$HOME/.zsh_modules" ]; then
  for module in "$HOME/.zsh_modules"/*.zsh; do
    source "$module"
  done
fi

# Finalize Theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh