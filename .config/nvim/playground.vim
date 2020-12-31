function! MyCocListProviders() abort
  let allActions =  [ "rename",
        \ "onTypeEdit", "documentLink", "documentColor", "foldingRange",
        \ "format", "codeAction", "workspaceSymbols", "formatRange",
        \ "hover", "signature", "documentSymbol", "documentHighlight",
        \ "definition", "declaration", "typeDefinition", "reference",
        \ "implementation", "codeLens", "selectionRange" ]
        \ + []
  let supportedActions = []
  let unsupportedActions = []
  for act in allActions
    if(CocHasProvider(act))
      let lst = supportedActions
    else
      let lst = unsupportedActions
    endif
    call add(lst, act)
  endfor

  let leftPad = '    '
  echom "Has providers:"
  if(len(supportedActions) <= 0)
    echom leftPad.'None'
  else
    for act in supportedActions
      echom leftPad.act
    endfor
  endif

  echom leftPad
  echom "Missing providers:"
  if(len(unsupportedActions) <= 0)
    echom leftPad.'None'
  else
    for act in unsupportedActions
      echom leftPad.act
    endfor
  endif
endfunction

function FooCount()
  let users = ['vasya', 'petya', 'johny', 'petya']
  echom count()
endfunction

function FooWhile()
	let s:i = 1
	while i < 5
	  echom "while count is" i
	  let i += 1
  endwhile
endfunction

function FooFor()
  for i in range(1,4)
	  echom "for count is" i
  endfor
endfunction

function FooCountWords() range
  let lnum = a:firstline
  let n = 0
  while lnum <= a:lastline
    let n = n + len(split(getline(lnum)))
    let lnum = lnum + 1
  endwhile
  echo "found " . n . " words"
endfunction

function Foo()
  let Af = function('MyCocListProviders')
  call call(Af, [])
endfunction

"cnoreabbrev ff w \| source $MYVIMRC \|call Foo()

