local M = {}

---@class GlineConfig
---@field entry_width? integer
---@field max_name_len? integer
---@field modified_icon? string
---@field use_ft_icons? boolean
---@field active_separator? string
---@field inactive_separator? string

---@type GlineConfig
local default_config = {
  entry_width = 26,
  max_name_len = 20,
  modified_icon = "[+]",
  use_ft_icons = true,
  active_separator = "▎",
  inactive_separator = "▏",
}

M.config = default_config

---@param opts GlineConfig
M.setup = function(opts)
  if opts then
    M.config = vim.tbl_extend("force", default_config, opts)
  end

  vim.o.tabline = "%!v:lua.require('gline.tabline')()"
end

return M
