local M = {}

---@class Gline.Config
M.config = {
  entry_width = 22, -- Width of each tab/entry in the tabline
  name = {
    enabled = true,
    max_len = 16, -- Max characters in name of active buffer for each tab
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
      color = "Statement", -- hex color(#000 | #000000) or highlight group
    },
    normal = {
      icon = "▏",
      color = "VertSplit", -- hex color(#000 | #000000) or highlight group
    },
  },
}

---@param conf Gline.Config?
M.merge_config = function(conf)
  if conf then
    M.config = vim.tbl_deep_extend("force", M.config, conf)
  end
end

setmetatable(M, {
  __index = function(_, key)
    return M.config[key]
  end,
})

return M
