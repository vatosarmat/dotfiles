-- Custom filetype detection logic with the new Lua filetype plugin
vim.filetype.add {
  extension = {
    ejs = 'ejs'
  }
}
vim.filetype.add({
  pattern = {
    ['%.env%.%l+'] = 'sh'
  }
})
