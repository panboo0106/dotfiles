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
          path = function()
            local path = vim.env.NOTEBOOK_PATH
            if path and path ~= "" then
              return vim.fs.normalize(vim.fn.expand(path))
            end
            return vim.fn.expand("~/Library/CloudStorage/GoogleDrive-leo.minorui@gmail.com/My Drive/Note/leo-notebook")
          end,
        },
      },
      -- completion.min_chars 已删：那是 cmp 集成的参数，blink.cmp 下无效，
      -- wikilink 补全由 markdown-oxide LSP 提供（见文件头注释）。
      ui = { enable = false }, -- 避免和 render-markdown/treesitter 渲染冲突
    },
  },
}
