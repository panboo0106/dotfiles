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
      local states, windows = {}, {}
      local bindings = {
        { "n", "J", "<C-v>j:VBox<CR>", "下画线" },
        { "n", "K", "<C-v>k:VBox<CR>", "上画线" },
        { "n", "L", "<C-v>l:VBox<CR>", "右画线" },
        { "n", "H", "<C-v>h:VBox<CR>", "左画线" },
        { "x", "f", ":VBox<CR>", "画框" },
      }
      local function restore_window(win)
        if windows[win] and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_set_option_value("virtualedit", windows[win].previous, { win = win })
        end
        windows[win] = nil
      end
      local function sync_window(win)
        local buf = vim.api.nvim_win_get_buf(win)
        if windows[win] and (windows[win].buf ~= buf or not states[buf]) then
          restore_window(win)
        end
        if states[buf] and not windows[win] then
          local previous = vim.api.nvim_get_option_value("virtualedit", { win = win })
          -- A split inherits the drawing window's option; recover its original value.
          if previous == "all" then
            for other, saved in pairs(windows) do
              if other ~= win and saved.buf == buf then
                previous = saved.previous
                break
              end
            end
          end
          windows[win] = { buf = buf, previous = previous }
          vim.api.nvim_set_option_value("virtualedit", "all", { win = win })
        end
      end
      local function toggle_venn()
        local buf = vim.api.nvim_get_current_buf()
        local state = states[buf]
        if not state then
          state = { maps = {} }
          states[buf] = state
          for _, binding in ipairs(bindings) do
            local mode, key, rhs, desc = unpack(binding)
            local old = vim.fn.maparg(key, mode, false, true)
            state.maps[#state.maps + 1] = old.buffer == 1 and old or false
            vim.keymap.set(mode, key, rhs, { buffer = buf, desc = "Venn: " .. desc })
          end
          vim.notify("[venn] 绘图模式 ON", vim.log.levels.INFO)
        else
          for i, binding in ipairs(bindings) do
            pcall(vim.keymap.del, binding[1], binding[2], { buffer = buf })
            if state.maps[i] then
              vim.fn.mapset(binding[1], false, state.maps[i])
            end
          end
          states[buf] = nil
          vim.notify("[venn] 绘图模式 OFF", vim.log.levels.INFO)
        end
        for _, win in ipairs(vim.fn.win_findbuf(buf)) do
          sync_window(win)
        end
      end
      local group = vim.api.nvim_create_augroup("venn_state", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
        group = group,
        callback = function()
          sync_window(vim.api.nvim_get_current_win())
        end,
      })
      vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, {
        group = group,
        callback = function(ev)
          local win = vim.api.nvim_get_current_win()
          if windows[win] and windows[win].buf == ev.buf then
            restore_window(win)
          end
        end,
      })
      vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        callback = function(ev)
          windows[tonumber(ev.match)] = nil
        end,
      })
      vim.api.nvim_create_autocmd("BufWipeout", {
        group = group,
        callback = function(ev)
          states[ev.buf] = nil
          for win, saved in pairs(windows) do
            if saved.buf == ev.buf then
              restore_window(win)
            end
          end
        end,
      })

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
