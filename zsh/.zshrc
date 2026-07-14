export PATH="$HOME/.local/bin:$PATH"
# Create by JayDotMurf

# POWERLEVEL10K
## 1. POWERLEVEL10K INSTANT PROMPT
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## 2. ZINIT BOOTSTRAP
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

## 3. COMPLETION INITIALIZATION (Critical: Load before Plugins)
autoload -Uz compinit
compinit -u

## 4. LOAD PLUGINS
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab

## Snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::docker
zinit snippet OMZP::kubectl

## Replay completions now that plugins are added
zinit cdreplay -q

## 5. CORE SYSTEM SETTINGS
export EDITOR='code --wait'
export VISUAL='code --wait'
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_ignore_space

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -la $realpath'

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

## 6. STARTER ALIASES
alias ..="cd .."
alias ls="ls -G"
alias ll="ls -alhG"
alias dot="cd ~/dev/dotfiles"
alias sz="source ~/.zshrc && echo 'Zsh config reloaded!'"
alias k=kubectl

## 7. EXTERNAL TOOLS
# ── Platform-aware Homebrew ──────────────────────────────
if [[ "$(uname -s)" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ "$(uname -s)" == "Linux" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
eval "$(zoxide init zsh)"
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# ── bat: a better cat (syntax highlighting + markdown rendering) ──
# Homebrew/Linuxbrew name the binary `bat`; Debian/Ubuntu apt names it `batcat`.
# Normalize to `bat`, then route `cat` through it. bat prints plain — no colors,
# decorations, or paging — when stdout isn't a TTY, so pipes, redirects, and
# scripts are unaffected. Use `\cat` or `command cat` to reach raw cat.
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
  alias bat="batcat"
fi
if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
  alias cat="bat"
  # Colorized, syntax-highlighted man pages
  export MANPAGER="sh -c 'col -bx | bat --language man --plain'"
  export MANROFFOPT="-c"
fi

## 8. MODULAR LOADER (Fixed wildcard crash)
if [ -d "$HOME/.zsh_modules" ]; then
  # (N) prevents "no matches found" errors
  for module in "$HOME/.zsh_modules"/*.zsh(N); do
    source "$module"
  done
fi

## 9. FINALIZE THEME
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Cheat sheet
cheat() {
  local file="$HOME/dev/dotfiles/docs/cheatsheet.md"
  if [[ -z "$1" ]]; then
    glow "$file"
  else
    awk -v s="$1" 'BEGIN{IGNORECASE=1} /^## /{if(f)exit; if($0~s)f=1} f' "$file" | glow -
  fi
}

# Aliases

# Claude aliases
# claudeyolo (bypass-permissions) removed 2026-07-14 per POA&M-06: bypass mode
# skips the ask-tier permission rules (PR/release/publish boundaries); only the
# push hook survives. Widen the allowlist via /fewer-permission-prompts instead.
alias claudeplan="claude --permission-mode plan"

# claude.ai cloud connectors load only where they're used: ~/dev/portfolio
# (Ideabrowser, Notion, keywords-everywhere) and ~/dev/chief-of-staff (Open
# Brain, Gmail, Calendar). Everywhere else they're suppressed to keep
# sessions lean and lanes separated. Per-connector selection isn't possible
# on this plan, so it's all-or-nothing per directory.
# NOTE: keywords-everywhere is currently absent from the claude.ai connector
# list (not just disabled) — it must be re-added account-side at
# claude.ai -> Settings -> Connectors before it loads here again.
claude() {
  case "$PWD/" in
    "$HOME/dev/portfolio/"*|"$HOME/dev/chief-of-staff/"*)
      command claude "$@" ;;
    *)
      ENABLE_CLAUDEAI_MCP_SERVERS=false command claude "$@" ;;
  esac
}

# Git aliases
alias gi="git init"
alias gs="git status -sbu"
alias gco="git checkout"
alias gcob="git checkout -b"
alias gp="git push"
alias gm="git merge"
alias ga="git add ."
alias gcm="git commit -m"
alias gpl="git pull"
alias gst="git stash"
alias gstl="git stash list"
alias glg='git log --graph --oneline --decorate --all'
# Army AVD
alias avd='pkill -f chrome 2>/dev/null; sleep 2; google-chrome https://rdweb.wvd.azure.us/arm/webclient/index.html &'

# Fabric aliases
alias fabric='fabric-ai'
alias fwisdom='fabric --pattern extract_wisdom'
alias fsum='fabric --pattern summarize'
alias fask='fabric --pattern ask_a_question'

# pass: fuzzy pick + copy to clipboard
pget() {
  local entry
  entry=$(find "$HOME/.password-store" -name '*.gpg' \
    | sed "s|$HOME/.password-store/||;s|\.gpg$||" \
    | fzf --prompt='pass > ') \
  && pass -c "$entry"
}


# Added by Antigravity CLI installer
export PATH="/home/jerraill/.local/bin:$PATH"
