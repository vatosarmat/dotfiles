let s:ft_ext = #{
  \ sh: ['sh', 'bash', 'bashrc'],
  \ vim: ['vim'],
  \ lua: ['lua'],
  \ json: ['json'],
  \ jsonc: ['json'],
  \ markdown: ['md'],
  \ python: ['py'],
  \ typescriptreact: ['tsx'],
  \ typescript: ['ts'],
  \ javascript: ['js'],
  \ text: ['txt'],
  \ yaml: ['yml', 'yaml'],
  \ rust: ['rs'],
  \ toml: ['toml'],
  \ go: ['go'],
  \ c: ['c'],
  \ cpp: ['cpp'],
  \ html: ['html']
  \ }

function! IsFtUnordinary(ft, ext) abort
  return index(get(s:ft_ext, a:ft, []), a:ext) == -1
endfunction

function! StatusLineFile() abort
  return "%f "
    \."%{StatusFileType()}"
    \."%{%StatusIsDebugSession()%}"
    \."%{%StatusShortmap()%}"
    \."%{%StatusRootDir()%}"
    \."%{%StatusLSP()%}"
    \." %<%3*%{StatusTreesitter()}%*"
    \."%="
    \." %m"
    \."%r"
    \." %L | %l %c%V%  %P"
endfunction

function! StatusLineFugitiveFile() abort
  return "%f "
    \."%{StatusFileType()}"
    \."%{%StatusLSP()%}"
    \." %<%3*%{StatusTreesitter()}%*"
    \."%="
    \." %m"
    \."%r"
    \." %L | %l %c%V%  %P"
endfunction

function! StatusLineNofile() abort
  return "%<"
    \."%f"
    \."%{StatusFileType()}"
    \."%="
    \." %m"
    \."%r"
    \." %L | %l %c%V%  %P"
endfunction

function! StatusLineQf() abort
  return "%<"
    \."%{%StatusQfTitle()%}"
    \."%="
    \." %m"
    \."%r"
    \." %L | %l %c%V%  %P"
endfunction

function! StatusLineExplorer() abort
  return "%<"
    \."%<%Y"
    \."%="
    \." %P"
endfunction

function! StatusQfTitle() abort
  let ret = ''
  if getwininfo(win_getid())[0].loclist
    let ret = 'LOC: '
    if exists('w:quickfix_title')
      let ret .= '%2*'.w:quickfix_title.'%*'
    endif
    let ret .= ' %<'. bufname(winbufnr(getloclist(0, #{filewinid: 0}).filewinid))
  else
    let ret = 'QF'
  endif
  return ret
endfunction

function! StatusTreesitter() abort
  " let w = winwidth(0)
  " if w < 100 | return '' | endif
  " return nvim_treesitter#statusline(#{separator: '->', indicator_size: w/2})
  return ''
endfunction

function! StatusShortmap() abort
  let content = ''
  let urt = getregtype('"')
  if urt ==# 'v'
    let content .= ' '
  elseif urt ==# 'V'
    let content .= ' '
  endif
  if g:ustate.yank_clipboard == 1
    let content .= ' '
  endif
  if content != ''
    let content = '%3*'.content.'%*'
  endif
  if type(get(b:,'shortmap',0)) == v:t_list
    if content != ''
      let content .= '|'
    endif
    let content .= '%2* %*'.b:shortmap[0]
  endif
  return content == '' ? '' : '['.content.']'
endfunction

function! StatusIsDebugSession() abort
  if luaeval('require"dap".session() ~= nil')
    return '%8* %*'
  endif
  return ''
endfunction

function! StatusLSP() abort
  if winwidth(0) < 70 | return '' | endif
  let str = luaeval('service.lsp.status_line()')
  if str == ''
    let str = 'No LSP'
  endif
  return '['.str.']'
endfunction

function! StatusFileType() abort
  return IsFtUnordinary(&filetype, expand("%:e")) && winwidth(0) >= 90 ? '['.&filetype.'] ' : ''
endfunction

function! StatusRootDir() abort
  if winwidth(0) < 90 | return '' | endif

  let root = fnamemodify(getcwd(), ':t')
  let gitStatus = get(b:, 'gitsigns_status_dict', '')
  if empty(gitStatus)
    return '['.root.'/No GIT] '
  else
    if gitStatus.head == 'master' || gitStatus.head == 'main'
      let head = ''
    else
      let head = '/'.gitStatus.head
    endif
    let changes = (get(gitStatus, 'added', 0) ? ' %5*落%*'.gitStatus.added : '')
      \.(get(gitStatus, 'changed', 0) ? ' %6*ﱴ %*'.gitStatus.changed : '')
      \.(get(gitStatus, 'removed', 0) ? ' %7* %*'.gitStatus.removed : '')
    return  '[%4* %*'.root.head.(empty(changes) ? '' : ' |'.changes ).'] '
  endif
endfunction

function! s:SetStatusLine(file) abort
  if empty(&buftype)
    if a:file =~ "fugitive:///"
      setl statusline=%!StatusLineFugitiveFile()
    else
      setl statusline=%!StatusLineFile()
    endif
  else
    if &filetype == 'coc-explorer'
      setl statusline=%!StatusLineExplorer()
    elseif &filetype == 'qf'
      setl statusline=%!StatusLineQf()
    else
      setl statusline=%!StatusLineNofile()
    endif
  endif
endfunction

command! SetStatusLine silent call<sid>SetStatusLine(bufnr())

augroup StatusLine
  autocmd!
  " autocmd BufEnter,BufNewFile,BufReadPost,ShellCmdPost,BufWritePost * call SetStatusLine()
  autocmd FileType * call s:SetStatusLine('<abuf>')
  autocmd FileChangedShellPost * call s:SetStatusLine('<abuf>')
augroup end

"Sometimes FileType is missing
nnoremap <leader>zz <cmd>let &ft=&ft<cr>


