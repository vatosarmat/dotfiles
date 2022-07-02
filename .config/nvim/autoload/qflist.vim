function! qflist#Step(next, loc = 0) abort
  if a:next
    let edge = 'LAST'
    if a:loc
      let after = 'lafter'
      let next = 'lnext'
    else
      let after = 'cafter'
      let next = 'cnext'
    endif
  else
    let edge = 'FIRST'
    if a:loc
      let after = 'lbefore'
      let next = 'lprev'
    else
      let after = 'cbefore'
      let next = 'cprev'
    endif
  endif
  try
    "This 'after' may actually be before...
    execute after
  catch
    try
      execute next
    catch /E553/
      call utils#Print('WarningMsg', [edge, 'LspDiagnosticsSignInformation'], ' item')
    catch /E42/
      call utils#Print('WarningMsg', 'No list for ', [after, 'LspDiagnosticsSignInformation'])
    catch /E776/
      call utils#Print('WarningMsg', 'No loclist available')
    endtry
  endtry
  if g:UOPTS.nz
    if a:loc
      call win_gotoid(getloclist(0, #{winid: 0 }).winid) | normal! zz
    else
      call win_gotoid(g:ustate.qf_window) | normal! zz
    endif
    wincmd p
    normal! zz
  endif
endfunction

function! qflist#RemoveCurrentItem() abort
  if &filetype != 'qf'
    return
  endif

  let qf_info = getqflist(#{items: 0, idx: 0, context: 0})
  let prev_pos = getpos('.')
  " echom qf_info
  if type(qf_info.context) == v:t_dict
    let context = extend(qf_info.context, #{ change_list: [] })
  else
    let context = #{ change_list: [] }
  endif
  " echom context

  if mode() == 'V'
    let start_idx = line('v')
    let end_idx = line('.')
    if start_idx > end_idx
      let [start_idx, end_idx] = [end_idx, start_idx]
    else
      let prev_pos[1] -= (end_idx - start_idx)
    endif
  else
    let start_idx = line('.')
    let end_idx = start_idx + v:count1 - 1
  endif

  let new_change = #{
    \ items: remove(qf_info.items, start_idx - 1, end_idx - 1),
    \ start_idx: start_idx,
    \ end_idx: end_idx}

  let context.change_list = add(context.change_list, new_change)

  let list_cursor = qf_info.idx
  if start_idx <= list_cursor
    "Keep list cursor on the some entry
    let removed_before_cursor = (min([end_idx, list_cursor]) - start_idx)
    let list_cursor -= removed_before_cursor
  endif

  call setqflist([],  'r', #{items: qf_info.items, idx: list_cursor, context: context})
  "Clear visual
  call feedkeys("\<ESC>")
  call setpos('.', prev_pos)
endfunction

function! qflist#Restore() abort
  if &filetype != 'qf'
    return
  endif

  let qf_info = getqflist(#{items: 0, idx: 0, context: 0})
  let prev_pos = getpos('.')
  let context = qf_info.context
  if empty(context) || !has_key(context, 'change_list') || len(context.change_list) < 1
    call utils#Print('WarningMsg', 'No removed items to restore')
    return
  endif

  let last_change = remove(context.change_list, -1)
  call extend(qf_info.items, last_change.items, last_change.start_idx - 1 )

  call setqflist([],  'r', #{items: qf_info.items, idx: qf_info.idx, context: context})
  call setpos('.', prev_pos)
endfunction
