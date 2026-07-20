-- Mindmap & ASCII diagram plugins
-- markmap: Markdown → interactive mind map in browser
-- venn.nvim: ASCII box/line drawing in Neovim

return {
  -- ── Markmap: Markdown 思维导图（浏览器预览）─────────────────────
  {
    "Zeioth/markmap.nvim",
    build = "npm install --prefix ~/.local/share/nvim/markmap markmap-cli",
    cmd = { "MarkmapOpen", "MarkmapSave", "MarkmapWatch", "MarkmapWatchStop" },
    ft = { "markdown" },
    keys = {
      { "<leader>kMo", "<cmd>MarkmapOpen<cr>", desc = "Markmap: 浏览器打开" },
      { "<leader>kMw", "<cmd>MarkmapWatch<cr>", desc = "Markmap: 实时预览" },
      { "<leader>kMs", "<cmd>MarkmapWatchStop<cr>", desc = "Markmap: 停止预览" },
      { "<leader>kMe", "<cmd>MarkmapSave<cr>", desc = "Markmap: 导出 HTML" },
    },
    opts = {
      html_output = "/tmp/markmap.html",
      hide_toolbar = false,
      grace_period = 3600000, -- keep server alive (ms)
      markmap_cmd = vim.fn.expand("~/.local/share/nvim/markmap/node_modules/.bin/markmap"),
    },
  },

  -- ── venn.nvim: ASCII 框图绘制 ─────────────────────────────────
  {
    "jbyuki/venn.nvim",
    keys = {
      { "<leader>kv", desc = "Venn: 切换绘图模式" },
    },
    config = function()
      local venn_enabled = false

      local function toggle_venn()
        venn_enabled = not venn_enabled
        if venn_enabled then
          vim.opt_local.virtualedit = "all"
          -- 方向键画线
          vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", { noremap = true, desc = "Venn: 下画线" })
          vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", { noremap = true, desc = "Venn: 上画线" })
          vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", { noremap = true, desc = "Venn: 右画线" })
          vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", { noremap = true, desc = "Venn: 左画线" })
          -- Visual 模式画框
          vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", { noremap = true, desc = "Venn: 画框" })
          vim.notify("[venn] 绘图模式 ON  |  HJKL=画线  Visual+f=画框", vim.log.levels.INFO)
        else
          vim.opt_local.virtualedit = ""
          pcall(vim.api.nvim_buf_del_keymap, 0, "n", "J")
          pcall(vim.api.nvim_buf_del_keymap, 0, "n", "K")
          pcall(vim.api.nvim_buf_del_keymap, 0, "n", "L")
          pcall(vim.api.nvim_buf_del_keymap, 0, "n", "H")
          pcall(vim.api.nvim_buf_del_keymap, 0, "v", "f")
          vim.notify("[venn] 绘图模式 OFF", vim.log.levels.INFO)
        end
      end

      vim.keymap.set("n", "<leader>kv", toggle_venn, { desc = "Venn: 切换绘图模式" })
    end,
  },

  -- ── Which-Key 分组注册 ────────────────────────────────────────
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>kM", group = "Markmap", icon = { icon = "󰙅", color = "purple" } },
        { "<leader>kv", icon = { icon = "󰏫", color = "blue" } },
      },
    },
  },
}
