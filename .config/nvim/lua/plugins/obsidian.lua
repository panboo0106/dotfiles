-- Obsidian 工作流：跳转/反链/补全走 markdown-oxide LSP（见 lsp.lua），
-- 此插件只提供 Obsidian 特有的 UX 命令（模板、daily notes、frontmatter、followlink 等）。
return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "leo-notebook",
          path = "/Users/panboozhu/leo-GoogleDrive/My Drive/Note/leo-notebook",
        },
      },
      completion = {
        min_chars = 2,
      },
      ui = { enable = false }, -- 避免和 render-markdown/treesitter 渲染冲突
    },
  },
}
