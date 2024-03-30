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
local components = require("gline.components")

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
```
Each component defines default options internally, which can be changed by the opts table in the setup function. Here are the options for the default components and their default values
```lua
---@class Gline.Component.Separator.Opts
---@field normal? {color: string, icon: string}
---@field selected? {color: string, icon: string}
separator.normal = opts.normal or {
  color = "VertSplit",
  icon = "▏",
}
separator.selected = opts.selected or {
  color = "Keyword",
  icon = "▎",
}

---@class Gline.Component.FtIcon.Opts
---@field colored? boolean
if opts.colored == false then
  ft_icon.colored = false
else
  ft_icon.colored = true
end

---@class Gline.Component.BufName.Opts
---@field max_len? integer
---@field no_name_label? string
buf_name.max_len = opts.max_len or 16
buf_name.no_name_label = opts.no_name_label or "[No Name]"

---@class Gline.Component.Modified.Opts
---@field icon? string
modified.icon = opts.icon or "●"
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
---@field init fun(self: Gline.Component, opts?: table<string, any>): Gline.Component constructor method that initializes the factory
---@field make fun(self: Gline.Component, tab: Gline.TabInfo): string makes this components string given some tabinfo
---@field opts table<string, any>
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
  example.opts = opts or {}
  return example
end

function ExampleComponent:make(tab)
  -- For actual components you should probably do some sort of logic for highlights.
  -- See `:help statusline` for how vim renders strings for the tabline
  return tab.is_selected and self.opts.selected or self.opts.normal
end

require("gline").setup({
  sections = {
    -- NOTE: By defining left in the sections here we will override the default config
    -- If you want to add your own components while keeping the defaults, copy from the default config.
    left = {
      -- [2] here will be passed as opts like ExampleComponent:init({ selected = "a", normal = "b" })
      { ExampleComponent, { selected = "a", normal = "b" } },
    },
  },
})
```
