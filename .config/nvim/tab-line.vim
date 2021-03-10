function! s:InferTabCurrentDir() abort
  let buflist = tabpagebuflist()
  let readableFiles = []

  "Collect files opened in the tab
  for bid in buflist
    let btp = getbufvar(bid,'&buftype')
    if btp == ""
      let bname = bufname(bid)
      if filereadable(bname)
        call add(readableFiles , bname)
      endif
    endif
  endfor

  "If no files opened, use present cwd
  if len(readableFiles) == 0
    return getcwd()
  endif

  "If any file is git-controlled, use its git root dir
  for f in readableFiles
    let gitDir = FugitiveExtractGitDir(bname)
    if gitDir != ""
      return fnamemodify(gitDir, ':h')
    endif
  endfor

  "Otherwise, if any buffer is a file, use its parent dir
  return fnamemodify(readableFiles[0], ':h')
endfunction

function! s:OnTabNewEntered() abort
  execute "tcd" s:InferTabCurrentDir()
endfunction

autocmd TabNewEntered * call s:OnTabNewEntered()

function! MyTabLabel(n) abort
  return fnamemodify(getcwd(-1, a:n), ':t')
endfunction

function! MyTabLine() abort
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999Xclose'
  endif

  return s
endfunction

set tabline=%!MyTabLine()
