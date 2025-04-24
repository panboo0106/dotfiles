return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    priority = 1000,
    opts = function()
      return {
        transparent = false,
        terminal_colors = false,
        on_highlights = function(hl, c)
          hl.Title = { fg = c.blue, bold = true }
        end,
        on_colors = function(colors)
          colors.error = "#ff0000"
          colors.bg = "#001e26"
          -- colors.bg = "#00313A"
        end,
        sidebars = { "qf", "vista_kind", "terminal", "packer" },
        styles = {
          keywords = { italic = true },
          sidebars = "transparent",
          floats = "transparent",
        },
      }
    end,
  },
}
