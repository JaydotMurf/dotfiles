# Jerraill's Dotfiles

## Overview

This repository contains my personal development environment configuration, optimized for **AI Engineering** and **Systems Engineering**.

### Tech Stack

- **Shell:** Zsh with [Zinit](https://github.com/zdharma-continuum/zinit) for ultra-fast plugin management.
- **Theme:** [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (Lean/Pure configuration).
- **Productivity:** `fzf` for fuzzy finding and `zoxide` for smart navigation.
- **Management:** [GNU Stow](https://www.gnu.org/software/stow/) for symlink orchestration.

## Installation

1. Clone this repo to `~/dev/dotfiles`.
2. Run the bootstrap script — it installs Homebrew, GNU Stow, and core dependencies, then wires up all symlinks:
   ```bash
   cd ~/dev/dotfiles && bash zsh/install.sh
   ```
3. To re-distribute after pulling changes (if symlinks are already in place):
   ```bash
   cd ~/dev/dotfiles && stow -t ~ zsh vim git
   ```

### What gets symlinked

| Package | Source | Target |
|---------|--------|--------|
| `zsh` | `zsh/.zshrc` | `~/.zshrc` |
| `zsh` | `zsh/.p10k.zsh` | `~/.p10k.zsh` |
| `zsh` | `zsh/install.sh` | `~/install.sh` |
| `vim` | `vim/.vimrc` | `~/.vimrc` |
| `git` | `git/.gitconfig` | `~/.gitconfig` |
| `git` | `git/.gitconfig-openclaw` | `~/.gitconfig-openclaw` |
