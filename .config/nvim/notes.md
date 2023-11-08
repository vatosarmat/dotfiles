##### Edit buffer 
- `vim.fn.append` - append line
- `append(line('$'), 'hello')` - append line at the end
- `nvim_buf_set_text`, `nvim_buf_set_lines`

##### Files 
- `vim.fn.writefile` takes string list, cannot write multiline strings, need to create vim *Blob* for that
- `vim.loop.fs_open`, `fs_write`, `fs_unlink` - create, write, delete

##### Strings
- `vim.startswith`, `endswith`
- `string.find(s, pattern [, init [, plain]])`
