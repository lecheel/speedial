-- Generates the visual layout for the menu buffer.
local M = {}

--- Finds the column for a hotkey, case-insensitively.
---@param label string The text to search within.
---@param key string The key character to find.
---@return integer|nil, integer|nil The start and end position of the key.
local function find_key_pos(label, key)
    return string.find(string.lower(label), string.lower(key), 1, true)
end

--- Generates the buffer lines, highlights, and dimensions for the menu.
---@param items table The list of menu items to render.
---@param config table The merged configuration table.
---@return table A layout object with { lines, highlights, dimensions, selectable_map }.
function M.generate(items, config)
    local lines, key_highlights, chord_highlights = {}, {}, {}
    local selectable_map = {}

    local selectable_items = {}
    for _, item in ipairs(items) do
        if item.label and not item.type then
            table.insert(selectable_items, item)
        end
    end

    if #selectable_items == 0 then
        return nil
    end

    local columns = math.max(1, config.columns)
    local col_gap = config.column_gap or 4
    local total_width = config.width
    local content_width = total_width - 2 -- For side padding
    local col_width = math.floor((content_width - (col_gap * (columns - 1))) / columns)
    local rows_needed = math.ceil(#selectable_items / columns)

    table.insert(lines, " ")

    for row = 1, rows_needed do
        local line_parts = {}
        local current_line_offset = 1 -- 0-indexed offset, starts after the buffer line's leading space

        for col = 1, columns do
            local idx = (col - 1) * rows_needed + row
            if idx <= #selectable_items then
                local item = selectable_items[idx]
                -- The start of the current cell is the current running offset
                local cell_start_col = current_line_offset

                selectable_map[idx] = {
                    item = item,
                    line_nr = #lines + 1,
                    column = col,
                    start_col = cell_start_col,
                    end_col = cell_start_col + col_width,
                }

                local chord_part = (item.chord and #item.chord > 0) and ("(" .. item.chord .. ")") or ""
                local display_text = chord_part .. item.label

                if vim.fn.strwidth(display_text) > col_width then
                    display_text = vim.fn.strcharpart(display_text, 0, col_width - 3) .. "..."
                end

                if item.key then
                    local key_start, _ = find_key_pos(item.label, item.key)
                    if key_start then
                        local start_pos = cell_start_col + #chord_part + key_start - 1
                        table.insert(key_highlights, { #lines, start_pos, start_pos + #item.key })
                    end
                end

                if #chord_part > 0 then
                    -- The chord highlight starts at the beginning of the cell
                    table.insert(chord_highlights, { #lines, cell_start_col, cell_start_col + #chord_part })
                end

                local padding = string.rep(" ", math.max(0, col_width - vim.fn.strwidth(display_text)))
                table.insert(line_parts, display_text .. padding)

                -- Update the running offset for the *next* column
                current_line_offset = current_line_offset + col_width + col_gap
            else
                table.insert(line_parts, string.rep(" ", col_width))
                -- Still need to update offset for empty cells
                current_line_offset = current_line_offset + col_width + col_gap
            end
        end
        table.insert(lines, " " .. table.concat(line_parts, string.rep(" ", col_gap)) .. " ")
    end

    table.insert(lines, " ")

    return {
        lines = lines,
        highlights = { key = key_highlights, chord = chord_highlights },
        dimensions = { width = total_width, height = #lines, rows = rows_needed, cols = columns },
        selectable_map = selectable_map,
    }
end

return M
