# gline.nvim
(YET ANOTHER) modular lightweight tabline plugin for neovim, with a simple interface for adding custom components. This plugin has intentionally dropped features I find unnecessary like mouse support, animations, pinning, etc. to keep it minimal and fast.

![gline preview](https://github.com/gremble0/gline.nvim/assets/45577341/73f7f507-3853-46a8-9328-ddf0c7b9e558)

## Setup
Use your favorite package manager to import the plugin. The plugin can easily be lazy loaded if your package manager allows it. Following is how to setup the plugin with the default configuration using lazy.nvim. The default components provided with the plugin will use the `TabLine` and `TabLineSel` highlight groups for most of its theming (see `:help nvim_set_hl()` if you want to override the colors from your current colorscheme)
```lua
{
  "gremble0/gline.nvim",
  -- nvim-web-devicons is required by default. If you don't want the file type icon
  -- component you can remove the dependency and redefine the center section in the setup (see below)
  dependencies = "nvim-tree/nvim-web-devicons",
  -- Uncomment if you want to lazy load
  -- event = "TabNew"
  config = function()
    require("gline").setup()
  end
}
```

<details>
<summary>Show full default configuration</summary>
<br>

```lua
-- ...
local components = require("gline.components")

M.config = {
  -- Width of each tab/entry in the tabline. Will be overridden if components together are bigger than this
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
-- ...
```
Each component defines default options internally, which can be changed by the opts table in the setup function. Here are the options for the default components and their default values
```lua
---`color` here can either be a 6 digit hex color or a vim highlight group
---@class Gline.Component.Separator.Opts
---@field normal? {color?: string, icon?: string} defaults to { color = "VertSplit", icon = "▏" }
---@field selected? {color?: string, icon?: string} defaults to { color = "Keyword", icon = "▎" }

---@class Gline.Component.FtIcon.Opts
---@field colored? boolean defaults to true

---@class Gline.Component.BufName.Opts
---@field max_len? integer defaults to 16
---@field no_name_label? string defaults to "[No Name]"

---@class Gline.Component.Modified.Opts
---@field icon? string defaults to "●"
```
</details>

## Modifying components
### Modifying default components
To modify the default components you can change the options in the sections table. For example if you want to swap the placements of the `Modified` and `Separator` components, but keep the default options you could do it like this:

```lua
local components = require("gline.components")

require("gline").setup({
  -- Width of each tab/entry in the tabline. Will be overridden if components are bigger than this
  min_entry_width = 24,

  sections = {
    -- Comes before left padding
    left = {
      { components.Modified, {} },
    },
    -- `center` will have the same components if omitted from setup
    right = {
      { components.Separator, {}, },
    },
  },
})
```
If you want to change any options you can modify the opts table passed for each component. For example:
```lua
local components = require("gline.components")

require("gline").setup({
  sections = {
    left = {
      {
        components.Separator,
        {
          selected = { color = "#ff0000", icon = ">" },
        },
      },
    },
  },
})
```

### Adding your own components
To add your own components you need to define a component that implements the following interface:
```lua
---@class Gline.Component
---@field init fun(self: Gline.Component, opts?: table<string, any>): Gline.Component constructor method, opts is different for each implementor
---@field make fun(self: Gline.Component, tab_info: Gline.TabInfo): string makes this components string given some tabinfo
---@field normal table<string, any> options for a component when its in a tab thats not selected
---@field selected table<string, any> options for a component when its in a tab that is selected
```

Where `Gline.TabInfo` contains data commonly used within components. It is defined as follows:
```lua
---@class Gline.TabInfo
---@field tabnr integer
---@field variables table<string, any>
---@field windows integer[]
---@field is_selected boolean
---@field selected_buf integer
```

The `:init()` method should do things you want to only be executed once, when doing initial setup. This could be things like setting some internal state, parsing some options, setting highlights, etc. The `:make()` method will be called every time the tabline is redrawn where the string it returns is added into the tab.

Here is a very simple example of how you can make a custom component and include it in your tabline
```lua
---@class Gline.Component.Example : Gline.Component
local ExampleComponent = {}
ExampleComponent.__index = ExampleComponent

function ExampleComponent:init(opts)
  local example = setmetatable({}, ExampleComponent)
  -- See `:help statusline` for how vim renders strings for the tabline, if you dont understand "%#TabLine#"
  -- Parsing opts just to show how you could do that. For personal components you
  -- could just ignore the opts parameter
  example.normal = { text = opts.normal and opts.normal.text or "a", highlight = "%#TabLine#" }
  example.selected = { text = opts.selected and opts.selected.text or "b", highlight = "%#Error#" }
  return example
end

function ExampleComponent:make(tab)
  return tab.is_selected and (self.selected.highlight .. self.selected.text)
    or (self.normal.highlight .. self.normal.text)
end

require("gline").setup({
  sections = {
    -- NOTE: By defining left in the sections here we will override the left components in the default config
    -- If you want to add your own components while keeping the defaults, copy from the default config.
    left = {
      -- [2] here will be passed as opts like ExampleComponent:init({ selected = "c" })
      { ExampleComponent, { selected = { text = "c" } } },
    },
  },
})
```
