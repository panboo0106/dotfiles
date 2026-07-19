return {
  -- 禁用 LazyVim 默认的 nvim-cmp，使用 blink.cmp
  { "hrsh7th/nvim-cmp", enabled = false },
  -- 禁用 LazyVim 默认的 mini.pairs，避免加载时的 Snacks.toggle() 错误
  { "nvim-mini/mini.pairs", enabled = false },
  -- 自定义 mini.pairs 配置（不依赖 Snacks.toggle）
  {
    "nvim-mini/mini.pairs",
    event = "VeryLazy",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
    config = function(_, opts)
      local pairs = require("mini.pairs")
      pairs.setup(opts)
      -- Override open function for markdown code blocks (from LazyVim)
      local open = pairs.open
      pairs.open = function(pair, neigh_pattern)
        if vim.fn.getcmdline() ~= "" then
          return open(pair, neigh_pattern)
        end
        local o, c = pair:sub(1, 1), pair:sub(2, 2)
        local line = vim.api.nvim_get_current_line()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local next = line:sub(cursor[2] + 1, cursor[2] + 1)
        local before = line:sub(1, cursor[2])
        if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
          return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
        end
        if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
          return o
        end
        if opts.skip_ts and #opts.skip_ts > 0 then
          local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
          for _, capture in ipairs(ok and captures or {}) do
            if vim.tbl_contains(opts.skip_ts, capture.capture) then
              return o
            end
          end
        end
        if opts.skip_unbalanced and next == c and c ~= o then
          local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
          local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
          if count_close > count_open then
            return o
          end
        end
        return open(pair, neigh_pattern)
      end
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*" },
    },
    opts = {
      snippets = {
        preset = "luasnip",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust" },
      keymap = {
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            end
          end,
          function()
            local luasnip = require("luasnip")
            if luasnip.locally_jumpable(1) then
              luasnip.jump(1)
              return true
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          function()
            local luasnip = require("luasnip")
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
              return true
            end
          end,
          "fallback",
        },
      },
    },
  },
  {
    "kawre/neotab.nvim",
    event = "InsertEnter",
    opts = {
      act_as_tab = true,
    },
  },
  {
    "nvim-neotest/neotest",
    -- stylua: ignore
    keys = {
      -- unbind all 11 of the extra's own lowercase <leader>t* defaults (collide with terminal
      -- keys in keymaps.lua). lazy.nvim's `keys` merge dedups by EXACT lhs string, not by
      -- prefix, so the group marker alone does not shadow its children — each lhs needs its
      -- own `false` entry.
      { "<leader>t",  false },
      { "<leader>ta", false },
      { "<leader>tt", false },
      { "<leader>tT", false },
      { "<leader>tr", false },
      { "<leader>tl", false },
      { "<leader>ts", false },
      { "<leader>to", false },
      { "<leader>tO", false },
      { "<leader>tS", false },
      { "<leader>tw", false },
      { "<leader>T",  "", desc = "+test" },
      { "<leader>Ta", function() require("neotest").run.attach() end, desc = "Attach to Test (Neotest)" },
      { "<leader>Tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File (Neotest)" },
      { "<leader>TT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files (Neotest)" },
      { "<leader>Tr", function() require("neotest").run.run() end, desc = "Run Nearest (Neotest)" },
      { "<leader>Tl", function() require("neotest").run.run_last() end, desc = "Run Last (Neotest)" },
      { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary (Neotest)" },
      { "<leader>To", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output (Neotest)" },
      { "<leader>TO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel (Neotest)" },
      { "<leader>TS", function() require("neotest").run.stop() end, desc = "Stop (Neotest)" },
      { "<leader>Tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch (Neotest)" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    -- stylua: ignore
    keys = {
      { "<leader>td", false }, -- unbind extra's default (collides with terminal keys)
      { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest (Neotest)" },
    },
  },
  {
    "gbprod/yanky.nvim",
    recommended = true,
    desc = "Better Yank/Paste",
    event = "LazyFile",
    opts = {
      system_clipboard = {
        sync_with_ring = not vim.env.SSH_CONNECTION,
      },
      highlight = { timer = 150 },
    },
    keys = {
      {
        "<leader>p",
        function()
          Snacks.picker.yanky()
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
        -- stylua: ignore
    { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put Text After Selection" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Selection" },
      { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
      { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
      { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
      { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
      { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
      { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
      { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and Indent Right" },
      { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and Indent Left" },
      { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put Before and Indent Right" },
      { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put Before and Indent Left" },
      { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
    },
  },
  {
    "danymat/neogen",
    cmd = "Neogen",
    keys = {
      {
        "<leader>cn",
        function()
          require("neogen").generate()
        end,
        desc = "Generate Annotations",
      },
    },
    opts = {
      snippet_engine = "luasnip",
    },
  },

  {
    "andythigpen/nvim-coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide", "CoverageToggle", "CoverageSummary" },
    keys = {
      { "<leader>TC", "<cmd>CoverageToggle<cr>", desc = "Coverage Toggle" },
      { "<leader>TV", "<cmd>CoverageSummary<cr>", desc = "Coverage Summary" },
      { "<leader>TL", "<cmd>CoverageLoad<cr>", desc = "Coverage Load" },
    },
    opts = {
      auto_reload = true,
      lang = {
        python = { coverage_file = ".coverage" },
        go = { coverage_file = "coverage.out" },
      },
    },
  },
}
