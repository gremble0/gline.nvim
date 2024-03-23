local M = {}

---@class GlineConfig
M.config = {
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

setmetatable(M, {
  __index = function(_, key)
    return M.config[key]
  end,
})

--TODO: setmetatable to not have to require(config).config ?
return M
