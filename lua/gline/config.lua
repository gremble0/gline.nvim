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
    -- Comes before left padding
    left = {
      {
        components.Separator,
        {
          normal = {
            color = "VertSplit", -- 6 digit hex color or highlight group
            icon = "▏",
          },
          selected = {
            color = "Keyword", -- 6 digit hex color or highlight group
            icon = "▎",
          },
        },
      },
    },
    -- Comes after left padding before right padding
    center = {
      { components.FtIcon, {} }, -- Requires nvim-web-devicons
      { components.BufName, { max_len = 16 } },
    },
    -- Comes after right padding
    right = {
      { components.Modified, { icon = "●" } },
    },
  },
}

---Merge some config with the current config
---@param conf Gline.Config?
M.merge_config = function(conf)
  if conf then
    M.config = vim.tbl_deep_extend("force", M.config, conf)
  end
end

-- So you can do for example require("gline.config").entry_width instead of require("gline.config").config.entry_width
setmetatable(M, {
  __index = function(_, key)
    return M.config[key]
  end,
})

return M
