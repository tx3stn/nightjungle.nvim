# Nightjungle Markdown Showcase

This file is a visual and syntax sample for `nightjungle.nvim`.

---

## Quick Start

Load the theme in a minimal setup:

```lua
vim.cmd.colorscheme("nightjungle")
```

Or configure before loading:

```lua
require("nightjungle").setup({
  palette = {
    ["green.base"] = "#0A7A62",
    ["bg.default"] = "#0A1014",
  },
  highlights = {
    Comment = { fg = "fg.muted", italic = true },
    Visual = { bg = "bg.selected" },
  },
  plugins = {
    telescope = true,
    snacks = true,
  },
  filetypes = {
    markdown = true,
    lua = true,
  },
})
```

> Tip: palette tokens can be used in `fg`, `bg`, and `sp` keys.

## Palette Tokens

| Token | Role | Example |
| --- | --- | --- |
| `bg.default` | Main editor background | `#0e1216` |
| `bg.focus` | Focused areas (line, panel) | `#0C0F13` |
| `fg.default` | Primary foreground text | `#A4ACB8` |
| `fg.muted` | Comments and secondary text | `#778489` |
| `green.base` | Brand/action accent | `#005869` |
| `blue.base` | Links/info accents | `#61AFEF` |

### Diagnostic + Git Tokens

| Category | Token | Typical Group |
| --- | --- | --- |
| Diagnostic | `diagnostic.error` | `DiagnosticError` |
| Diagnostic | `diagnostic.warn` | `DiagnosticWarn` |
| Git | `git.add` | `GitSignsAdd` |
| Git | `git.change` | `GitSignsChange` |
| Git | `git.delete` | `GitSignsDelete` |

## Highlight Override Examples

### Core UI

```lua
highlights = {
  Normal = { fg = "fg.default", bg = "bg.default" },
  FloatBorder = { fg = "bg.dark", bg = "bg.dark" },
  CursorLine = { bg = "bg.focus" },
}
```

### Plugin Highlights

```lua
highlights = {
  TelescopePromptTitle = { fg = "bg.focus", bg = "green.base" },
  MarkviewHeading1 = { fg = "green.base", bold = true },
  NeoTreeDirectoryName = { fg = "cyan.base" },
}
```

### Style Flags

| Flag | Meaning |
| --- | --- |
| `bold` | Strong emphasis |
| `italic` | Comment/text style |
| `underline` | Underlined text |
| `undercurl` | Curly underline (diagnostics) |
| `strikethrough` | Removed/deprecated text |

## Example Markdown Content

### Jungle Notes

- Canopy layers create depth.
- Moonlight reads as `fg.default` on `bg.default`.
- Accent hues should stay restrained.

#### Checklist

- [x] Core highlights loaded
- [x] Plugin highlights loaded
- [ ] Fine-tune markdown headings

#### Code Block

```bash
nvim --clean -u NONE \
  -c "set rtp+=/Users/tristan/git/nightjungle.nvim" \
  -c "colorscheme nightjungle"
```

#### Quote

> Nightjungle is tuned for contrast without glare.

---

## Reference

| Area | Path |
| --- | --- |
| Core highlights | `lua/nightjungle/highlights/core/` |
| Plugin highlights | `lua/nightjungle/highlights/plugins/` |
| Filetype highlights | `lua/nightjungle/highlights/filetypes/` |
| Palette | `lua/nightjungle/palette.lua` |
