# -------------------------
# Aliases for 'ls' commands
# -------------------------
# lists only directories (no files)
ld='eza -lD'

# lists only files (no directories)
lf='eza -lF --color=always | grep -v /'

# lists only hidden files (no directories)
lh='eza -dl .* --group-directories-first'

# lists everything with directories first
ll='eza -al --group-directories-first'

# lists only files sorted by size
ls='eza -alF --color=always --sort=size | grep -v /'

# lists everything sorted by time updated
lt='eza -al --sort=modified'

# -----------------------------------
# Aliases for system and file commands
# -----------------------------------
# Update the package list from repositories
alias update='sudo apt update -y'

# Upgrade all installed packages
alias upgrade='sudo apt upgrade -y'

# Count the number of files in the current directory and subdirectories
alias count='find . -type f | wc -l'

# View currently mounted drives and their mount points, filtered by /dev/
alias mnt="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort"

# Move files to trash instead of permanent deletion (safer file removal)
alias tcn='mv --force -t ~/.local/share/Trash'

# Copy files with a progress bar
alias cpv='rsync -ah --info=progress2'


# -------------------------
# Aliases for Git operations
# -------------------------
# General Git Aliases
alias g='git'                # Short for 'git'
alias ga='git add'           # Stage changes for commit
alias gc='git commit -m'     # Commit changes with a message
alias gs='git status'        # Check the current status of the repo
alias gb='git branch'        # List branches
alias gcheckout='   git checkout' # Switch branches
alias gm='git merge'         # Merge branches
alias gpull='git pull'       # Pull updates from the remote repo
alias gpush='git push'       # Push commits to the remote repo

# Git Log and Show Aliases
alias gl='git log --oneline --graph --decorate --all'  # Compact log view with graph
alias gd='git diff'                                   # Show file differences
alias gg='git grep'                                   # Search through repository files

# Git Stash Aliases
alias gstash='git stash'                              # Stash changes for later

# Git Remote Aliases
alias gremote='git remote'                            # Manage git remotes (add/remove)

# Git Interactive Rebase Alias
alias grebase='git rebase'                            # Interactive rebase

# Git Configuration Aliases
alias gconfig-name='git config --global user.name "Your Name"'   # Set global git username
alias gconfig-email='git config --global user.email "your.email@example.com"' # Set global git email

# Return to the top level of the current Git project
alias cg='cd `git rev-parse --show-toplevel`'


# --------------------------------
# Aliases for Python environments
# --------------------------------
# Create a Python virtual environment in the current directory
alias ve='python3 -m venv ./venv'

# Activate the Python virtual environment
alias va='source ./venv/bin/activate'


# --------------------------------
# Other utility aliases
# --------------------------------
# Search for a command in history using a keyword
alias gh='history|grep'

# Use Cheat.sh to quickly reference cheat sheets for commands
alias cct='function _cct() { curl cheat.sh/$1; }; _cct'
