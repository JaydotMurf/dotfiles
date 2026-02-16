# 1. POWERLEVEL10K INSTANT PROMPT
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. ZINIT BOOTSTRAP
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# 3. COMPLETION INITIALIZATION (Critical: Load before Plugins)
autoload -Uz compinit
compinit -u

# 4. LOAD PLUGINS
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::docker
zinit snippet OMZP::kubectl

# Replay completions now that plugins are added
zinit cdreplay -q

# 5. CORE SYSTEM SETTINGS
export EDITOR='code --wait'
export VISUAL='code --wait'
HISTSIZE=10000
SAVEHIST=10000
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_ignore_space

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -G $realpath'

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# 6. STARTER ALIASES
alias ..="cd .."
alias ls="ls -G"
alias ll="ls -alhG"
alias dot="cd ~/dotfiles"
alias sz="source ~/.zshrc && echo 'Zsh config reloaded!'"
alias k=kubectl

# 7. EXTERNAL TOOLS
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(zoxide init zsh)"
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# 8. MODULAR LOADER (Fixed wildcard crash)
if [ -d "$HOME/.zsh_modules" ]; then
  # (N) prevents "no matches found" errors
  for module in "$HOME/.zsh_modules"/*.zsh(N); do
    source "$module"
  done
fi

# 9. FINALIZE THEME
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh