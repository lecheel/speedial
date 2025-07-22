-- Manages the Neovim window, buffer, and highlights.
local M = {}

function M.get_position(position_config, dimensions)
    if position_config == "center" then
        local row = math.floor((vim.o.lines - dimensions.height) / 2)
        local col = math.floor((vim.o.columns - dimensions.width) / 2)
        return row, col
    end
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local screen_pos = vim.fn.screenpos(0, cursor_pos[1], cursor_pos[2] + 1)
    local screen_row = screen_pos.row - 1
    local screen_col = screen_pos.col - 1
    local row = screen_row + 1
    if row + dimensions.height > vim.o.lines - 2 then
        row = screen_row - dimensions.height
    end
    row = math.max(0, row)
    local col = screen_col
    if col + dimensions.width > vim.o.columns then
        col = vim.o.columns - dimensions.width
    end
    col = math.max(0, col)
    return row, col
end

function M.create(layout, config)
    local buf_id = vim.api.nvim_create_buf(false, true)
    vim.bo[buf_id].bufhidden = "wipe"
    vim.bo[buf_id].buftype = "nofile"
    vim.bo[buf_id].swapfile = false
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, layout.lines)
    vim.bo[buf_id].modifiable = false
    local row, col = M.get_position(config.position, layout.dimensions)
    local win_id = vim.api.nvim_open_win(buf_id, true, {
        relative = "editor",
        width = layout.dimensions.width,
        height = layout.dimensions.height,
        style = "minimal",
        border = config.border,
        noautocmd = true,
        row = row,
        col = col,
    })
    vim.wo[win_id].cursorline = false
    vim.wo[win_id].number = false
    vim.wo[win_id].relativenumber = false
    vim.wo[win_id].wrap = false
    pcall(vim.api.nvim_win_set_option, win_id, "winhl", "Normal:" .. config.bg_hl)
    for _, h in ipairs(layout.highlights.key) do
        vim.api.nvim_buf_add_highlight(buf_id, -1, config.key_hl, h[1], h[2], h[3])
    end
    for _, ch in ipairs(layout.highlights.chord) do
        vim.api.nvim_buf_add_highlight(buf_id, -1, config.chord_hl, ch[1], ch[2], ch[3])
    end
    local selection_ns_id = vim.api.nvim_create_namespace("speedial_selection")
    return win_id, buf_id, selection_ns_id
end

--- Updates the selection highlight in the buffer.
---@param buf_id integer The buffer handle.
---@param ns_id integer The namespace for selection highlights.
---@param line_nr integer The line number to highlight (1-based).
---@param start_col integer The starting column for the highlight (0-based).
---@param end_col integer The ending column for the highlight (0-based).
---@param hl_group string The highlight group to apply.
function M.update_selection(buf_id, ns_id, line_nr, start_col, end_col, hl_group)
    if not vim.api.nvim_buf_is_valid(buf_id) then return end
    vim.api.nvim_buf_clear_namespace(buf_id, ns_id, 0, -1)
    if line_nr then
        -- Note: nvim_buf_add_highlight uses 0-indexed line numbers.
        vim.api.nvim_buf_add_highlight(buf_id, ns_id, hl_group, line_nr - 1, start_col, end_col)
    end
end

--- Closes the floating window.
function M.close(win_id)
    if win_id and vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
    end
end

return M
