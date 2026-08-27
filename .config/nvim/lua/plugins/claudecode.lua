-- Claude Code 接入：nvim 起一个 WebSocket server，实现的是官方 VS Code/JetBrains 扩展同款协议。
-- 主力用法 —— ghostty 里照常跑 claude，在里面敲 /ide 连上本 server：
--   选区自动进 context、诊断经 mcp__ide__getDiagnostics 回喂、Claude 的改动回到 nvim 里原生 diff 审批。
-- 用 VeryLazy 而不是 cmd 懒加载：server 得先起来（auto_start 默认 true，会写 ~/.claude/ide/<port>.lock），
-- 外部 claude 才连得上；cmd 懒加载会等到手敲命令才起，/ide 就找不到端口。

return {
  -- ── claudecode.nvim: Claude Code ↔ nvim 桥 ────────────────────
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy",
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude: 切换终端" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: 聚焦终端" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: 恢复会话" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: 当前 buffer 进 context" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: 发送选区" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: 接受改动" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: 拒绝改动" },
      { "<leader>aS", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude: server 状态" },
    },
    opts = {}, -- 默认值够用；terminal_cmd 留 nil 走 PATH 上的 claude
  },

  -- ── Which-Key 分组注册 ────────────────────────────────────────
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "Claude", icon = { icon = "󰚩", color = "orange" } },
      },
    },
  },
}
