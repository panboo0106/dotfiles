return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    priority = 1000,
    opts = function()
      return {
        transparent = false,
        on_colors = function(colors)
          colors.hint = colors.orange
          colors.error = "#ff0000"
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
