let s:docFavsFile = stdpath('data').'/site/doc/favs.txt'
let s:funcDeclPattern = '^\k\+(.*).*$'
let s:sectionHeadPattern = '\v^[[:keyword:][:blank:]]+\~$'

function! docfavs#Init()
  let oldPos = [line('.'), col('.')]
  let areaStart = search('\C\*functions\*')
  let areaStart = search('\v\C^USAGE\s+RESULT\s+DESCRIPTION[[:blank:]~]+$')
  let areaEnd = search('^\k\+(.*)\s\+\*\w\+()\*\s*$')
  call cursor(oldPos)
  let b:helpEvalFuncstionsArea = [areaStart, areaEnd]

  nnoremap <buffer> s <cmd>call <SID>FavFunction()<cr>
endfunction

function! s:ParseFavFunctionsContent(favFunctionsContent, favedFunctionDecl0) abort
  let favFunctionsBySections = #{}
  let currentSection = ''
  for line in a:favFunctionsContent
    if line =~ s:sectionHeadPattern
      let currentSection = line[:-2]
      let favFunctionsBySections[currentSection] = []
    else
      if currentSection == ''
        echoerr 'No section for function '.line
        call interrupt()
      endif
      if line =~ s:funcDeclPattern
        if line == a:favedFunctionDecl0
          echon printf('''%s'' is already faved in section ', matchstr(line, '^\k\+(.*)'))
          echohl helpHeader
          echon currentSection
          echohl None
          return [1, #{}]
        endif
        call add(favFunctionsBySections[currentSection], [line])
      else
        call add(favFunctionsBySections[currentSection][-1], line)
      endif
    endif
  endfor

  return [0, favFunctionsBySections]
endfunction

function! s:UnparseFavFunctionsContent(favFunctionsBySections) abort
  "Unparse back into flat line list, keep sections sorted, declarations in
  "them are already sorted
  let favFunctionsContent = []
  let sections = sort(keys(a:favFunctionsBySections))
  for section in sections
    call add(favFunctionsContent, section.'~')
    let favFunctionsContent = favFunctionsContent + flatten(a:favFunctionsBySections[section])
  endfor
  return favFunctionsContent
endfunction

function! s:PromptForSection(favFunctionsBySections) abort
  let sectionsList = keys(a:favFunctionsBySections)

  function! CompleteSection(a,cl,cp) closure
    return filter(sectionsList, {section -> section =~ a:a.'.*'})
  endfunction

  let section = ''
  while 1
    let section = input(#{
      \ prompt: 'Section... ',
      \ completion: 'customlist,CompleteSection'
      \ })

    if has_key(a:favFunctionsBySections, section)
      break
    else
      let ans = ['', 'yes', 'no'][inputlist([printf(' Add new section ''%s''?', section), '1 - yes', '2 - no'])]
      if ans == 'yes'
        let a:favFunctionsBySections[section] = []
        break
      endif
    endif
  endwhile
  return section
endfunction

function! s:FavFunction() abort
  "We are supposed to be in eval.txt
  let ln = line('.')
  "Ensure we are in functions list area
  if ln > b:helpEvalFuncstionsArea[1] || ln < b:helpEvalFuncstionsArea[0]
    echom "Not in function list"
    return
  endif

  let lc = getline('.')
  "Ensure the line starts with function decl
  if lc !~ s:funcDeclPattern
    echom "Not a function decl"
    return
  endif

  "Search for the next function decl to determine current func decl lines
  let nln = search(s:funcDeclPattern)
  let favedFuncDecl = getline(ln,nln-1)

  "Extract and parsecurrent favs content
  let docFavsContent = readfile(s:docFavsFile)
  let favFunctionsIdx = index(docFavsContent, '*fav-functions*')
  let favFunctionsBefore = docFavsContent[:favFunctionsIdx]
  let favFunctionsContent = docFavsContent[favFunctionsIdx+1:]
  let [alreadyFaved, favFunctionsBySections] = s:ParseFavFunctionsContent(favFunctionsContent, favedFuncDecl[0])
  if alreadyFaved
    return
  endif
  "Ask user for section
  let section = s:PromptForSection(favFunctionsBySections)
  let favFunctionsBySections[section] = sort(add(favFunctionsBySections[section], favedFuncDecl),
    \ {a, b -> a[0] > b[0]})
  let favFunctionsNewContent = s:UnparseFavFunctionsContent(favFunctionsBySections)

  if !writefile(favFunctionsBefore + favFunctionsNewContent, s:docFavsFile)
    echom ' '.matchstr(lc, '^\k\+(.*)').' faved!'
  endif
endfunction
