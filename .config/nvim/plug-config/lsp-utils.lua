local lsp_utils = {}

-- function lsp_utils.list_clients()
--   local sep = ','
--   local result = ''
--   for _, client in ipairs(vim.lsp.buf_get_clients(0)) do
--     result = result .. sep .. client.name
--   end

--   if vim.startswith(result, sep) then
--     result = string.sub(result, #sep + 1)
--   end

--   return result
-- end

-- function lsp_utils.progress()
--   local msgs = vim.lsp.util.get_progress_messages()
--   print(vim.inspect(msgs))
--   local array = vim.tbl_keys(msgs)
--   local sep = ','
--   local result = ''
--   for _, v in ipairs(array) do
--     result = result .. sep .. v
--   end

--   if vim.startswith(result, sep) then
--     result = string.sub(result, #sep + 1)
--   end
--   return result
-- end

