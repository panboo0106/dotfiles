-- =============================================================================
-- Solarized Zen - Neovim Colorscheme Configuration
-- =============================================================================
-- Colors matched to kitty solarized-zen theme for consistency
-- Dark mode:  kitty solarized-zen-dark.conf
-- Light mode: kitty solarized-zen-light.conf (Standard Solarized)
-- =============================================================================

return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- Use dark mode (can be toggled with :set background=light)
      style = "dark",

      -- Disable transparency
      transparent = false,

      -- Enable terminal colors
      terminal_colors = true,

      -- Style options
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },

      -- Sidebars
      sidebars = { "qf", "vista_kind", "terminal", "packer", "neo-tree", "Outline" },

      -- Custom colors - Match kitty solarized-zen theme
      on_colors = function(colors)
        -- Dark mode: Match kitty solarized-zen-dark.conf
        if vim.o.background == "dark" then
          colors.bg = "#00242c" -- kitty background
          colors.fg = "#839395" -- kitty foreground
          colors.bg_visual = "#002c38" -- kitty selection_background
          colors.bg_popup = "#002c38" -- kitty selection_background
          colors.bg_sidebar = "#002830" -- kitty tab_bar_background
          colors.bg_status = "#002830" -- kitty tab_bar_background

        -- Light mode: Match kitty solarized-zen-light.conf
        else
          colors.bg = "#fdf6e3" -- Standard Solarized Light
          colors.fg = "#657b83" -- Solarized base00
          colors.bg_visual = "#eee8d5" -- Solarized base2
          colors.bg_popup = "#eee8d5" -- Solarized base2
          colors.bg_sidebar = "#93a1a1" -- Solarized base1
          colors.bg_status = "#93a1a1" -- Solarized base1
        end
      end,

      -- Optional: Fine-tune specific highlights if needed
      on_highlights = function(hl, colors)
        if vim.o.background == "dark" then
          hl.CursorLine = { bg = "#002830" } -- kitty tab_bar_background
          hl.CursorLineNr = { fg = "#839395", bold = true }
        else
          hl.CursorLine = { bg = "#eee8d5" } -- Solarized base2
          hl.CursorLineNr = { fg = "#657b83", bold = true } -- Solarized base00
        end
      end,
    },
    config = function(_, opts)
      require("solarized-osaka").setup(opts)
      vim.cmd.colorscheme("solarized-osaka")
    end,
  },
}
