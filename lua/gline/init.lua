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
  colors = {
    active_bg = "#151515", -- TODO: nil by default
    inactive_bg = "#000000",
  },
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
    enabled = true, -- if you have web-devicons installed but want it disabled for this plugin, set to false
    --TODO: colored?
    --TODO: default_icon
  },
  separator = {
    enabled = true,
    active_icon = "▎",
    inactive_icon = "▏",
    active_color = "#e1b655",
    inactive_color = "#282828",
  },
}

M.config = default_config

---@param opts GlineConfig?
M.setup = function(opts)
  if opts then
    M.config = vim.tbl_deep_extend("force", default_config, opts)
  end

  vim.o.tabline = "%!v:lua.require('gline.tabline')()"
end

return M
