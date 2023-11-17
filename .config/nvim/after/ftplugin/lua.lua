vim.b.language = {
  print = function(arg)
    return ([[vim.print(%s)]]):format(arg)
  end,
}
