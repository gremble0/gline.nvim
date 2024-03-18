local M = {}

M.setup = function()
	vim.o.tabline = "%!v:lua.require('gline.tabline')()"
end

return M
