-- Define some shortcuts for highlight groups
local HIGHLIGHT = "%#Tabline#"
local HIGHLIGHT_SEP = "%#TablineSep#"
local HIGHLIGHT_SEL = "%#TablineSel#"
local HIGHLIGHT_SEL_SEP = "%#TablineSelSep#"
local HIGHLIGHT_FILL = "%#TablineFill#"
local config = require("gline").config

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
  return tab.tabnr == vim.fn.tabpagenr() and (HIGHLIGHT_SEL_SEP .. "▎") or (HIGHLIGHT_SEP .. "▏")
end

---@param tab Tab
---@return string
local component_icon = function(tab)
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
  return name:len() > width and name:sub(1, width) .. "…" or name
end

---@param tab Tab
---@return string
local component_name = function(tab)
  local tabpage_is_active = tab.tabnr == vim.fn.tabpagenr()
  local buf_name = vim.fn.bufname(tabpage_get_active_buf(tab.tabnr))
  local name = buf_name == "" and "[No Name]" or vim.fn.fnamemodify(buf_name, ":t")
  -- TODO: get [No Name] from vim api? i think there is some option to change this
  -- TODO: expand when no name gets set ref: fugitive

  return (tabpage_is_active and HIGHLIGHT_SEL or HIGHLIGHT) .. name_trim_to_width(name, config.max_name_len)
end

---@param tab Tab
---@return string
local component_modified = function(tab)
  return vim.api.nvim_buf_get_option(tabpage_get_active_buf(tab.tabnr), "modified") and config.modified_icon or ""
end

---Get the rendered length of an entry, i.e. string length excluding highlight groups
---@param entry string
---@return integer
local entry_rendered_width = function(entry)
  local len_iter = entry:len()
  for highlight in entry:gmatch("%%#.-#") do -- Matches inline hl groups like %#HighlightGroup#
    len_iter = len_iter - highlight:len()
  end

  return len_iter
end

---@param entry string
---@return string left_padding, string right_padding
local entry_pad_to_width = function(entry)
  local total_padding = config.entry_width - entry_rendered_width(entry) -- TODO: entry:rendered_length() ?, entry:add_component()

  local left_padding = (" "):rep(math.floor(total_padding / 2))
  local right_padding = (" "):rep(math.ceil(total_padding / 2) + 1) -- +1 because left is also padded with separator

  return left_padding, right_padding
end

---@param tab Tab
---@return string
local tabline_make_entry = function(tab)
  local separator = component_separator(tab) -- TODO: tab:get_separator(), tab:get_icon(), etc.
  local icon = component_icon(tab)
  local name = component_name(tab)
  local modified = component_modified(tab)
  modified = modified:len() > 1 and modified or ""

  local entry_unpadded = separator .. icon .. name .. modified
  local left_padding, right_padding = entry_pad_to_width(entry_unpadded)

  return separator .. left_padding .. icon .. name .. modified .. right_padding
end

return function()
  local tabline_builder = ""
  for _, tab in ipairs(vim.fn.gettabinfo()) do
    tabline_builder = tabline_builder .. tabline_make_entry(tab)
  end

  return tabline_builder .. HIGHLIGHT_FILL
end
