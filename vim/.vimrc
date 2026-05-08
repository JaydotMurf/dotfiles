" --- General Settings ---
set nocompatible            " Disable compatibility with old vi
set number                  " Show line numbers
set relativenumber          " Help with jumping lines (optional, remove if distracting)
set showcmd                 " Show command in bottom bar
set cursorline              " Highlight the current line
set showmatch               " Highlight matching brackets
set mouse=a                 " Enable mouse support for scrolling/resizing

" --- UI & Colors ---
syntax on                   " Enable syntax highlighting
filetype plugin indent on   " Enable filetype detection and indentation
set background=dark         " Adjust for dark terminal backgrounds
colorscheme industry        " A standard high-contrast scheme; 'desert' is another good option

" --- Search Settings ---
set hlsearch                " Highlight search results
set incsearch               " Search as you type
set ignorecase              " Ignore case when searching
set smartcase               " Override ignorecase if search contains uppercase

" --- Indentation & Tabs (Optimized for JSON/Plist) ---
set expandtab               " Use spaces instead of tabs
set shiftwidth=2            " 2 spaces for indentation
set tabstop=2               " 2 spaces for tabs
set softtabstop=2           " Fine-tune backspace behavior with tabs
set autoindent              " Copy indent from current line to next
set smartindent             " Insert extra level of indent in some cases

" --- File Specific Tweaks ---
" Treat .plist files as XML for better syntax highlighting
autocmd BufNewFile,BufRead *.plist set filetype=xml
" Auto-format JSON if you have python3 installed (press \j to format)
map <leader>j :%!python3 -m json.tool<CR>

" --- Performance & Backup ---
set nobackup                " Do not create backup files
set nowritebackup
set noswapfile              " Prevent creation of .swp files
set encoding=utf-8          " Standardize encoding
