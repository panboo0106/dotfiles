return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    -- 添加全局选项
    format_on_save = {
      timeout_ms = 1000,
      lsp_fallback = true,
    },
    -- 添加格式化失败处理
    notify_on_error = true,

    formatters_by_ft = {
      -- Shell 脚本
      bash = { "shfmt" },
      sh = { "shfmt" },

      -- Lua
      lua = { "stylua" },

      -- Go 语言（保持顺序，先导入整理后格式化）
      go = { "goimports", "gofumpt", "goimports-reviser" },

      -- Web 开发（添加备选格式化工具）
      javascript = { { "prettier" }, { "prettierd" }, { "eslint_d" } },
      typescript = { { "prettier" }, { "prettierd" }, { "eslint_d" } },
      javascriptreact = { { "prettier" }, { "prettierd" } },
      typescriptreact = { { "prettier" }, { "prettierd" } },
      vue = { { "prettier" }, { "prettierd" } },

      -- 样式文件
      css = { { "prettier" }, { "prettierd" } },
      scss = { { "prettier" }, { "prettierd" } },
      less = { { "prettier" }, { "prettierd" } },

      -- 标记语言
      html = { { "prettier" }, { "prettierd" } },
      json = { { "prettier" }, { "prettierd" }, { "jq" } },
      jsonc = { { "prettier" }, { "prettierd" }, { "jq" } },
      yaml = { { "prettier" }, { "prettierd" }, { "yamlfmt" } },
      markdown = { { "prettier" }, { "prettierd" } },
      ["markdown.mdx"] = { { "prettier" }, { "prettierd" } },
      graphql = { { "prettier" }, { "prettierd" } },
      handlebars = { { "prettier" } },

      -- 系统编程语言
      rust = { { "rustfmt" } },
      c = { "clang_format" },
      cpp = { "clang_format" },

      -- Python - 优化逻辑，保持您的条件判断
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format" }
        else
          return { "isort", "black" }
        end
      end,

      -- 新增文件类型
      toml = { "taplo" },
      xml = { "xmlformat" },
      sql = { "sqlfmt" },
      proto = { "buf" },
    },

    -- 添加一些格式化工具的特定配置
    formatters = {
      shfmt = {
        args = { "-i", "2", "-ci" }, -- 使用 2 空格缩进
      },
      prettier = {
        args = { "--print-width", "100", "--single-quote" },
      },
      black = {
        args = { "--line-length", "88" },
      },
    },
  },
}
