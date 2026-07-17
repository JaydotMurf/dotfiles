# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Stow creates symlinks from each subdirectory into `~`, so `stow zsh` symlinks `zsh/.zshrc` → `~/.zshrc`, etc. The repo lives at `~/dev/dotfiles`.

## Key Commands

```bash
# Full bootstrap (installs Homebrew, deps, and stows everything)
bash zsh/install.sh

# Stow individual config groups (run from ~/dev/dotfiles)
stow zsh
stow vim
stow git
stow -D zsh   # unstow (remove symlinks)

# Reload Zsh config after changes
source ~/.zshrc   # or: sz (alias)

# Dump currently installed Homebrew packages
brew bundle dump --force --file=brew/Brewfile

# Restore Homebrew packages from Brewfile
brew bundle --file=brew/Brewfile
```

## Repository Structure

| Directory | Stowed to | Contents |
|-----------|-----------|----------|
| `zsh/`    | `~`       | `.zshrc`, `.p10k.zsh`, `install.sh`, `.local/bin/tmux-sessionizer` |
| `git/`    | `~`       | `.gitconfig`, `.gitconfig-work`, `.gitconfig-openclaw` |
| `vim/`    | `~`       | `.vimrc` |
| `tmux/`   | `~`       | `.tmux.conf` |
| `gemini/`  | `~`       | `.gemini/config/skills.json` — Antigravity shared skills registry |
| `brew/`   | not stowed | `Brewfile` — package manifest |

## Architecture Notes

**Zsh plugin manager**: Zinit (not Oh-My-Zsh). Plugins are loaded in `.zshrc` in a specific order: Powerlevel10k instant prompt must come first, then `compinit`, then plugins, then `cdreplay -q` to replay completions.

**Machine-local overrides**: `.zshrc` has a modular loader that sources `~/.zsh_modules/*.zsh`. Any machine-specific config (env vars, secrets, work-specific aliases) goes there rather than in the tracked `.zshrc`.

**Git identity switching**: Default identity is personal (`Jerraill D. Murphy <80340739+JaydotMurf@users.noreply.github.com>`). The work identity lives in `~/.gitconfig-work` — machine-local and untracked, like `~/.zsh_modules` — and is loaded automatically via `includeIf "gitdir:~/dev/work/"`. The OpenClaw identity (`jerraill.openclaw@gmail.com`) loads via `includeIf "gitdir:~/dev/personal/openclaw/"`. No manual switching needed. Personal-by-default is deliberate: side-project repos must never be authored under the work identity (clean-room separation). On a new machine, recreate `~/.gitconfig-work` by hand with the work `[user]` block; it is intentionally not in this repo.

**Machine-local git overrides**: `.gitconfig` also includes `~/.gitconfig-local` (untracked; git skips it silently where absent). Use it for per-machine transport quirks. Current use: on machines where agent shells can't sign with the passphrase-protected SSH key, add

```ini
[url "https://github.com/JaydotMurf/"]
	insteadOf = git@github.com:JaydotMurf/
```

so personal-account remotes authenticate via the gh credential helper (requires `gh auth login`). Scoped to `JaydotMurf/` on purpose — work and OpenClaw-account remotes must keep their own transport/identity.

**Cross-platform**: `install.sh` branches on `uname -s` for Darwin vs Linux. On Linux, `stow` is installed via apt; `uv`, `fzf`, and `zoxide` come from Linuxbrew. Zsh permission fixes are macOS-only.

## Cheat Sheet

`docs/cheatsheet.md` covers tmux, zsh, git, and vim. Rendered in the terminal via the `cheat` function (defined in `.zshrc`, requires `glow`):

```bash
cheat          # full sheet
cheat tmux     # tmux section only
cheat git      # git section only
```

## Tmux

Prefix is `C-a`. Plugin manager is TPM — auto-bootstraps on first `tmux` launch (clones TPM, installs all plugins). Plugins: `tmux-sensible`, `vim-tmux-navigator`, `tmux-yank`, `tmux-resurrect`, `tmux-continuum`. Sessions auto-save every 10 min and restore on server restart. Status bar uses Tokyo Night palette.

**tmux-sessionizer** (`~/.local/bin/tmux-sessionizer`, stowed from `zsh/.local/bin/`) — fuzzy-finds `~/dev/**` project dirs via fzf and creates/switches tmux sessions. Bound to `C-a C-f` as a floating popup. Each project gets a session named after its directory basename.

Key bindings quick ref: `C-a -` / `C-a |` split panes, `C-a h/j/k/l` navigate panes, `C-h/j/k/l` navigate without prefix (vim-tmux-navigator), `C-a C-l` clear screen, `C-a r` reload config, `C-a Enter` enter copy mode.

```bash
# Install TPM plugins manually (after adding a new plugin to .tmux.conf)
~/.tmux/plugins/tpm/bin/install_plugins

# Reload config from outside tmux
tmux source ~/.tmux.conf
```

## Adding New Config

1. Create a new subdirectory matching the file structure relative to `~` (e.g., `newapp/.config/newapp/config`).
2. Run `stow newapp` from `~/dev/dotfiles`.
3. Add the new stow target to the `stow` line in `install.sh` so it's included in future bootstraps.
