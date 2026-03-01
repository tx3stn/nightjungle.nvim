<!-- markdownlint-disable MD033 -->
<h1 align="center">nightjungle.nvim</h1>

<p align="center">
  <img src="docs/logo.svg" alt="nightjungle.nvim logo" width="220" />
</p>

<p align="center">
  <em>Dark & green with pops of color</em>
</p>

## Overview

`nightjungle.nvim` is a Neovim colorscheme with lots of green, dark backgrounds and pops of color.

Very much inspired by my use of [OneDarkPro](https://github.com/olimorris/onedarkpro.nvim) for
many years with some overriden base colors.

## Installation

### lazy.nvim

```lua
{
  "tx3stn/nightjungle.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nightjungle").setup()
    vim.cmd.colorscheme("nightjungle")
  end,
}
```

## Configuration

`setup()` accepts a single options table that allows you to enable/disable highlights for
specific filetypes or plugins. Example:

```lua
require("nightjungle").setup({
  caching = true,
  palette = {
    ["bg.default"] = "#0A1014",
    ["green.base"] = "#0A7A62",
  },
  highlights = {
    Comment = { fg = "fg.muted", italic = true },
    CursorLine = { bg = "bg.focus" },
  },
  plugins = {
    telescope = true,
    snacks = true,
    markview = true,
  },
  filetypes = {
    markdown = true,
    lua = true,
    typescript = true,
  },
  options = {
    transparency = false,
  },
})
```

### Key Options

- `caching` (`boolean`): Enables compiled cache loading.
- `palette` (`table`): Override existing palette tokens.
- `highlights` (`table`): Add or override highlight groups.
- `plugins` (`table<string, boolean>`): Enable/disable plugin highlight modules (leave empty to enable all defaults).
- `filetypes` (`table<string, boolean>`): Enable/disable filetype highlight modules (leave empty to enable all defaults).
- `options.transparency` (`boolean`): Use a transparent background.

### Overriding Highlights

Color values can be used directly in highlight definitions:

```lua
highlights = {
  NormalFloat = { fg = "fg.default", bg = "bg.dark" },
  DiagnosticUnderlineError = { sp = "diagnostic.error", undercurl = true },
  GitSignsAdd = { fg = "git.add" },
}
```

## Commands

`nightjungle.nvim` registers the following commands on load:

- `:NightJungleBGToggle` - toggles `options.transparency`, recompiles cache, and reloads the colorscheme.
- `:NightjungleColors` - opens a scratch buffer listing active palette tokens and values.
- `:NightjungleCache` - compiles and writes cache artifacts.
- `:NightjungleCacheClear` - clears cache artifacts.

## Cache Artifacts

With default settings, cache files are written under:

`~/.cache/nvim/nightjungle`

## Development

This repo contains a `.lazy.lua` file which will load the colorscheme and reload
on changes so you can see how your changes work.

`./examples/` contains a number of example files of different languages to preview
the color scheme.

> [!NOTE]
> You may need to clear the cache after making your changes with `:NightjungleCacheClear`

Loading just the color scheme:

```bash
nvim --clean -u NONE \
  -c "set rtp+=/absolute/path/to/nightjungle.nvim" \
  -c "colorscheme nightjungle"
```

## References

- [OneDarkPro](https://github.com/olimorris/onedarkpro.nvim) - an outstanding Neovim color scheme
project and a major inspiration (by which I mean source I copied directly from) for structure,
caching ideas, and extensible highlight organization.
