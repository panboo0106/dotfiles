return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    -- 添加全局选项
    -- 添加格式化失败处理
    notify_on_error = true,
    formatters_by_ft = {
      -- Shell 脚本
      bash = { "shfmt" },
      sh = { "shfmt" },

      -- Lua
      lua = { "stylua" },

      -- Go 语言（保持顺序，先导入整理后格式化）
      go = { "goimports", "gofumpt" },

      -- Web 开发（prettierd 主、prettier 兜底：stop_after_first 只跑第一个可用的，
      -- 避免两者都装时重复格式化、保存延迟翻倍）
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      vue = { "prettierd", "prettier", stop_after_first = true },

      -- 样式文件
      css = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
      less = { "prettierd", "prettier", stop_after_first = true },

      -- 标记语言
      html = { "prettierd", "prettier", stop_after_first = true },
      -- json/jsonc：stop_after_first 让 prettier 之后不再跑 jq——jq 无法解析带注释的
      -- jsonc（tsconfig 等），否则每次保存必失败并弹 notify_on_error。
      json = { "prettierd", "prettier", "jq", stop_after_first = true },
      jsonc = { "prettierd", "prettier", "jq", stop_after_first = true },
      yaml = { "yamlfmt" },
      -- markdown 保持串行：prettier 格式化 → markdownlint-cli2 修复 → markdown-toc 更新目录，
      -- 三者各司其职，不能 stop_after_first。
      markdown = { "prettierd", "prettier", "markdownlint-cli2", "markdown-toc" },
      ["markdown.mdx"] = { "prettierd", "prettier", "markdownlint-cli2", "markdown-toc" },
      graphql = { "prettierd", "prettier", stop_after_first = true },
      handlebars = { "prettierd", "prettier", stop_after_first = true },

      -- 系统编程语言
      rust = { "rustfmt" },
      c = { "clang_format" },
      cpp = { "clang_format" },

      -- Python - 优化逻辑，保持您的条件判断
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_organize_imports", "ruff_format" }
        else
          return { "isort", "black" }
        end
      end,

      -- 新增文件类型
      toml = { "taplo" },
      xml = { "prettier" },
      sql = { "sql_formatter" },
      proto = { "buf" },
    },

    -- 添加一些格式化工具的特定配置
    formatters = {
      shfmt = {
        args = { "-i", "2", "-ci" }, -- 使用 2 空格缩进
      },
      black = {
        args = { "--line-length", "88" },
      },
      yamlfmt = {
        command = "yamlfmt",
        args = {
          "-formatter",
          "indent=2,include_document_start=false,line_ending=lf,pad_line_comments=0,retain_line_breaks=true,retain_line_breaks_single=true,disallow_quotes=false,allow_flow_style=true,indentless_arrays=false,scan_folded_lines_as_literal=true",
          "-",
        },
        stdin = true,
      },
    },
  },
}
