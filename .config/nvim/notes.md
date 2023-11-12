### API layers
- Vim API: ex-commands, Vimscript builtin and user-defined functions: vim.fn., vim.cmd.
- Nvim API: vim.api.
- Lua API: vim.
- Lua builtins

##### Edit buffer 
- `vim.fn.append` - append line
  - `append(line('$'), 'hello')` - append line at the end
- `nvim_buf_set_text`, `nvim_buf_set_lines`

##### File system
- `vim.fn.filereadable` - check file is readable and not a dir
- `vim.fn.isdirectory` - check dir exists
- `vim.fn.mkdir` - 
  - `vim.fn.mkdir('/long/path/to/be/created/with/p/flag/or/do/nothing/if/aready/exists', 'p')` - 
- `vim.fn.writefile` - takes string list, cannot write multiline strings, need to create vim *Blob* for that
- `vim.fn.getcwd`, `vim.fn.fnamemodify`
- `vim.loop.fs_open`, `fs_write`, `fs_unlink`, `fs_stat` - create, write, delete, check if exists
- `io.open`, `io:read()`, `io:close()` - open, read, close

##### Strings
- `vim.startswith`, `endswith`
- `string.find(s, pattern [, init [, plain]])`

##### Tables and lists
- `vim.tbl_extend(error|keep|force, ...tables)` - doesn't mutate, returns result
- `vim.tbl_deep_extend(error|keep|force, ...tables)`
