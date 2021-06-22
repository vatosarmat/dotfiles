let s:ft_ext = #{
  \ sh: ['sh', 'bash', 'bashrc'],
  \ vim: ['vim'],
  \ lua: ['lua'],
  \ json: ['json'],
  \ markdown: ['md'],
  \ python: ['py'],
  \ typescriptreact: ['tsx'],
  \ typescript: ['ts'],
  \ text: ['txt']
  \ }

function! IsFtUnordinary(ft, ext) abort
  return index(get(s:ft_ext, a:ft, []), a:ext) == -1
endfunction

function! FileStatusLine() abort
  return "%<"
    \."%f"
    \."%{StatusFileType()}"
    \."%{StatusRootDir()}"
    \."%{StatusCoc()}"
    \."%="
    \." %m"
    \."%r"
    \." %L | %l, %c%V% , %P"
endfunction

function! NofileStatusLine() abort
  return "%<"
    \."%f"
    \."%{StatusFileType()}"
    \."%="
    \." %m"
    \."%r"
    \." %L | %l, %c%V% , %P"
endfunction

function! ExplorerStatusLine() abort
  return "%<"
    \."%<%Y"
    \."%="
    \." %P"
endfunction

function! StatusCoc() abort
  if winwidth(0) < 70 | return '' | endif

  const cs = coc#status()
  const cf = get(b:,'coc_current_function','')
  let items = []

  if !empty(cs)
    call add(items, cs)
  endif
  if !empty(cf)
    call add(items, cf)
  endif

  if empty(items)
    return ''
  endif

  return ' ['.join(items, ' | ').']'
endfunction

function! StatusFileType() abort
  return IsFtUnordinary(&filetype, expand("%:e")) && winwidth(0) >= 90 ? ' ['.&filetype.'] ' : ''
endfunction

function! StatusRootDir() abort
  if winwidth(0) < 90 | return '' | endif

  let maybeRoot = FindRootDirectory()
  let root = fnamemodify(maybeRoot ? maybeRoot : getcwd(), ':t')
  let gitStatus = get(b:, 'gitsigns_status_dict', '')
  if empty(gitStatus)
    return ' ['.root.'/NO GIT] '
  else
    let changes = (get(gitStatus, 'added', 0) ? '  '.gitStatus.added : '')
      \.(get(gitStatus, 'removed', 0) ? '  '.gitStatus.removed : '')
      \.(get(gitStatus, 'changed', 0) ? '  '.gitStatus.changed : '')
    return  ' [ '.root.'/'.gitStatus.head.(empty(changes) ? '' : ' |'.changes ).'] '
  endif
endfunction

function! SetStatusLine()
  if empty(&buftype)
    setl statusline=%!FileStatusLine()
  else
    if &filetype == 'coc-explorer'
      setl statusline=%!ExplorerStatusLine()
    else
      setl statusline=%!NofileStatusLine()
    endif
  endif
endfunction

augroup StatusLine
  autocmd!
  " autocmd BufEnter,BufNewFile,BufReadPost,ShellCmdPost,BufWritePost * call SetStatusLine()
  autocmd FileType * call SetStatusLine()
  autocmd FileChangedShellPost * call SetStatusLine()
augroup end

