local M = {}

-- Import necessary modules
local config_module = require("dev.speedial.config") -- Import config module
local layout_module = require("dev.speedial.layout")
local Instance = require("dev.speedial.instance")

-- Store the full configuration
M.config = {}

-- Define a simple, built-in default menu.
-- This provides a working menu out-of-the-box.
local builtin_default_menu_items = {
    { label = "Find File", key = "f", action = ":Telescope find_files", chord = "f", desc = "Find File" },
    { label = "Live Grep", key = "g", action = ":Telescope live_grep",  chord = "g", desc = "Live Grep" },
    { label = "Buffers",   key = "b", action = ":Telescope buffers",    chord = "b", desc = "List Buffers" },
    { label = "Help Tags", key = "h", action = ":Telescope help_tags",  chord = "h", desc = "Search Help" },
    -- Add more generic, useful items as defaults if desired
}

--- Setup Speedial
--- @param opts table Configuration options
function M.setup(opts)
    -- 1. Setup custom highlight groups - DO THIS FIRST
    if config_module.setup_highlights and type(config_module.setup_highlights) == "function" then
        config_module.setup_highlights()
    else
        -- Fallback: Define minimal highlights if config.setup_highlights fails
        pcall(vim.api.nvim_set_hl, 0, "SpeedialNormal", { bg = "NONE", fg = "NONE" })
        pcall(vim.api.nvim_set_hl, 0, "SpeedialKey", { fg = "Cyan", bold = true })
        pcall(vim.api.nvim_set_hl, 0, "SpeedialChord", { fg = "Blue", italic = true })
        pcall(vim.api.nvim_set_hl, 0, "SpeedialSelected", { bg = "DarkGray", fg = "White", bold = true })
    end

    -- 2. Merge user options with the defaults defined in config.lua
    -- Ensure config_module.defaults exists and is a table
    local base_defaults = config_module.defaults or {}
    if type(base_defaults) ~= "table" then
        base_defaults = {}
    end
    -- Merge base defaults with user options
    M.config = vim.tbl_deep_extend("force", base_defaults, opts or {})

    -- 3. Ensure menus is a table
    M.config.menus = M.config.menus or {}
end

--- Resolve a menu name or definition to an item table.
--- @param menu_spec string|table The menu name (string) or direct item table.
--- @return table|nil items The resolved items table, or nil on failure.
local function resolve_menu_items(menu_spec)
    if type(menu_spec) == "table" then
        return menu_spec
    elseif type(menu_spec) == "string" then
        local success, module_or_items = pcall(require, menu_spec)
        if success then
            if type(module_or_items) == "table" then
                return module_or_items
            else
                vim.notify("Speedial: Module '" .. menu_spec .. "' did not return a table.", vim.log.levels.ERROR)
                return nil
            end
        else
            vim.notify("Speedial: Failed to load menu module '" .. menu_spec .. "': " .. tostring(module_or_items),
                vim.log.levels.ERROR)
            return nil
        end
    else
        vim.notify("Speedial: Invalid menu specification type: " .. type(menu_spec), vim.log.levels.ERROR)
        return nil
    end
end

--- Open a Speedial menu.
--- @param menu_name string|nil (Optional) Name of the menu to open. Defaults to "default".
function M.open(menu_name)
    menu_name = menu_name or "default"

    local menu_spec = nil
    -- Check if the user defined a specific menu for this name
    if M.config.menus and M.config.menus[menu_name] then
        menu_spec = M.config.menus[menu_name]
    else
        -- If it's the special "default" name and no user menu was found,
        -- use the built-in default items.
        if menu_name == "default" then
            menu_spec = builtin_default_menu_items
        else
            -- Otherwise, assume the menu_name is a module name to load directly
            menu_spec = menu_name
        end
    end

    if not menu_spec then
        vim.notify("Speedial: No menu specification found for '" .. menu_name .. "'.", vim.log.levels.WARN)
        return
    end

    local items_to_use = resolve_menu_items(menu_spec)

    if not items_to_use or vim.tbl_isempty(items_to_use) then
        vim.notify("Speedial: Menu '" .. menu_name .. "' is empty or could not be loaded.", vim.log.levels.WARN)
        return
    end

    -- Use the M.config which now correctly includes defaults and user overrides
    local popup_config = M.config -- This is the correctly merged config

    local layout = layout_module.generate(items_to_use, popup_config)

    if not layout then
        vim.notify("Speedial: Failed to generate layout for menu '" .. menu_name .. "'.", vim.log.levels.ERROR)
        return
    end

    -- Pass the correctly merged popup_config to Instance.new
    local instance = Instance.new(layout, popup_config, function()
        -- Optional on_close callback
    end)
end

return M
