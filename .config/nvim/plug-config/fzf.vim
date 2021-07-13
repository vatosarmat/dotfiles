" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
endfunction

"Default file picker
nnoremap <silent><C-p> :Files<cr>
nnoremap <silent><M-m> :Buffers<cr>
let g:fzf_action = {
  \'ctrl-q': function('s:build_quickfix_list'),
  \'ctrl-l': 'vsplit',
  \'ctrl-t': 'tab split',
  \'ctrl-x': 'split' }

"Navigate marks just like files
nnoremap <silent><leader>ml :call <sid>MarksLocal()<cr>
nnoremap <silent><leader>mm :call <sid>MarksGlobal()<cr>

"[Rip]grep shortcuts
"Simple, smart-case
nnoremap <leader>rs :Rg<space>
nnoremap <leader>rp :Rg <C-r>=utils#GetSearchPatternWithoutFlags()<cr>
"With file glob pattern
nnoremap <leader>ra :Rga ''<left>

"Handy abbrevs
cnoreabbrev ht h \| Helptags
cnoreabbrev bl BLines
cnoreabbrev li Lines
cnoreabbrev ma Maps
cnoreabbrev gf GFiles?
cnoreabbrev gc Commits
cnoreabbrev gb BCommits
cnoreabbrev hf h fzf-vim

"Find quesitions
cnoreabbrev rq Rga -F '???'

"Ripgrep taking command line args
let s:rga_shell_command = "rg --column --line-number --no-heading --color=always --smart-case"
command! -bang -nargs=* Rga
  \ call fzf#vim#grep(s:rga_shell_command." ".<q-args>, 1, fzf#vim#with_preview(), <bang>0)

"Implementations
function! s:MarksLocal() abort
  let list = s:GetLocalMarksList()
  let options = [
    \'--query', '^',
    \'--ansi',
    \'--preview-window', '+{2}/4',
    \"--prompt", "Local marks> ",
    \'--preview', printf("bat '%s' --color=always --style=numbers --pager=never --highlight-line {2}", bufname("%"))]
  return fzf#run(fzf#wrap('marks', #{ source: list, options: options, sink: function('s:MarkSink') }))
endfunction

function! s:MarksGlobal() abort
  let list = s:GetGlobalMarksList()
  let options = [
    \'--query', '^',
    \'--ansi',
    \'--preview-window', '+{4}/4',
    \"--prompt", "GlobalMarks> ",
    \"--delimiter=\ua0",
    \'--nth=1,3..',
    \'--with-nth=1,3..',
    \'--preview', "bat '{2}' --color=always --style=numbers --pager=never --highlight-line {4}"]
  return fzf#run(fzf#wrap('marks', #{ source: list, options: options, sink: function('s:MarkSink') }))
endfunction

function! s:MarkSink(line) abort
  execute "normal!" "'".a:line[0].'zz'
endfunction

function! s:GetLocalMarksList() abort
  let rawList = getmarklist("%")
  let outList = []
  for item in rawList
    let name = item.mark[-1:]
    if name =~ "^\\l$"
      let [_, lnum, _, _] = item.pos
      call add(outList, printf("%s%s %s%5d %s%s", g:utils#color8.red, name, g:utils#color8.cyan, lnum, g:utils#color_reset, getline(lnum)))
    endif
  endfor
  return outList
endfunction

function! s:GetGlobalMarksList() abort
  let truncFileLength = 40
  let root = getcwd()
  let rawList = getmarklist()
  let markItemsList = []
  let outList = []

  let maxFileLength = 0
  for item in rawList
    "If this is a hand-made mark
    let name = item.mark[-1:]
    if name =~ "^\\u$"
      "If it is under CWD
      let file = expand(item.file)
      if file =~ "^".root
        let [_, line, _, _] = item.pos
        let file = fnamemodify(file, ":.")

        if len(file) > maxFileLength
          let maxFileLength = len(file)
        endif

        call add(markItemsList, #{ name: name, file: file, line: line })
      endif
    endif
  endfor

  let truncFileLength = min([truncFileLength, maxFileLength])

  for item in markItemsList
    let fileTrunc = item.file
    if len(item.file) > truncFileLength
      let fileTrunc = '<'.item.file[-truncFileLength + 1:]
    endif

    let bnum = bufadd(item.file)
    call bufload(item.file)
    let lineContent = getbufline(bnum, item.line)[0]

    "mark, file, line num, line content
    let format =
      \g:utils#color8.red."%s".g:utils#color_reset.
      \" %s %".truncFileLength."s ".
      \g:utils#color8.cyan."%5s".g:utils#color_reset.
      \" %s"
    let format = substitute(format, " ", "\ua0", "g")
    call add(outList, printf(format, item.name, item.file, fileTrunc, item.line, lineContent))
  endfor
  return outList
endfunction
