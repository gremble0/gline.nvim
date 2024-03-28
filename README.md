# gline.nvim
A modular lightweight tabline plugin for neovim, with a simple interface for adding custom components.

## Adding your own components
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
      -- [2] here will be passed as opts to ExampleComponent:init({ text = "a" })
      { ExampleComponent, { selected = "a", normal = "b" } },
    },
  },
})
```
