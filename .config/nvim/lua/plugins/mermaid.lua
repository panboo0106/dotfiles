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
    cond = function()
      return require("config.util").supports_kitty_images()
    end,
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
          if nodes > NODE_LIMIT or not require("config.util").supports_kitty_images() then
            vim.cmd("MermaidPreview")
            vim.notify("[mermaid] 浏览器预览 (" .. nodes .. "节点)", vim.log.levels.INFO)
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
      local current_images, image_paths, jobs, generations, outputs = {}, {}, {}, {}, {}

      local function clear_image(bufnr)
        if current_images[bufnr] then
          local ok = pcall(function()
            current_images[bufnr]:clear()
          end)
          if not ok then
            return false
          end
          current_images[bufnr] = nil
        end
        if image_paths[bufnr] then
          vim.fn.delete(image_paths[bufnr])
          image_paths[bufnr] = nil
        end
        return true
      end

      local function cancel_render(bufnr)
        generations[bufnr] = (generations[bufnr] or 0) + 1
        if jobs[bufnr] then
          vim.fn.jobstop(jobs[bufnr])
          jobs[bufnr] = nil
        end
      end

      local function count_nodes(bufnr)
        local count = 0
        for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
          if line:match("%[.+%]") or line:match("{.+}") or line:match("%((.-)%)") then
            count = count + 1
          end
        end
        return count
      end

      local function render_mmd(bufnr, force)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        cancel_render(bufnr)
        if not require("config.util").supports_kitty_images() then
          return
        end
        local src = vim.api.nvim_buf_get_name(bufnr)
        if src == "" then
          return
        end
        if not force and count_nodes(bufnr) > NODE_LIMIT then
          clear_image(bufnr)
          vim.notify("[mermaid] 大图 → 用 <leader>kmo 在浏览器查看", vim.log.levels.INFO)
          return
        end

        local generation = generations[bufnr]
        local out = vim.fn.tempname() .. ".png"
        outputs[out] = true
        local job = vim.fn.jobstart({
          "mmdc",
          "-i",
          src,
          "-o",
          out,
          "-s",
          "2",
          "--puppeteerConfigFile",
          puppeteer_cfg,
        }, {
          env = { PUPPETEER_EXECUTABLE_PATH = chrome },
          on_exit = function(_, code)
            vim.schedule(function()
              outputs[out] = nil
              if generations[bufnr] ~= generation or not vim.api.nvim_buf_is_valid(bufnr) then
                vim.fn.delete(out)
                return
              end
              jobs[bufnr] = nil
              if code ~= 0 then
                vim.fn.delete(out)
                vim.notify("[mermaid] render failed (exit " .. code .. ")", vim.log.levels.WARN)
                return
              end
              local win = vim.fn.bufwinid(bufnr)
              local ok, image = pcall(require, "image")
              if not ok or win == -1 then
                vim.fn.delete(out)
                return
              end
              if not clear_image(bufnr) then
                vim.fn.delete(out)
                return
              end
              local created, img = pcall(image.from_file, out, {
                buffer = bufnr,
                window = win,
                col = 0,
                row = vim.api.nvim_buf_line_count(bufnr),
                with_virtual_padding = true,
                inline = true,
                max_width_window_percentage = 75,
                max_height_window_percentage = 65,
              })
              if created and img then
                current_images[bufnr], image_paths[bufnr] = img, out
                if not pcall(function()
                  img:render()
                end) then
                  clear_image(bufnr)
                end
              else
                vim.fn.delete(out)
              end
            end)
          end,
        })
        if job > 0 then
          jobs[bufnr] = job
        else
          outputs[out] = nil
          vim.fn.delete(out)
          vim.notify("[mermaid] mmdc could not start", vim.log.levels.WARN)
        end
      end

      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost" }, {
        group = group,
        pattern = "*.mmd",
        callback = function(ev)
          render_mmd(ev.buf, false)
        end,
      })

      vim.api.nvim_create_autocmd({ "BufLeave", "BufWipeout" }, {
        group = group,
        callback = function(ev)
          if generations[ev.buf] then
            cancel_render(ev.buf)
            clear_image(ev.buf)
            if ev.event == "BufWipeout" then generations[ev.buf] = nil end
          end
        end,
      })

      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
          for buf in pairs(jobs) do
            cancel_render(buf)
          end
          for buf in pairs(current_images) do
            clear_image(buf)
          end
          for out in pairs(outputs) do
            vim.fn.delete(out)
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
        if src == "" then return end
        local out = src:match("%.mmd$") and src:gsub("%.mmd$", ".svg") or (src .. ".svg")
        vim.fn.jobstart({
          "mmdc", "-i", src, "-o", out, "--puppeteerConfigFile", puppeteer_cfg,
        }, {
          env = { PUPPETEER_EXECUTABLE_PATH = chrome },
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
