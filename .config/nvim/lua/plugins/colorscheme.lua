-- =============================================================================
-- Solarized Zen - Neovim Colorscheme
-- =============================================================================
-- All colors sourced from lua/config/palette.lua
-- Matches kitty/solarized-zen-{dark,light}.conf
-- =============================================================================

local function p()
  return require("config.palette")[vim.o.background == "light" and "light" or "dark"]
end

return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "dark",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments  = { italic = true },
        keywords  = { italic = true },
        functions = {},
        variables = {},
        sidebars  = "transparent",
        floats    = "transparent",
      },
      sidebars = { "qf", "vista_kind", "terminal", "Outline", "snacks_layout_box" },

      on_colors = function(colors)
        local c = p()
        colors.bg         = c.bg
        colors.fg         = c.fg
        colors.bg_visual  = c.bg2
        colors.bg_popup   = c.bg2
        colors.bg_sidebar = c.bg1
        colors.bg_status  = c.bg1
      end,

      on_highlights = function(hl, _)
        local c = p()
        local is_dark = vim.o.background == "dark"

        -- Shared
        hl.CursorLine   = { bg = c.bg4 }
        hl.CursorLineNr = { fg = c.fg,  bold = true }
        hl.LineNr       = { fg = c.fg2 }
        hl.Comment      = { fg = c.fg2, italic = true }

        -- Syntax
        hl.Keyword    = { fg = is_dark and c.cyan or c.blue, italic = true }
        hl.Function   = { fg = is_dark and c.blue or c.cyan }
        hl.String     = { fg = c.green }
        hl.Number     = { fg = c.magenta }
        hl.Type       = { fg = c.yellow }
        hl.Constant   = { fg = c.orange }
        hl.Identifier = { fg = c.fg }
        hl.Statement  = { fg = is_dark and c.cyan or c.blue }
        hl.PreProc    = { fg = c.magenta }
        hl.Special    = { fg = c.cyan }

        -- UI
        hl.Visual     = { bg = c.bg5 }
        hl.VisualNOS  = { bg = c.bg5 }
        hl.Search     = { bg = c.bg2,    fg = c.fg }
        hl.IncSearch  = { bg = c.yellow, fg = is_dark and c.bg or c.fg_max }
        hl.MatchParen = { bg = c.fg3,    fg = c.fg }
        hl.Underlined = { fg = c.blue,   underline = true }
        hl.Error      = { fg = c.red,    bold = true }
        hl.Todo       = { fg = c.magenta, bold = true }
        hl.WarningMsg = { fg = c.yellow }
        hl.ErrorMsg   = { fg = c.red }
        hl.Question   = { fg = c.cyan }
        hl.ModeMsg    = { fg = c.fg }
        hl.MoreMsg    = { fg = c.cyan }

        -- LSP references
        hl.LspReferenceText  = { bg = c.lsp_ref }
        hl.LspReferenceRead  = { bg = c.lsp_ref }
        hl.LspReferenceWrite = { bg = c.lsp_ref_write }

        -- render-markdown headings (low-saturation bg + solarized fg)
        hl.RenderMarkdownH1   = { fg = c.br_blue,  bold = true }
        hl.RenderMarkdownH2   = { fg = c.blue,    bold = true }
        hl.RenderMarkdownH3   = { fg = c.br_cyan,  bold = true }
        hl.RenderMarkdownH4   = { fg = c.cyan,    bold = true }
        hl.RenderMarkdownH5   = { fg = c.fg,      bold = true }
        hl.RenderMarkdownH6   = { fg = c.fg2,     bold = true }
        hl.RenderMarkdownH1Bg = { bg = is_dark and "#0f2e52" or "#c8dff5" }
        hl.RenderMarkdownH2Bg = { bg = is_dark and "#0b2644" or "#d2e6f7" }
        hl.RenderMarkdownH3Bg = { bg = is_dark and "#081e38" or "#daedf8" }
        hl.RenderMarkdownH4Bg = { bg = is_dark and "#05182e" or "#e2f1fa" }
        hl.RenderMarkdownH5Bg = { bg = is_dark and "#031228" or "#eaf5fc" }
        hl.RenderMarkdownH6Bg = { bg = is_dark and "#020e20" or "#f2f8fd" }
      end,
    },

    config = function(_, opts)
      require("solarized-osaka").setup(opts)
      vim.cmd.colorscheme("solarized-osaka")

      vim.api.nvim_create_user_command("ToggleSolarized", function()
        vim.o.background = vim.o.background == "dark" and "light" or "dark"
        vim.notify("Background: " .. vim.o.background, vim.log.levels.INFO)
      end, {})
    end,
  },

}
