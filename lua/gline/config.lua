local components = require("gline.components")

local M = {}

---@class Gline.Config.SectionItem: table<number, Gline.ComponentFactory | table<string, any>>

---@class Gline.Config.Sections
---@field left Gline.Config.SectionItem[]
---@field center Gline.Config.SectionItem[]
---@field right Gline.Config.SectionItem[]

---@class Gline.Config
---@field entry_width integer
---@field sections Gline.Config.Sections

---@type Gline.Config
M.config = {
  entry_width = 22, -- Width of each tab/entry in the tabline

  sections = {
    -- Comes before left padding
    left = {
      { components.SeparatorFactory, {} },
    },
    -- Comes after left padding before right padding
    center = {
      { components.FtIconFactory, {} },
      { components.BufNameFactory, {} },
      { components.ModifiedFactory, {} },
    },
    -- Comes after right padding
    right = {},
  },
}

---@param conf Gline.Config?
M.merge_config = function(conf)
  if conf then
    M.config = vim.tbl_deep_extend("force", M.config, conf)
  end
end

-- So you can do require("gline.config").entry_width instead of require("gline.config").config.entry_width
setmetatable(M, {
  __index = function(_, key)
    return M.config[key]
  end,
})

return M
