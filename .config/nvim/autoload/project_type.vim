
function! project_type#Guess() abort
  let g:project_type = 'generic'

  if filereadable('./Makefile.am')
    let g:project_type = 'gnu'
  elseif filereadable('./CMakeLists.txt')
    let g:project_type = 'cmake'
  elseif filereadable('./Cargo.toml')
    let g:project_type = 'rust'
  end
endfunction
