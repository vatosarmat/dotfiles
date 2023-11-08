vim.b.language = {
  print = function(arg)
    return ([[console.log(%s)]]):format(arg)
  end,
  export = function(arg)
    return ('exports.%s = %s'):format(arg, arg)
  end,
}
