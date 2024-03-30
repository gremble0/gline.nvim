local components = require("gline.components")

local M = {}

---@class Gline.Config.SectionItem
---@field [1] Gline.Component some component
---@field [2]? table<string, any> any options passed to the components constructor
---@see Gline.Component

---@class Gline.Config.Sections
---@field left? Gline.Config.SectionItem[]
---@field center? Gline.Config.SectionItem[]
---@field right? Gline.Config.SectionItem[]

---@class Gline.Config
---@field min_entry_width? integer
---@field sections? Gline.Config.Sections

---The active config used for gline, can be modified by the user through the setup function
---@type Gline.Config
M.config = {
  -- Width of each tab/entry in the tabline. Will be overridden if components are bigger than this
  min_entry_width = 24,

  sections = {
    left = {
      { components.Separator, {} },
    },
    center = {
      { components.FtIcon, {} }, -- Requires nvim-web-devicons
      { components.BufName, {} },
    },
    right = {
      { components.Modified, {} },
    },
  },
}

---Merge some config with the current config
---@param conf Gline.Config
M.merge_config = function(conf)
  M.config = vim.tbl_deep_extend("force", M.config, conf)
end

-- So you can do for example require("gline.config").min_entry_width instead of require("gline.config").config.min_entry_width
setmetatable(M, {
  __index = function(_, key)
    return M.config[key]
  end,
})

return M
