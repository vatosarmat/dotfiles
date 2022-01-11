let s:Paragraph_opers = #{
  \ forward: #{
    \ move_offset: 1,
    \ search_dirflag: '',
    \ lines_offset: 0,
    \ to_mfend: 'G',
    \ fold_mstart: function('foldclosed'),
    \ fold_mend: function('foldclosedend'),
    \ is_pos_beyond_mfend: { x -> x > line('$') },
    \ mnextnonblank: function('nextnonblank'),
    \ mfend: {  -> line('$') },
  \ },
  \ backward: #{
    \ move_offset: -1,
    \ search_dirflag: 'b',
    \ lines_offset: -1,
    \ to_mfend: 'gg',
    \ fold_mstart: function('foldclosedend'),
    \ fold_mend: function('foldclosed'),
    \ is_pos_beyond_mfend: { x -> x < 1 },
    \ mnextnonblank: function('prevnonblank'),
    \ mfend: {  -> 1 },
  \ }
  \}

function! s:to_parend_or_mfend(op, lnum) abort
  while 1
    let blank_lnum = search('^\s*$', a:op['search_dirflag'].'Wn')
    if blank_lnum == 0
      "No parend, mfend
      execute 'normal!' a:op.to_mfend
      return
    endif

    let fend = a:op.fold_mend(blank_lnum)
    if fend == -1
      "This lnum is actually blank, go to its mprevious line which should be parend
      call cursor(blank_lnum-a:op.move_offset, 0)
      return
    else
      let pos = fend + a:op.move_offset
      if a:op.is_pos_beyond_mfend(pos)
        execute 'normal!' a:op.to_mfend
        return
      else
        if getline(pos) !~ '\S'
          "This fold is parend, stop
          call cursor(fend, 0)
          return
        else
          "Go after this fold and repeat
          call cursor(pos, 0)
        endif
      endif
    endif
  endwhile
endfunction

function! s:to_parbeg_or_mfend(op, lnum) abort
  let lnum = a:op.mnextnonblank(a:lnum)
  if lnum == 0
    "No parbeg, mfend
    execute 'normal!' a:op.to_mfend
  else
    call cursor(lnum, 0)
  endif
endfunction

function! s:is_blank_and_mnext(op, lnum) abort
  let fend = a:op.fold_mend(a:lnum)
  if fend == -1
    let is_blank = getline(a:lnum) !~ '\S'
    let mnext = a:lnum + a:op.move_offset
  else
    "Fold is always assumed to be non blank
    let is_blank = 0
    let mnext = fend + a:op.move_offset
  endif

  return [is_blank, mnext]
endfunction

function! s:is_parend_or_blank_and_mnext(op, lnum) abort
  "handle folds in a proper way!
  "Here coulbe be 2 usual lines, or 2 folds, or 1 fold and 1 usual line
  "Can do nothing with lnum itself - only after fold-checking
  "
  "Also cannot infer second line without 'unfolding' lnum first
  "But how to 'unfold'? mnext
  let [blank1, mnext1] = s:is_blank_and_mnext(a:op, a:lnum)
  let [blank2, _] = s:is_blank_and_mnext(a:op, mnext1)

  return [blank1 || blank2, mnext1]
endfunction

function! s:is_mfend(op, lnum) abort
  let mfend = a:op.mfend()
  return a:lnum == mfend || a:op.fold_mend(a:lnum) == mfend
endfunction

function! s:to_fold_first_line(op, lnum) abort
  let fb = foldclosed(a:lnum)
  if fb != -1
    call cursor(fb, 0)
  endif
endfunction

function! motion#Paragraph(dir)abort
  "m - motion, direction dependent
  "Line means line or a group of folded lines
  "Def: blank line - line with only spaces
  "Def: mnext - next if forward, previous if backward
  "Def: mafter - after if forward, before if backward
  "Def: mfirst, mlast, mprevious, mbefore, mstart, mend - similar
  "Def: parbeg - non-blank line with blank mprevious line
  "Def: parend - non-blank line with blank mnext line
  "Def: parmid - non-balnk line with non-blank mnext line
  "Thus, parbeg could be either parmid, or parend('isolated' single line between blank lines)
  "Def: mfend - last file line if forward, first file line if backward

  "Where motion should move:
  "If mfend, return
  "If parend or blank, to parbeg or mfend
  "if parmid, to parend or mfend

  "If motion ends in fold, it should go to its first line

  let op = s:Paragraph_opers[a:dir]
  let lnum = line('.')

  if !s:is_mfend(op, lnum)
    let [parend_or_blank, mnext] = s:is_parend_or_blank_and_mnext(op, lnum)
    if parend_or_blank
      call s:to_parbeg_or_mfend(op, mnext)
    else
      call s:to_parend_or_mfend(op, mnext)
    endif
    let lnum = mnext
  endif

  call s:to_fold_first_line(op, lnum)
  normal! _
  call uopts#pzz()
endfunction
