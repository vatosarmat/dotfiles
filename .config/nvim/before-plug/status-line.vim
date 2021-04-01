set statusline=%!StatusLine()

let s:short = ['coc-explorer']

function! StatusLine() abort
  let statusLine = '%<'
  let bufnr = winbufnr(g:statusline_winid)
  let buftype = getbufvar(bufnr, '&buftype')
  let filetype = getbufvar(bufnr, '&filetype')
  let long = index(s:short, filetype) == -1
  if long
    let statusLine .= "%f"
    let statusLine .= "\ %y"
    if empty(buftype)
      let gitHead = FugitiveHead()
      if !empty(gitHead)
        let gitDir = fnamemodify(FugitiveGitDir(), ':h:t')
        let statusLine .= ' [ '.gitDir.'/'.gitHead.']'
      else
        let statusLine .= ' Not git'
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
