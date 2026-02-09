-- 置灰未使用代码（类似 JetBrains IDE）
return {
  {
    "zbirenbaum/neodim",
    event = "LspAttach",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("neodim").setup({
        alpha = 0.75, -- 置灰透明度（0.0 = 完全透明，1.0 = 不透明）
        hide = {
          underline = true, -- 隐藏下划线
          virtual_text = true, -- 隐藏虚拟文本
          signs = true, -- 隐藏 sign 栏图标
        },
      })
    end,
  },
}
