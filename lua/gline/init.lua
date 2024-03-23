local M = {}

---@class GlineConfig
local default_config = {
  tab_width = 22, -- Width of each tab/entry in the tabline
  name = {
    enabled = true,
    max_len = 15, -- Max characters in name of active buffer for each tab
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
      color = "Statement", ---@type string hex color or highlight group
    },
    normal = {
      icon = "▏",
      color = "VertSplit", ---@type string hex color or highlight group
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
