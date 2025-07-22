-- Defines default configuration and highlight groups.
local M = {}

-- Default appearance settings
M.defaults = {
    position = "cursor", -- possible values: "cursor", "center"
    border = "none",
    width = 60,
    columns = 2,
    column_gap = 4,
    -- Highlight groups
    bg_hl = "SpeedialNormal",
    border_hl = "SpeedialBorder",
    key_hl = "SpeedialKey",
    chord_hl = "SpeedialChord",
    selected_hl = "SpeedialSelected",
    -- Plugin-managed items
    items = {},
}

-- Defines the custom highlight groups.
-- This should be called once during setup.
function M.setup_highlights()
    vim.api.nvim_set_hl(0, "SpeedialNormal", { bg = "#002b36", fg = "#2aa198" })
    vim.api.nvim_set_hl(0, "SpeedialBorder", { bg = "#002b36", fg = "#487680" })
    vim.api.nvim_set_hl(0, "SpeedialKey", { fg = "#2aa198", bold = true })
    vim.api.nvim_set_hl(0, "SpeedialChord", { fg = "#5566ff", italic = true })
    vim.api.nvim_set_hl(0, "SpeedialSelected", { bg = "#073642", fg = "#aaaaaa", bold = true })
end

return M
