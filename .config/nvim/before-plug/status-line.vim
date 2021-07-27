let s:ft_ext = #{
  \ sh: ['sh', 'bash', 'bashrc'],
  \ vim: ['vim'],
  \ lua: ['lua'],
  \ json: ['json'],
  \ markdown: ['md'],
  \ python: ['py'],
  \ typescriptreact: ['tsx'],
  \ typescript: ['ts'],
  \ text: ['txt'],
  \ yaml: ['yml', 'yaml'],
  \ rust: ['rs'],
  \ toml: ['toml'],
  \ go: ['go']
  \ }

function! IsFtUnordinary(ft, ext) abort
  return index(get(s:ft_ext, a:ft, []), a:ext) == -1
endfunction

function! StatusLineFile() abort
  return "%<"
    \."%f"
    \."%{StatusFileType()}"
    \."%{StatusRootDir()}"
    \."%{%StatusLSP()%}"
    \."%="
    \." %m"
    \."%r"
    \." %L | %l, %c%V% , %P"
endfunction

function! StatusLineFugitiveFile() abort
  return "%<"
    \."%f"
    \."%{StatusFileType()}"
    \."%{%StatusLSP()%}"
    \."%="
    \." %m"
    \."%r"
    \." %L | %l, %c%V% , %P"
endfunction

function! StatusLineNofile() abort
  return "%<"
    \."%f"
    \."%{StatusFileType()}"
    \."%="
    \." %m"
    \."%r"
    \." %L | %l, %c%V% , %P"
endfunction

function! StatusLineExplorer() abort
  return "%<"
    \."%<%Y"
    \."%="
    \." %P"
endfunction


if $NO_COC
  function! StatusLSP() abort
    if winwidth(0) < 70 | return '' | endif
    let str = luaeval('lsp_utils.render_status_string()')
    if str == ''
      let str = 'No LSP'
    endif
    return '['.str.']'
  endfunction
else
  function! StatusLSP() abort
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
endif

function! StatusFileType() abort
  return IsFtUnordinary(&filetype, expand("%:e")) && winwidth(0) >= 90 ? ' ['.&filetype.'] ' : ''
endfunction

function! StatusRootDir() abort
  if winwidth(0) < 90 | return '' | endif

  let maybeRoot = FindRootDirectory()
  let root = fnamemodify(maybeRoot ? maybeRoot : getcwd(), ':t')
  let gitStatus = get(b:, 'gitsigns_status_dict', '')
  if empty(gitStatus)
    return ' ['.root.'/No GIT] '
  else
    let changes = (get(gitStatus, 'added', 0) ? '  '.gitStatus.added : '')
      \.(get(gitStatus, 'removed', 0) ? '  '.gitStatus.removed : '')
      \.(get(gitStatus, 'changed', 0) ? '  '.gitStatus.changed : '')
    return  ' [ '.root.'/'.gitStatus.head.(empty(changes) ? '' : ' |'.changes ).'] '
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
    else
      setl statusline=%!StatusLineNofile()
    endif
  endif
endfunction

augroup StatusLine
  autocmd!
  " autocmd BufEnter,BufNewFile,BufReadPost,ShellCmdPost,BufWritePost * call SetStatusLine()
  autocmd FileType * call s:SetStatusLine(bufname())
  autocmd FileChangedShellPost * call s:SetStatusLine(bufname())
augroup end

