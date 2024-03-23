local M = {}

---@class GlineConfig
local default_config = {
  entry_width = 22,
  name = {
    enabled = true,
    max_len = 15,
  },
  modified = {
    enabled = true,
    icon = "●",
  },
  ft_icon = {
    enabled = true, -- if you have web-devicons but want it disabled for this plugin, set to false
  },
  separator = {
    enabled = true,
    selected = {
      icon = "▎",
      color = "#e1b655", ---@type string hex color or highlight group
    },
    normal = {
      icon = "▏",
      color = "#282828", ---@type string hex color or highlight group
    },
  },
}

---@type GlineConfig
M.config = default_config

---@param opts GlineConfig?
M.setup = function(opts)
  if opts then
    M.config = vim.tbl_extend("force", default_config, opts)
  end

  vim.o.tabline = "%!v:lua.require('gline.tabline')()"
end

return M
