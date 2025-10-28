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
          -- 增强加粗文本可见度
          hl.Bold = { fg = "#b5cace", bold = true }
          hl["@text.strong"] = { fg = "#b5cace", bold = true }
          hl["@markup.strong"] = { fg = "#b5cace", bold = true }
          hl.markdownBold = { fg = "#b5cace", bold = true }
          hl.htmlBold = { fg = "#b5cace", bold = true }
        end,
        on_colors = function(colors)
          colors.error = "#ff0000"
          colors.bg = "#001e26"
          -- 提亮普通文本
          colors.fg = "#9eb0b2"
          -- 注释颜色
          colors.comment = "#637981"
          -- 代码高亮使用更亮的青色
          colors.cyan = "#3dc9bd"
          colors.teal = "#3dc9bd"
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
