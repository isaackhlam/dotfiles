call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
" Declare the list of plugins.

"""""""""""""""""""""""
" Basic plugin        "
"""""""""""""""""""""""
Plug 'tpope/vim-sensible'
Plug 'christoomey/vim-tmux-navigator'
" Git Integrate
Plug 'tpope/vim-fugitive'
" Git Diff status on left gutter
Plug 'airblade/vim-gitgutter'

"""""""""""""""""""""""""
" Beautify              "
"""""""""""""""""""""""""
" Start Screen
Plug 'mhinz/vim-startify'
Plug 'vim-airline/vim-airline'
" Theme
Plug 'dracula/vim'

"""""""""""""""""""""""""
" File Related          "
"""""""""""""""""""""""""
" File management
Plug 'scrooloose/nerdtree'
" File Icon
Plug 'ryanoasis/vim-devicons'

"""""""""""""""""""""""""
" Edit Related          "
"""""""""""""""""""""""""
" Comment
Plug 'preservim/nerdcommenter'
" Move line
Plug 'matze/vim-move'
" White Space
Plug 'ntpeters/vim-better-whitespace'
" See indent
Plug 'preservim/vim-indent-guides'
" Surround
Plug 'tpope/vim-surround'
" color code background
Plug 'ap/vim-css-color'

"""""""""""""""""""""""""
" Document Editing      "
"""""""""""""""""""""""""
" MD preview
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown']}
" CSV file
Plug 'chrisbra/csv.vim', { 'for': 'csv'}
" LaTeX
Plug 'lervag/vimtex', { 'for': 'tex' }


"""""""""""""""""""""""""
" Others                "
"""""""""""""""""""""""""
" Global Search
Plug 'mileszs/ack.vim'
" fuzzy search
Plug 'ctrlpvim/ctrlp.vim'
" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" List ends here. Plugins become visible to Vim after this call.
call plug#end()


"""""""""""""""""""""""""
" Theme Setting         "
"""""""""""""""""""""""""

" Airline
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1
let g:airline_theme='dracula'
let g:airline#extensions#whitespace#enabled=1

" color schemes
if (has("termguicolors"))
 set termguicolors
endif
syntax enable
colorscheme dracula


"""""""""""""""""""""""""
" Config                "
"""""""""""""""""""""""""
set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching bracket
set ignorecase              " case insensitive search
set smartcase               " case sensitive search if search contain upper
set hlsearch                " highlight search
set incsearch               " incremental search
set mouse=av                " middle-click paste with
set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=0            " width for autoindents, auto match tabstop
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions in command mode
set cc=80                   " set an 80 column border for good coding style
filetype plugin indent on   " allow auto-indenting depending on file type
set clipboard=unnamedplus   " using system clipboard
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set spell                   " enable spell check (may need to download language package)
" open new split panes to right and below
set splitright
set splitbelow
if !isdirectory($HOME . "/.cache/vim")
    call mkdir($HOME . "/.cache/vim", "p")
endif
set backup
set backupdir=~/.cache/vim " Directory to store backup files.


"""""""""""""""""""""""""
" Keymapping
"""""""""""""""""""""""""

" COC
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" NERD Tree
nnoremap <silent> <C-a> :exec 'NERDTreeToggle' <CR>
nmap  <Leader>r :NERDTreeRefreshRoot <CR>

" Buffer
nnoremap <Leader>[ :bprevious<CR>
nnoremap <Leader>] :bnext<CR>
nnoremap <Leader>1 :bfirst<CR>
nnoremap <Leader>2 :bfirst<CR>:bn<CR>
nnoremap <Leader>3 :bfirst<CR>:2bn<CR>
nnoremap <Leader>4 :bfirst<CR>:3bn<CR>
nnoremap <Leader>5 :bfirst<CR>:4bn<CR>
nnoremap <Leader>6 :bfirst<CR>:5bn<CR>
nnoremap <Leader>7 :bfirst<CR>:6bn<CR>
nnoremap <Leader>8 :bfirst<CR>:7bn<CR>
nnoremap <Leader>9 :blast<CR>
nnoremap <Leader>w :bd<CR>

" Comment
map <C-_> <Leader>c<space>

" Global Search in cwd
nnoremap <C-f> :Ack!<Space>

" Ctrl p
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
