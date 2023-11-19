### API layers
- Vim API: ex-commands, Vimscript builtin and user-defined functions: vim.fn., vim.cmd.
- Nvim API: vim.api.
- Lua API: vim.
- Lua builtins
- My lua utils

##### Edit buffer 
- `vim.fn.append` - append line
  - `append(line('$'), 'hello')` - append line at the end
- `nvim_buf_set_text`, `nvim_buf_set_lines`

##### File system
- `vim.fn.filereadable` - check file is readable and not a dir
- `vim.fn.isdirectory` - check dir exists
- `vim.fn.readdir` - iterates files in dir 
- `vim.fn.glob(glob, false, true)` - get list of files matching glob
- `vim.fn.mkdir` - 
  - `vim.fn.mkdir('/long/path/to/be/created/with/p/flag/or/do/nothing/if/aready/exists', 'p')` - 
- `vim.fn.writefile` - takes string list, cannot write multiline strings, need to create vim *Blob* for that
- `vim.loop.fs_open`, `fs_write`, `fs_unlink`, `fs_stat` - create, write, delete, check if exists
- `io.open`, `io:read()`, `io:close()` - open, read, close

##### Path
- `vim.fn.getcwd`
- `vim.fn.fnamemodify`

##### Strings and patterns
- `vim.startswith(str, prefix)`
- `vim.endswith(str, suffix)`
- `vim.split(str, sep, opts)`
- `string.rep(str, n)` - repeat str n times
- `string.sub(str, i)` - slice substring
- `string.gsub(str, pattern, repl [, n])` - replace substring
- `string.find(str, pattern [, init [, plain]])`
- `string.match(str, pattern)` - returns captures as several values

##### Tables and lists
- `vim.tbl_extend(error|keep|force, ...tables)` - doesn't mutate, returns result
- `vim.tbl_deep_extend(error|keep|force, ...tables)`
- `vim.tbl_map(func, t)` - 
- `vim.tbl_filter(predicate, table)`
- `vim.tbl_contains(t, value)`
- `vim.tbl_get(tbl, [...path])`
- `table.remove(tbl, [pos])`
- `utils.find(array, cb)`

##### Types and validation
- `vim.is_callable(maybe_f)`
- `vim.validate(args_table)`
