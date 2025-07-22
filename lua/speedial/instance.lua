-- Represents a single, active instance of the speed-dial menu.
local ui = require("speedial.ui")

local Instance = {}
Instance.__index = Instance

function Instance.new(layout, config, on_close)
    local self = setmetatable({}, Instance)
    self.layout = layout
    self.config = config
    self.current_selection = 1
    self.on_close_callback = on_close
    self.win_id, self.buf_id, self.ns_id = ui.create(layout, config)
    self:setup_keymaps()
    self:update_highlight()
    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
        buffer = self.buf_id,
        once = true,
        callback = function() self:close() end,
    })
    return self
end

function Instance:close()
    if not self.win_id then return end
    ui.close(self.win_id)
    self.win_id, self.buf_id = nil, nil
    if self.on_close_callback then self.on_close_callback() end
end

function Instance:update_highlight()
    local selected = self.layout.selectable_map[self.current_selection]
    if selected then
        -- *** FIX: Pass the column boundaries to the UI function ***
        ui.update_selection(self.buf_id, self.ns_id, selected.line_nr, selected.start_col, selected.end_col,
            self.config.selected_hl)
    end
end

function Instance:select_next()
    self.current_selection = self.current_selection + 1
    if self.current_selection > #self.layout.selectable_map then self.current_selection = 1 end
    self:update_highlight()
end

function Instance:select_prev()
    self.current_selection = self.current_selection - 1
    if self.current_selection < 1 then self.current_selection = #self.layout.selectable_map end
    self:update_highlight()
end

function Instance:navigate_horizontal(direction)
    local map = self.layout.selectable_map
    local dim = self.layout.dimensions
    if dim.cols <= 1 then return end

    local current_entry = map[self.current_selection]
    if not current_entry then return end

    local current_line = current_entry.line_nr
    local current_col = current_entry.column
    local target_col = current_col + direction
    if target_col > dim.cols then target_col = 1 end
    if target_col < 1 then target_col = dim.cols end

    for i, entry in ipairs(map) do
        if entry.column == target_col and entry.line_nr == current_line then
            self.current_selection = i
            self:update_highlight()
            return
        end
    end
end

function Instance:select_right() self:navigate_horizontal(1) end

function Instance:select_left() self:navigate_horizontal(-1) end

function Instance:execute_item(item)
    self:close()
    if not item then return end
    vim.schedule(function()
        if type(item.action) == "function" then
            item.action()
        elseif type(item.action) == "string" then
            vim.cmd(item.action)
        end
    end)
end

function Instance:execute_selection()
    local selection = self.layout.selectable_map[self.current_selection]
    if selection then self:execute_item(selection.item) end
end

function Instance:setup_keymaps()
    local opts = { buffer = self.buf_id, nowait = true, silent = true }
    local keymap = vim.keymap.set
    keymap("n", "<Esc>", function() self:close() end, opts)
    -- keymap("n", "q", function() self:close() end, opts)
    keymap("n", "<CR>", function() self:execute_selection() end, opts)
    keymap("n", "<Down>", function() self:select_next() end, opts)
    -- keymap("n", "j", function() self:select_next() end, opts)
    keymap("n", "<Up>", function() self:select_prev() end, opts)
    -- keymap("n", "k", function() self:select_prev() end, opts)
    keymap("n", "<Right>", function() self:select_right() end, opts)
    -- keymap("n", "l", function() self:select_right() end, opts)
    keymap("n", "<Left>", function() self:select_left() end, opts)
    -- keymap("n", "h", function() self:select_left() end, opts)
    for _, entry in ipairs(self.layout.selectable_map) do
        local item = entry.item
        if item.chord and #item.chord > 0 then
            keymap("n", item.chord, function() self:execute_item(item) end, opts)
        end
    end
end

return Instance
