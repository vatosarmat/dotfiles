set hidden
set autoread
set noundofile
set nobackup nowritebackup
set noswapfile

set scrolloff=3

set mouse=a

set virtualedit=block

"set clipboard+=unnamedplus

set expandtab tabstop=2 softtabstop=2 shiftwidth=2 nosmarttab
let g:vim_indent_cont=shiftwidth()

set splitbelow splitright
set keywordprg=:vert\ Man

set number
set relativenumber

set ignorecase
set smartcase
set nowrapscan
set noincsearch

set tgc
"set noshowmode

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldtext=FoldText()
set nofoldenable

set statusline=%!StatusLine()
" set wildmode=longest,list,full

let mapleader = " "
nnoremap <Space> <Nop>

let g:is_bash = 1

set diffopt+=vertical,context:10000

let g:dfShortLinerList = ['coc-explorer']

function! StatusLine() abort
  let statusLine = '%<'
  let bufnr = winbufnr(g:statusline_winid)
  let buftype = getbufvar(bufnr, '&buftype')
  let filetype = getbufvar(bufnr, '&filetype')
  let long = index(g:dfShortLinerList, filetype) == -1
  if long
    let statusLine .= "%f"
    let statusLine .= "\ %y"
    if empty(buftype)
      let gitHead = FugitiveHead()
      if !empty(gitHead)
        let gitDir = fnamemodify(FugitiveGitDir(), ':h:t')
        let statusLine .= ' [ '.gitDir.'/'.gitHead.']'
      else
        let statusLine .= '\ Not\ git'
      endif
      let statusLine .= ' '.coc#status()
    endif
  else
    let statusLine .= "%Y"
  endif
  let statusLine .= "%="
  let statusLine .= "%m"
  let statusLine .= "%r"
  if long
    let statusLine .= "\ %-20.(%L\ |\ %l,%c%V%)"
  endif
  let statusLine .= "\ %P"
  return statusLine
endfunction

function! FoldText() abort
  let firstLine = getline(v:foldstart)
  let spaces = firstLine[0:match(firstLine, '\S')-1]
  let text = spaces.'...'.string(v:foldend-v:foldstart+1).' '.trim(getline(v:foldend))
  let postSpaces = repeat(' ',&columns - len(text))
  return text.postSpaces
endfunction

" function! FoldJoin() abort
"   let
"   let text = string(v:foldend - v:foldstart).' LINES:'
"   for i in range(v:foldstart, v:foldend)
"     let text .= ' '.trim(getline(i))

"     if len(text) > &columns
"       break
"     endif
"   endfor
"   return text
" endfunction

" function! s:GetSpaces(foldLevel)
"   if &expandtab == 1
"     " Indenting with spaces
"     let str = repeat(" ", a:foldLevel / (&shiftwidth + 1) - 1)
"     return str
"   elseif &expandtab == 0
"     " Indenting with tabs
"     return repeat(" ", indent(v:foldstart) - (indent(v:foldstart) / &shiftwidth))
"   endif
" endfunction

" function! MyFoldText()
"   let startLineText = getline(v:foldstart)
"   let endLineText = trim(getline(v:foldend))
"   let indentation = s:GetSpaces(foldlevel("."))
"   let spaces = repeat(" ", 200)

"   let str = indentation . startLineText . "..." . endLineText . spaces

"   return str
" endfunction

" function! MyFoldTextSimple()
"   return getline(v:foldstart)
" endfunction

