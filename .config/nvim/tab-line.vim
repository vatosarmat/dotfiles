function! MyTabLabel(n) abort
  let buflist = tabpagebuflist(a:n)
  for bid in buflist
    let btp = getbufvar(bid,'&buftype')
    if btp == ""
      let bname = bufname(bid)
      if filereadable(bname)
        let gitDir = FugitiveExtractGitDir(bname)
        if gitDir != ""
          return fnamemodify(gitDir, ':h:t')
        endif
      endif
    endif
  endfor
  let winnr = tabpagewinnr(a:n)
  return bufname(buflist[winnr - 1])
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
