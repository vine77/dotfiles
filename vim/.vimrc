" Apple's /usr/share/vim/vimrc sets skip_defaults_vim, and a user vimrc
" suppresses defaults.vim anyway — so pull it in explicitly. This is where
" `syntax on` actually lives, which is why vim was monochrome without it.
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

syntax enable
filetype plugin indent on

" iTerm2 advertises COLORTERM=truecolor; without these two escapes vim
" quantizes the theme down to the 256-color cube.
if has('termguicolors') && ($COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

silent! colorscheme monokai_machine

set number
set cursorline
set showcmd
set laststatus=2
set hlsearch incsearch ignorecase smartcase
set expandtab shiftwidth=2 softtabstop=2
set splitbelow splitright
set list listchars=tab:›\ ,trail:·,nbsp:␣
set scrolloff=4
set signcolumn=yes

" ~/.vim is a stow symlink into the dotfiles repo, so undo history lives
" outside it — otherwise every edit would litter the working tree.
let s:undodir = expand('~/.local/state/vim/undo')
if !isdirectory(s:undodir)
  call mkdir(s:undodir, 'p', 0700)
endif
let &undodir = s:undodir
set undofile

" defaults.vim turns the mouse on; uncomment to get plain terminal
" text selection back.
" set mouse=
