-- Mermaid diagram plugins
-- .mmd files: custom autocmd → mmdc → image.nvim (Kitty inline)
-- .md files:  diagram.nvim → image.nvim (Kitty inline)
-- Large/any:  kevalin/mermaid.nvim → browser preview

local chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
local puppeteer_cfg = vim.fn.expand("~/.config/nvim/puppeteer.config.json")
local NODE_LIMIT = 12 -- diagrams with more nodes → browser only

return {
  -- ── Markdown 内 ```mermaid 代码块：diagram.nvim ──────────────────
  {
    "3rd/diagram.nvim",
    enabled = not vim.g.vscode,
    dependencies = { "3rd/image.nvim" },
    ft = { "markdown" },
    config = function()
      require("diagram").setup({
        integrations = {
          require("diagram.integrations.markdown"),
        },
        events = {
          render_buffer = { "InsertLeave", "BufWinEnter", "BufWritePost" },
          clear_buffer = { "BufLeave" },
        },
        renderer_options = {
          mermaid = {
            background = "transparent",
            theme = "forest",
            scale = 1.5,
            cli_args = { "--puppeteerConfigFile", puppeteer_cfg },
          },
        },
      })
    end,
  },

  -- ── 独立 .mmd 文件 + 浏览器预览（合并为一个 spec 避免 lazy 合并问题）──
  {
    "kevalin/mermaid.nvim",
    enabled = not vim.g.vscode,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "mermaid", "markdown" },
    keys = {
      {
        "<leader>km",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local nodes = 0
          for _, line in ipairs(lines) do
            if line:match("%[.+%]") or line:match("{.+}") or line:match("%((.-)%)") then
              nodes = nodes + 1
            end
          end
          if nodes > NODE_LIMIT then
            vim.cmd("MermaidPreview")
            vim.notify("大图(" .. nodes .. "节点) → 浏览器预览", vim.log.levels.INFO)
          else
            vim.notify("小图(" .. nodes .. "节点) → Kitty 内嵌", vim.log.levels.INFO)
          end
        end,
        desc = "Mermaid: 智能预览",
      },
      { "<leader>kmo", "<cmd>MermaidPreview<cr>", desc = "Mermaid: 浏览器打开" },
      { "<leader>kmc", "<cmd>MermaidStop<cr>",    desc = "Mermaid: 关闭浏览器" },
    },
    opts = {
      preview = {
        theme = "forest",
        renderer = "mermaid",
      },
    },
    init = function()
      vim.filetype.add({ extension = { mmd = "mermaid" } })

      local group = vim.api.nvim_create_augroup("mermaid_render", { clear = true })
      local current_images = {}

      local function count_nodes(bufnr)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local count = 0
        for _, line in ipairs(lines) do
          if line:match("%[.+%]") or line:match("{.+}") or line:match("%((.-)%)") then
            count = count + 1
          end
        end
        return count
      end

      local function render_mmd(bufnr, force)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        local src = vim.api.nvim_buf_get_name(bufnr)
        if src == "" then return end

        if not force and count_nodes(bufnr) > NODE_LIMIT then
          vim.notify("[mermaid] 大图 → 用 <leader>kmo 在浏览器查看", vim.log.levels.INFO)
          return
        end

        local out = string.format("/tmp/mermaid_%d_%d.png", bufnr, os.time())
        local cmd = string.format(
          "PUPPETEER_EXECUTABLE_PATH='%s' mmdc -i '%s' -o '%s' -s 2 --puppeteerConfigFile '%s'",
          chrome, src, out, puppeteer_cfg
        )

        vim.fn.jobstart(cmd, {
          on_exit = function(_, code)
            if code ~= 0 then
              vim.notify("[mermaid] render failed (exit " .. code .. ")", vim.log.levels.WARN)
              return
            end
            vim.schedule(function()
              local ok, image = pcall(require, "image")
              if not ok then return end

              if current_images[bufnr] then
                pcall(function() current_images[bufnr]:clear() end)
                current_images[bufnr] = nil
              end

              local win = vim.fn.bufwinid(bufnr)
              if win == -1 then return end

              local img = image.from_file(out, {
                buffer = bufnr,
                window = win,
                col = 0,
                row = vim.api.nvim_buf_line_count(bufnr),
                with_virtual_padding = true,
                inline = true,
                max_width_window_percentage = 75,
                max_height_window_percentage = 65,
              })
              if img then
                img:render()
                current_images[bufnr] = img
              end
            end)
          end,
        })
      end

      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost" }, {
        group = group,
        pattern = "*.mmd",
        callback = function(ev) render_mmd(ev.buf, false) end,
      })

      vim.api.nvim_create_autocmd("BufLeave", {
        group = group,
        pattern = "*.mmd",
        callback = function(ev)
          local bufnr = ev.buf
          if current_images[bufnr] then
            pcall(function() current_images[bufnr]:clear() end)
            current_images[bufnr] = nil
          end
        end,
      })

      vim.keymap.set("n", "<leader>kr", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].filetype ~= "mermaid" then return end
        render_mmd(bufnr, true)
        vim.notify("[mermaid] 强制重新渲染...", vim.log.levels.INFO)
      end, { desc = "Mermaid: 强制重新渲染" })

      vim.keymap.set("n", "<leader>ks", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].filetype ~= "mermaid" then return end
        local src = vim.api.nvim_buf_get_name(bufnr)
        local out = src:gsub("%.mmd$", ".svg")
        local cmd = string.format(
          "PUPPETEER_EXECUTABLE_PATH='%s' mmdc -i '%s' -o '%s' --puppeteerConfigFile '%s'",
          chrome, src, out, puppeteer_cfg
        )
        vim.fn.jobstart(cmd, {
          on_exit = function(_, code)
            if code == 0 then
              vim.notify("[mermaid] SVG 已导出: " .. out, vim.log.levels.INFO)
            else
              vim.notify("[mermaid] SVG 导出失败", vim.log.levels.ERROR)
            end
          end,
        })
      end, { desc = "Mermaid: 导出 SVG" })
    end,
  },
}
