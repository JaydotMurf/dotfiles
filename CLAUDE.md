# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Stow creates symlinks from each subdirectory into `~`, so `stow zsh` symlinks `zsh/.zshrc` → `~/.zshrc`, etc. The repo lives at `~/dev/dotfiles`.

## Key Commands

```bash
# Full bootstrap (apt packages on Linux, Homebrew, deps, stow, templates). Safe to re-run.
bash zsh/install.sh

# Restow after pulling changes (run from ~/dev/dotfiles). Always --no-folding.
stow --no-folding -R -t ~ zsh vim git tmux
stow -D -t ~ zsh   # unstow (remove symlinks)

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
| `zsh/`    | `~`       | `.zshrc`, `.p10k.zsh`, `install.sh`, `.local/bin/{tmux-sessionizer,agent-pane,agent-pane-state}` |
| `git/`    | `~`       | `.gitconfig`, `.gitconfig-openclaw` |
| `vim/`    | `~`       | `.vimrc` |
| `tmux/`   | `~`       | `.tmux.conf` |
| `templates/` | not stowed | `skills.json.tmpl` — rendered by `install.sh` via `envsubst` to `~/.gemini/config/skills.json` (Antigravity skills registry; needs an absolute path, so it cannot be stowed) |
| `brew/`   | not stowed | `Brewfile` — macOS package manifest |
| `docs/`   | not stowed | `cheatsheet.md` and troubleshooting notes |

## Architecture Notes

**Zsh plugin manager**: Zinit (not Oh-My-Zsh). Plugins are loaded in `.zshrc` in a specific order: Powerlevel10k instant prompt must come first, then `compinit`, then plugins, then `cdreplay -q` to replay completions.

**Machine-local overrides**: `.zshrc` has a modular loader that sources `~/.zsh_modules/*.zsh`. Any machine-specific config (env vars, secrets, work-specific aliases) goes there rather than in the tracked `.zshrc`.

**This repo is public, and `~/.zshrc` is a symlink into it.** Tool installers (SDKMAN, vendor CLIs) append PATH lines — and sometimes tokens — straight to the tracked file. Before any commit, check `git diff zsh/.zshrc` for installer-added lines and move them to `~/.zsh_modules/<tool>.zsh`. Never commit a hardcoded `/Users/...` or `/home/...` path, a token, or an employer-specific alias.

**Stow is always run with `--no-folding`.** Folding made `~/.local/bin` a symlink to `zsh/.local/bin`, so `uv tool`, `pipx`, and vendor installers wrote binaries into the repo. `install.sh` un-folds machines stowed the old way (moving untracked files out to the real `~/.local/bin`), and `.gitignore` allowlists only the scripts this repo owns under `zsh/.local/bin/` — a new script there needs a matching `!` line.

**Git identity switching**: Default identity is personal (`Jerraill D. Murphy <80340739+JaydotMurf@users.noreply.github.com>`). The work identity lives in `~/.gitconfig-work` — machine-local and untracked, like `~/.zsh_modules` — and is loaded automatically via `includeIf "gitdir:~/dev/work/"`. The OpenClaw identity (`jerraill.openclaw@gmail.com`) loads via `includeIf "gitdir:~/dev/personal/openclaw/"`. No manual switching needed. Personal-by-default is deliberate: side-project repos must never be authored under the work identity (clean-room separation). On a new machine, recreate `~/.gitconfig-work` by hand with the work `[user]` block; it is intentionally not in this repo.

**Machine-local git overrides**: `.gitconfig` also includes `~/.gitconfig-local` (untracked; git skips it silently where absent). Use it for per-machine transport quirks. Current use: on machines where agent shells can't sign with the passphrase-protected SSH key, add

```ini
[url "https://github.com/JaydotMurf/"]
	insteadOf = git@github.com:JaydotMurf/
```

so personal-account remotes authenticate via the gh credential helper (requires `gh auth login`). Scoped to `JaydotMurf/` on purpose — work and OpenClaw-account remotes must keep their own transport/identity.

**Git credential helper**: `.gitconfig` calls `gh auth git-credential` through a small shell function that probes `/opt/homebrew/bin`, `/home/linuxbrew/.linuxbrew/bin`, and `/usr/bin` before falling back to `PATH`. Do not run `gh auth setup-git` — it rewrites the tracked file with an absolute path that only works on the machine it ran on.

**Cross-platform**: `install.sh` branches on `uname -s` for Darwin vs Linux and bootstraps a bare Ubuntu install. On Linux, apt provides the system layer (Homebrew build prerequisites, `zsh`, `stow`, `tmux`, full `vim`, `gettext-base`, `wl-clipboard`/`xclip`, `gnupg`, `pass`) and the script sets zsh as the login shell; the CLI tools (`uv`, `fzf`, `zoxide`, `bat`, `ripgrep`, `glow`, `gh`) come from Linuxbrew so versions match the Macs. Zsh permission fixes are macOS-only. In `.zshrc`, anything OS- or tool-dependent is guarded (`[[ -x ... ]]` / `command -v`) so a machine missing a tool still gets a clean shell; `ls` color flags branch on `$OSTYPE` because GNU `ls -G` means "hide group", not color.

Before linking, `install.sh` backs up any real file that would block a link to `<file>.pre-dotfiles.<timestamp>` and replaces hand-made absolute symlinks (stow refuses to adopt those and aborts).

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
2. Run `stow --no-folding -t ~ newapp` from `~/dev/dotfiles`.
3. Add the new stow target to the `PACKAGES` array in `install.sh` so it's included in future bootstraps.
4. If the file needs an absolute path (`$HOME` differs between macOS and Linux), do not stow it — add a `templates/<file>.tmpl` and an `envsubst` step in `install.sh` instead.
