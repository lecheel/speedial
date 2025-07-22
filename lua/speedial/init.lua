-- A classic speed-dial menu for Neovim (Lua)
local config_module = require("speedial.config")
local layout_module = require("speedial.layout")
local Instance = require("speedial.instance")

local M = {}

-- Store the merged configuration and the single active menu instance.
-- Initialize with a deep copy of defaults to prevent errors if setup() is not called.
M.config = vim.tbl_deep_extend("force", {}, config_module.defaults)
local active_instance = nil

--- Public API: Open the speed dial menu.
function M.open()
    -- If already open, close it first.
    if active_instance then
        active_instance:close()
        return
    end

    -- Generate the layout based on current items and config.
    local layout = layout_module.generate(M.config.items, M.config)
    if not layout then
        vim.notify("Speedial: No items configured.", vim.log.levels.WARN)
        return
    end

    -- Create and store a new menu instance.
    -- The on_close callback ensures we clear the active_instance reference.
    active_instance = Instance.new(layout, M.config, function()
        active_instance = nil
    end)
end

--- Public API: Add an item to the menu list.
---@param item table The item to add, e.g., { label, key, action, chord }.
function M.add(item)
    -- Ensure items table exists before trying to add to it.
    if not M.config.items then M.config.items = {} end
    table.insert(M.config.items, item)
end

--- Public API: Configure the plugin.
--- This should be called by the user in their Neovim config.
---@param user_config table User-provided configuration overrides.
function M.setup(user_config)
    -- Define highlights once
    config_module.setup_highlights()

    -- Merge user config with a fresh deep copy of the defaults.
    -- This makes multiple setup() calls non-additive and predictable.
    local defaults_copy = vim.tbl_deep_extend("force", {}, config_module.defaults)
    M.config = vim.tbl_deep_extend("force", defaults_copy, user_config or {})

    -- Ensure `items` is always a table, even if the user provides `items = nil`.
    if not M.config.items then
        M.config.items = {}
    end
end

-- The self-registering command and keymap have been removed.
-- Your lazy.nvim configuration now handles this, which is the correct approach.

return M
