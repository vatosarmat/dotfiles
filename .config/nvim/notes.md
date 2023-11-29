### API layers
- Vim API: ex-commands, Vimscript builtin and user-defined functions: vim.fn., vim.cmd.
- Nvim API: vim.api.
- Lua API: vim.
- Lua builtins
- My lua utils and vim_utils

##### Get buffer/editor info
- `vim.fn.line({expr} [, {winid}])` - line number(from 1) of: 
  - .  cursor
  - $  last line
  - 'x mark
  - w0 first visible in current window line
  - w$ last visible in current window line
  - v  in visual mode - start of the selected area, cursor in other modes
- `vim.fn.col({expr} [, {winid})` - col number(from 1), same but without w0 and w$
- `vim.fn.getpos({expr})` - [bufnum, lnum, col, off], like `line`

##### Edit buffer 
- `vim.fn.append` - append line
  - `append(line('$'), 'hello')` - append line at the end
- `vim.fn.setreg({regname}, {value} [, {options}])` - write into register
  - `setreg('"', 'vasya')`
- `nvim_buf_set_text`, `nvim_buf_set_lines`
- `vim_utils.get_visual_selection_lines()` - returns selected lines
- `vim_utils.feed_keys()` - should be used for mode changing

##### File system
- `vim.fn.filereadable` - check file is readable and not a dir
- `vim.fn.isdirectory` - check dir exists
- `vim.fn.readdir(dir_path, predicate)` - get files in dir. predicate allows to filter
- `vim.fn.glob(glob, false, true)` - get list of files matching glob. Doesn't work with .files, they are considered "hidden"
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
- `vim.tbl_contains(t, value)` - check if value is in table
- `vim.tbl_get(tbl, [...path])`
- `table.remove(tbl, [pos])` - for some reason, unlike string functions, table functions can't be called as tbl:remove()
- `table.concat (table [, sep [, i [, j]]])` - join table elements
- `utils.find(array, cb)`

##### Types and validation
- `vim.is_callable(maybe_f)`
- `vim.validate(args_table)`
