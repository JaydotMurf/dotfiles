# Cheat Sheet

> Key notation: `C-x` = hold Ctrl + press x. `prefix` = Ctrl+a (release), then the next key.

---

## tmux

### Prefix & Meta
| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix key (hold Ctrl, press a, release both) |
| `prefix r` | Reload tmux config in-place |

### Panes
| Key | Action |
|-----|--------|
| `prefix -` | Split horizontally (new pane below) |
| `prefix \|` | Split vertically (new pane right) |
| `prefix h/j/k/l` | Move focus between panes (vim-style) |
| `Ctrl+h/j/k/l` | Move focus between panes (no prefix needed) |
| `prefix H/J/K/L` | Resize pane (hold and repeat) |
| `prefix S` | Toggle sync to all panes in window (broadcast) |
| `prefix z` | Zoom pane to full screen / unzoom |
| `prefix x` | Kill current pane |

### Windows
| Key | Action |
|-----|--------|
| `prefix c` | New window (inherits current directory) |
| `prefix 1-9` | Jump to window by number |
| `prefix n / p` | Next / previous window |
| `prefix ,` | Rename current window |
| `prefix &` | Kill current window |

### Sessions
| Key | Action |
|-----|--------|
| `prefix $` | Rename current session |
| `prefix s` | Browse and switch sessions (tree view) |
| `prefix C-f` | Fuzzy-find project → create/switch session |
| `prefix d` | Detach from session (session keeps running) |

### Copy Mode
| Key | Action |
|-----|--------|
| `prefix Enter` | Enter copy mode |
| `v` | Start selection |
| `Ctrl+v` | Rectangle (column) selection |
| `y` | Yank selection → system clipboard, exit copy mode |
| `prefix ]` | Paste tmux buffer |
| `/` | Search forward in copy mode |
| `q` | Quit copy mode |

### Misc
| Key | Action |
|-----|--------|
| `prefix C-l` | Clear terminal screen |
| `prefix ?` | List all key bindings |

---

## zsh

### Navigation
| Alias | Expands to |
|-------|------------|
| `..` | `cd ..` |
| `dot` | `cd ~/dotfiles` |
| `z <dir>` | Jump to frecent directory (zoxide) |
| `sz` | `source ~/.zshrc` — reload shell config |

### Listing
| Alias | Expands to |
|-------|------------|
| `ls` | `ls -G` (colorized) |
| `ll` | `ls -alhG` (long, all, human-readable) |

### AI
| Alias | Expands to |
|-------|------------|
| `claudeyolo` | `claude --dangerously-skip-permissions` |

### History
| Key | Action |
|-----|--------|
| `Ctrl+p` | Search history backward |
| `Ctrl+n` | Search history forward |

### Modular config
Drop machine-local config (secrets, work aliases) in `~/.zsh_modules/*.zsh` — auto-sourced at shell start, not tracked in the repo.

---

## git

### Aliases
| Alias | Expands to |
|-------|------------|
| `gi` | `git init` |
| `gs` | `git status -sbu` |
| `ga` | `git add .` |
| `gcm "msg"` | `git commit -m "msg"` |
| `gco <branch>` | `git checkout <branch>` |
| `gcob <branch>` | `git checkout -b <branch>` |
| `gp` | `git push` |
| `gpl` | `git pull` |
| `gm <branch>` | `git merge <branch>` |
| `gst` | `git stash` |
| `gstl` | `git stash list` |
| `glg` | `git log --graph --oneline --decorate --all` |

### Identity switching
Git identity is automatic based on project directory:
- Default → personal identity (GitHub noreply)
- `~/dev/work/**` → work identity (from `~/.gitconfig-work`, machine-local, untracked)
- `~/dev/personal/openclaw/**` → personal identity (`jerraill.openclaw@gmail.com`)

No manual switching needed — driven by `includeIf` in `~/.gitconfig`.

---

## vim

### Search
| Key | Action |
|-----|--------|
| `/pattern` | Search forward |
| `n / N` | Next / previous match |
| `:noh` | Clear search highlight |

### Indentation
2 spaces, expandtab. Automatic for most filetypes.

### Custom mappings
| Key | Action |
|-----|--------|
| `\j` | Format current file as JSON (requires python3) |

### Notes
- `.plist` files are treated as XML automatically.
- No swap or backup files created.

---

## fzf

| Key | Action |
|-----|--------|
| `Ctrl+r` | Fuzzy search shell history |
| `Ctrl+t` | Fuzzy find file → paste path at cursor |
| `Alt+c` | Fuzzy cd into subdirectory |
| `Tab` (in zsh) | fzf-tab: fuzzy complete any tab target |

Files are found with ripgrep (`FZF_DEFAULT_COMMAND=rg`), so `.gitignore` entries are respected.

---

## SSH port forwarding

```bash
# Forward remote port to localhost
ssh -L <local_port>:localhost:<remote_port> user@host

# Forward in background (no interactive shell)
ssh -L 8080:localhost:8080 user@host -N -f

# Reach a Kubernetes pod web UI locally
kubectl port-forward pod/mypod 8080:8080
ssh -L 8080:localhost:8080 user@bastion
```

---

## pass (Unix password manager)

```bash
# Initial setup (once)
gpg --gen-key
pass init <gpg-key-id>

# Daily use
pass ls                          # list all entries
pass show email/gmail            # show password
pass -c email/gmail              # copy to clipboard (clears after 45s)
pass insert email/newsite        # add new entry
pass generate email/newsite 20   # generate 20-char password
pass edit email/gmail            # edit entry in $EDITOR
pget                             # fzf fuzzy picker → copy to clipboard
```

---

## fabric

```bash
# Pipe text to a pattern
cat notes.txt | fabric --pattern extract_wisdom
fabric --pattern summarize < article.txt

# YouTube transcript → insights
fabric -y "https://youtube.com/..." --pattern extract_wisdom

# List all patterns
fabric --list

# Shortcuts (defined in .zshrc)
cat file.txt | fwisdom    # extract_wisdom
echo "..." | fsum         # summarize
echo "question" | fask    # ask_a_question
```
