let s:docFavsFile = stdpath('data').'/site/doc/favs.txt'
let s:funcDeclPattern = '^\k\+(.*).*$'
let s:subsectionHeadPattern = '\v^[[:keyword:][:blank:]]+\~$'

"docFavsFile has functions section(no other sections currently) which is
"divided into subsections. Each subsection has one function per line
"By key press function declaration from help file is copied into docFavsFile
"Function declarations can be in eval.txt, api.txt, lua.txt, lsp.txt, maybe other places

function! docfavs#Init()
  nnoremap <buffer> , <cmd>call <SID>FavFunction()<cr>
endfunction


"And also check if lineToAdd was already added
"returns linesBySubsection dictionary
function! s:ParseFavFunctionsSection(lines, lineToAdd) abort
  "In subsection: one line - one function
  let linesBySubsections = #{}
  let currentSubsection = ''
  for line in a:lines
    if line =~ s:subsectionHeadPattern
      "Cut off new line and tilde
      let currentSubsection = line[:-2]
      let linesBySubsections[currentSubsection] = []
    elseif line =~ s:funcDeclPattern
      "If that's not a subsection, then it should be a function
      if currentSubsection == ''
        "Each function must have subsection
        echoerr 'No subsection for function '.line
        call interrupt()
      endif
      if line == a:lineToAdd
        echon printf('''%s'' is already faved in section ', matchstr(line, '^\k\+(.*)'))
        echohl helpHeader
        echon currentSubsection
        echohl None
        call interrupt()
      endif
      call add(linesBySubsections[currentSubsection], line)
    else
      echoerr 'Unexpected line: '.line
      call interrupt()
    endif
  endfor

  return linesBySubsections
endfunction

function! s:ToLinesList(linesBySubsections) abort
  "Keep sections sorted
  let favFunctionsLines = []
  let sections = sort(keys(a:linesBySubsections))
  for section in sections
    call add(favFunctionsLines, section.'~')
    call extend(favFunctionsLines, a:linesBySubsections[section])
  endfor
  return favFunctionsLines
endfunction

function! s:PromptForSubsection(favFunctionsBySections) abort
  let sectionsList = keys(a:favFunctionsBySections)

  function! DocfavsCompleteSection(a,cl,cp) closure
    return filter(sectionsList, {_, section -> section =~ a:a.'.*'})
  endfunction

  let section = ''
  echom sectionsList
  while 1
    let section = input(#{
      \ prompt: 'Section... ',
      \ completion: 'customlist,DocfavsCompleteSection'
      \ })

    if has_key(a:favFunctionsBySections, section)
      break
    elseif section =~ '\v^\u[[:keyword:][:blank:]]+$'
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
  let funcToAdd = getline('.')
  "Ensure the line starts with function decl
  if funcToAdd !~ s:funcDeclPattern
    echom "Not a function decl"
    return
  endif
  let funcToAdd = matchstr(funcToAdd, '^\k\+(.\{-\})')

  let docFavsFileLines = readfile(s:docFavsFile)
  let ids = index(docFavsFileLines, '*fav-functions*')
  let fileLinesBeforeFavFunctions = docFavsFileLines[:ids]
  let fileLinesFavFunctionsSection = docFavsFileLines[ids+1:]
  let favFunctionsBySections = s:ParseFavFunctionsSection(fileLinesFavFunctionsSection, funcToAdd)
  "Ask user for section
  let section = s:PromptForSubsection(favFunctionsBySections)
  "Keep section content sorted
  let favFunctionsBySections[section] = sort(add(favFunctionsBySections[section], funcToAdd),
    \ {a, b -> a[0] > b[0]})
  let favFunctionsNewContent = s:ToLinesList(favFunctionsBySections)

  if !writefile(fileLinesBeforeFavFunctions + favFunctionsNewContent, s:docFavsFile)
    echom ' '.matchstr(funcToAdd, '^\k\+(.*)').' faved!'
  endif
endfunction
