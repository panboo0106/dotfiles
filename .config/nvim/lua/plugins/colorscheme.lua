return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    priority = 1000,
    opts = function()
      return {
        transparent = false,
        on_highlights = function(hl, c)
          hl.Title = { fg = c.blue, bold = true }
        end,
        on_colors = function(colors)
          colors.error = "#ff0000"
          colors.bg = "#001419"
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
