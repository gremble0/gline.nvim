---@class GlineConfig
local M = {}

---@class GlineConfig
local default_config = {
  entry_width = 22, -- Width of each tab/entry in the tabline
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

M.config = default_config

---@param partial_config GlineConfig
M.merge_config = function(partial_config)
  M.config = vim.tbl_extend("force", default_config, partial_config)
end

return M