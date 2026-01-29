call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
" Declare the list of plugins.

" Core
Plug 'tpope/vim-sensible'
Plug 'christoomey/vim-tmux-navigator'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" UI
Plug 'mhinz/vim-startify'
Plug 'vim-airline/vim-airline'
Plug 'dracula/vim'

" File tree
Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'

" Editing
Plug 'preservim/nerdcommenter'
Plug 'matze/vim-move'
Plug 'ntpeters/vim-better-whitespace'
Plug 'preservim/vim-indent-guides'
Plug 'tpope/vim-surround'
Plug 'ap/vim-css-color'

" Search
Plug 'mileszs/ack.vim'
Plug 'ctrlpvim/ctrlp.vim'

" Markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown']}
" CSV
Plug 'chrisbra/csv.vim', { 'for': 'csv' }
" LaTeX
Plug 'lervag/vimtex', { 'for': 'tex' }

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

filetype plugin indent on   " allow auto-indenting depending on file type
" ====================
" General Settings
" ====================
set nocompatible            " disable compatibility to old-time vi
set encoding=utf-8
set number                  " add line numbers
set cursorline              " highlight current cursorline
set showmatch               " show matching bracket
set wildmode=longest,list   " get bash-like tab completions in command mode
" open new split panes to right and below
set splitbelow
set splitright
set clipboard=unnamedplus   " using system clipboard
set mouse=av                " middle-click paste with
set ttyfast                 " Speed up scrolling in Vim
set cc=80                   " set an 80 column border for good coding style

" Searching
set ignorecase              " case insensitive search
set smartcase               " case sensitive search if search contain upper
set hlsearch                " highlight search
set incsearch               " incremental search

" Indentation
set expandtab               " converts tabs to white space
set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set shiftwidth=0            " width for autoindents, auto match tabstop
set autoindent              " indent a new line the same amount as the line just typed

" Backup
if !isdirectory($HOME . "/.cache/vim")
    call mkdir($HOME . "/.cache/vim", "p")
endif
set backup
set backupdir=~/.cache/vim " Directory to store backup files.


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


" =================
" Keymapping
" =================

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

" =============
" COC
" ============
set updatetime=300
set signcolumn=yes

let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-json',
  \ 'coc-pyright',
  \ 'coc-clangd',
  \ ]

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent><nowait> [g <Plug>(coc-diagnostic-prev)
nmap <silent><nowait> ]g <Plug>(coc-diagnostic-next)


" GoTo code navigation
nmap <silent><nowait> gd <Plug>(coc-definition)
nmap <silent><nowait> gy <Plug>(coc-type-definition)
nmap <silent><nowait> gi <Plug>(coc-implementation)
nmap <silent><nowait> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
