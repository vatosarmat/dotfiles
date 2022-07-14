vim.o.foldlevel = 99
vim.o.foldenable = true

local braces = {
  ['{'] = '}',
  ['['] = ']'
}

require('ufo').setup({
  open_fold_hl_timeout = 250,
  fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate, ctx)
    -- virtText - list of chunks {text, hlGroup}
    -- lnum - region start line
    -- endLnum - region end line
    -- width, truncate - related to screen width
    local textLastChar = string.sub(ctx.text, #ctx.text, #ctx.text)
    local suffixLastChar = braces[textLastChar] or ''
    local newVirtText = {}
    local suffix = (' ⤷ ...%d %s'):format(endLnum - lnum, suffixLastChar)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        chunkText = truncate(chunkText, targetWidth - curWidth)
        local hlGroup = chunk[2]
        table.insert(newVirtText, { chunkText, hlGroup })
        chunkWidth = vim.fn.strdisplaywidth(chunkText)
        -- str width returned from truncate() may less than 2nd argument, need padding
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, 'Folded' })
    return newVirtText
  end,
  provider_selector = function()
    return { 'treesitter', 'indent' }
  end
})
