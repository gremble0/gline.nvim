local config = require("gline").config
local colors = require("gline.colors")

---@param tabpage integer
---@return integer id of active buffer in the given tabpage
local tabpage_get_active_buf = function(tabpage)
  local buflist = vim.fn.tabpagebuflist(tabpage)
  local winnr = vim.fn.tabpagewinnr(tabpage)

  return type(buflist) == "number" and buflist or buflist[winnr]
end

---This class is a mockup of the returntype of each element in vim.fn.gettabinfo()
---@class Tab
---@field tabnr integer
---@field variables table<string, any>
---@field windows integer[]

---@param tab Tab
---@return string
local component_separator = function(tab)
  local active = config.separator.selected
  local inactive = config.separator.normal

  return tab.tabnr == vim.fn.tabpagenr() and (colors.sel_sep .. active.icon) or (colors.norm_sep .. inactive.icon)
end

---@param tab Tab
---@return string
local component_ft_icon = function(tab)
  local tabpage_active_buf = tabpage_get_active_buf(tab.tabnr) -- TODO: fix?
  local buf_ft = vim.api.nvim_buf_get_option(tabpage_active_buf, "ft")
  -- TODO: pcall() ?
  local icon, icon_hl = require("nvim-web-devicons").get_icon_by_filetype(buf_ft, { default = true })

  return "%#" .. icon_hl .. "#" .. icon
end

---@param name string
---@param width integer
---@return string
local name_trim_to_width = function(name, width)
  return #name > width and name:sub(1, width) .. "…" or name
end

---@param tab Tab
---@return string
local component_name = function(tab)
  local tabpage_is_active = tab.tabnr == vim.fn.tabpagenr()
  local buf_name = vim.fn.bufname(tabpage_get_active_buf(tab.tabnr))
  local name = buf_name == "" and "[No Name]" or vim.fn.fnamemodify(buf_name, ":t")
  -- TODO: get [No Name] from vim api? i think there is some option to change this
  -- TODO: expand when no name gets set ref: fugitive

  return (tabpage_is_active and colors.sel or colors.norm) .. name_trim_to_width(name, config.name.max_len)
end

---@param tab Tab
---@return string
local component_modified = function(tab)
  return vim.api.nvim_buf_get_option(tabpage_get_active_buf(tab.tabnr), "modified") and config.modified.icon or ""
end

---Get the rendered length of an entry, i.e. string length excluding highlight groups
---@param entry string
---@return integer
local entry_rendered_width = function(entry)
  -- `#` or `:len()` will not be right here, as that counts bytes, not chars
  local len_iter = vim.fn.strchars(entry)
  for highlight in entry:gmatch("%%#.-#") do -- Matches inline hl groups like %#HighlightGroup#
    len_iter = len_iter - #highlight
  end

  return len_iter
end

---@param entry string
---@return string left_padding, string right_padding
local entry_pad_to_width = function(entry)
  local total_padding = config.entry_width - entry_rendered_width(entry) -- TODO: entry:rendered_length() ?, entry:add_component()

  local left_padding = (" "):rep(math.floor(total_padding / 2))
  local right_padding = (" "):rep(math.ceil(total_padding / 2))

  return left_padding, right_padding
end

---@param tab Tab
---@return string
local tabline_make_entry = function(tab)
  -- TODO: tab:get_separator(), tab:get_icon(), etc.
  local separator = config.separator.enabled and component_separator(tab) or ""
  -- TODO: component_tab_id()
  local ft_icon = config.ft_icon.enabled and component_ft_icon(tab) or ""
  local name = config.name.enabled and component_name(tab) or ""
  local modified = config.modified.enabled and component_modified(tab) or ""

  local entry_unpadded = separator .. ft_icon .. " " .. name .. " " .. modified
  local left_padding, right_padding = entry_pad_to_width(entry_unpadded)

  local entry = separator .. left_padding .. ft_icon .. " " .. name .. " " .. modified .. right_padding

  return entry
end

return function()
  local tabline_builder = ""
  for _, tab in ipairs(vim.fn.gettabinfo()) do
    tabline_builder = tabline_builder .. tabline_make_entry(tab)
  end

  return tabline_builder .. colors.fill
end
