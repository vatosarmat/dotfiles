set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldtext=FoldText()
set nofoldenable

function! FoldText() abort
  let firstLine = getline(v:foldstart)
  let spaces = firstLine[0:match(firstLine, '\S')-1]
  let text = spaces.' ...'.string(v:foldend-v:foldstart+1).' '.trim(getline(v:foldend))
  let postSpaces = repeat(' ',&columns - len(text))
  return text.postSpaces
endfunction
