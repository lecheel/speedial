# Speedial.nvim

A lightweight and customizable speed-dial menu plugin for Neovim (Lua).  
Quickly access your favorite actions, commands, or functions with a clean, minimal interface.

---

## ✨ Features

- **Floating Menu**: Opens near the cursor or centered on screen.
- **Multi-column Layout**: Configurable grid layout with gap control.
- **Hotkey Highlighting**: Visual emphasis on configured key letters.
- **Chord Support**: Trigger items using custom key chords.
- **Selection Navigation**: Move with arrow keys and confirm with `<CR>`.
- **Automatic Cleanup**: Closes on window leave or escape.
- **Customizable UI**: Define highlight groups and appearance.

---


## 🔧 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return
{
    "lecheel/speedial.nvim",
    config = function()
        require("speedial").setup({
            position = "cursor", -- or "center"
            width = 70,
            columns = 2,
            column_gap = 4,
            border = "none", -- or "single", "rounded", etc.
            bg_hl = "SpeedialNormal",
            border_hl = "SpeedialBorder",
            key_hl = "SpeedialKey",
            chord_hl = "SpeedialChord",
            selected_hl = "SpeedialSelected",
        })
    end
}
```

---

## 🚀 Usage

### Add Menu Items

After setup, register items using `require("speedial").add()`:

```lua
local speedial = require("speedial")

speedial.add({
    label = "Open Telescope",
    key = "T",
    action = "Telescope find_files",
    chord = "<C-t>"
})

speedial.add({
    label = "Toggle NERDTree",
    key = "n",
    action = "NERDTreeToggle",
    chord = "<C-n>"
})

speedial.add({
    label = "Save All",
    key = "s",
    action = "wa",
    chord = "<C-s>"
})
```

### Open the Menu

Bind a key to open the menu:

```lua
vim.keymap.set("n", "<F12>", function()
    require("speedial").open()
end, { desc = "Open speed dial" })
```

Or call manually via `:lua require('speedial').open()`.

---

## ⚙️ Configuration Options

| Option         | Default       | Description |
|----------------|---------------|-------------|
| `position`     | `"cursor"`    | Where to place the popup: `"cursor"` or `"center"` |
| `border`       | `"none"`      | Border style (`"single"`, `"double"`, `"rounded"`, etc.) |
| `width`        | `60`          | Total width of the floating window |
| `columns`      | `2`           | Number of columns in the grid |
| `column_gap`   | `4`           | Space between columns |
| `items`        | `{}`          | List of initial menu items (rarely set directly) |

> Use `require("speedial").setup({ ... })` to override defaults.

---

## 🗂️ Item Structure

Each item is a table:

```lua
{
    label = "Visible Text",       -- Required
    key = "k",                    -- Optional: letter to highlight
    chord = "<k>",                -- Optional: direct keybinding
    action = "command" | function() ... end, -- What to run when selected
}
```

Example:
```lua
{
    label = "New File",
    key = "N",
    chord = "<n>",
    action = function()
        vim.cmd("enew")
    end
}
```

---

## 🔄 Behavior

- Press `<Esc>` or click outside to close.
- Navigate with arrow keys (`<Up>`, `<Down>`, `<Left>`, `<Right>`).
- Confirm selection with `<CR>`.
- Any registered `chord` acts as a direct trigger.
- If already open, calling `open()` again closes it (toggle behavior).

---

## 📄 License

MIT — See `LICENSE` file.

---

