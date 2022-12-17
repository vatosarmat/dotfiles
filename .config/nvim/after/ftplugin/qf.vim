function! s:Context() abort
  let w = bufwinid(0)
  let ll = getloclist(w, #{context: 0})
  let context = get(ll, 'context', '')
  if type(context) == v:t_dict
    let b:loclist_context = ll.context
  end
endfunctio

call s:Context()

if get(get(b:,'loclist_context', #{}), 'type', -1) == 'symbol_list'
  set nonumber
end
