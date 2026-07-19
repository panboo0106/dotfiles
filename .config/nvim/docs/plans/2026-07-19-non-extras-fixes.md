# Non-Extras Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the confirmed bugs and cleanups from the original config audit that are NOT part of the concurrent `2026-07-19-lazyvim-extras-migration.md` effort — items in 4 categories the user explicitly confirmed in scope: confirmed bugs, deprecated/redundant dependencies, perf items, keymap/config cleanups.

**Architecture:** Same repo as the extras migration (`~/.config/nvim`, no git — see that plan's Global Constraints for the tar-backup safety net, which already covers these files). Each task here is a small, single-file, mostly-mechanical change with a precisely verified old_string/new_string — no design ambiguity remains, every item below was independently re-verified against the CURRENT file state and, where relevant, against LazyVim's current upstream source, immediately before this plan was written (not from memory of the original audit).

**Tech Stack:** Neovim 0.12.3, lazy.nvim (main), LazyVim 16 (main branch), Lua.

## Global Constraints

- No git repo in this directory (confirmed earlier in this session). No commit steps.
- **File overlap with the concurrent extras-migration plan, two spots, both resolved:**
  1. The Ruff config fix (originally bug #4 in the audit) touches `lua/plugins/lsp.lua`'s `ruff` server block, which the extras-migration plan's Task 7 (`lang.python`) also rewrites. To avoid two uncoordinated edits to the same block (the exact class of problem that caused the extras-migration Task 2 defect), **the Ruff fix is folded into that plan's Task 7 directly, not duplicated here.**
  2. **`lua/config/options.lua`, discovered mid-execution:** this plan's Task H removes the dead `vim.g.build_cmd = "make"` line; the extras-migration plan's Task 7 (via the folded-in Ruff fix, added after this plan was first written) removes the two lines immediately above it (`RUFF_CONFIG` env var + its comment). Task H was executed first in this session (see `docs/plans/sdd-work/progress.md`), so the extras-migration plan's Task 7 Step 3b old_string has been updated to match the post-Task-H file state (no longer expects `build_cmd` to be present) — see the note inline in that plan file. If re-running either plan from scratch in a different order, re-check this old_string against actual file content before applying.
  Every other task below was checked against the extras-migration plan's Tasks 3-9 file lists and has zero overlap.
- **Two items from the original audit were dropped after fresh verification, not carried into this plan:**
  - *nvim-notify removal* — re-read `lua/plugins/ui.lua`'s noice.nvim config: `notify.enabled=false` only stops noice from taking over the global `vim.notify()`, but the `routes` table still explicitly sends "Plugin Updates" messages through `view = "notify"`, and noice's `view/backend/notify.lua` genuinely `require("notify")`s to render that view. Removing the dependency would break that route. Not a dead dependency — leave it.
  - *`<leader>gn`/`<leader>gnc` prefix-shadow (300ms wait)* — this is an inherent tradeoff of `<leader>gn` being both a complete binding (opens Neogit) and a prefix for `gnc`/`gnb`/`gnl`; there's no fix that doesn't mean renaming one of the keys, which is a taste call, not a bug fix. Not included as a task — flagging only.
- **Items already resolved as side effects of the extras migration, not duplicated here:** `FixCursorHold.nvim` (dropped when extras-migration Task 2 deleted the old neotest block — verified zero remaining references), `neotest-go`→`neotest-golang`, the Go formatter triple-redundancy, `markdownlint-cli2`/`markdown-toc` activation, `ts_ls` dead code, ESLint's stale `useFlatConfig` setting (all handled by that plan's Tasks 4/6/9).

---

### Task A: Fix treesitter.lua being a stale, hand-copied LazyVim core spec

**Files:**
- Modify: `lua/plugins/treesitter.lua:1-105` (the `nvim-treesitter/nvim-treesitter` entry only — leave `nvim-treesitter-textobjects`, `nvim-ts-autotag`, `nvim-treesitter-context` entries at lines 107-171 untouched, they're genuine and not copies of anything)

**Acceptance criterion:** Treesitter-based indentation (`indentexpr`) and folding (`foldexpr`) actually activate on FileType, which they do not today — the hand-copied `config` function only calls `vim.treesitter.start` and never sets `indentexpr`/`foldexpr`, silently dropping the `indent = { enable = true }` opts value the file itself declares. Re-verified this against LazyVim's CURRENT upstream source (`~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/treesitter.lua`, re-read immediately before writing this task): upstream's own `config` function does set both via `LazyVim.set_default("indentexpr", ...)` / `LazyVim.set_default("foldexpr", ...)`, gated per-feature through an `enabled()` helper the hand-copy never carries. Also, upstream has since added `commit = vim.fn.has("nvim-0.12") == 0 and "..." or nil` pinning and a `folds = { enable = true }` opts field the hand-copy predates entirely — this file was copied from an older LazyVim revision and has not tracked upstream since.

- [ ] **Step 1: Verify current broken state (RED)**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+e /tmp/x.lua" "+lua vim.defer_fn(function() print('INDENTEXPR='..vim.bo.indentexpr); print('FOLDEXPR='..vim.wo.foldexpr); vim.cmd('qall') end, 400)" 2>&1 | tail -2
```
Expected: `INDENTEXPR=` empty (or unrelated default), NOT `v:lua.LazyVim.treesitter.indentexpr()` — confirms treesitter indent is not actually wired despite `opts.indent.enable=true`.

- [ ] **Step 2: Replace the `nvim-treesitter/nvim-treesitter` entry with an opts-only fragment**

The project's only genuine customization versus LazyVim's current defaults is 7 additional parsers (`go`, `gomod`, `gosum`, `java`, `jsonc`, `rust`, `mermaid` — everything else in the current `ensure_installed` list duplicates what LazyVim 16 core already installs, confirmed by diffing both lists directly). `opts_extend = {"ensure_installed"}` is already set on LazyVim core's own spec, so a plain `opts` table merges automatically — no need to redeclare it here.

Modify `lua/plugins/treesitter.lua`, old_string (the entire first plugin entry, from the opening `{` through its closing `},` immediately before the `nvim-treesitter-textobjects` entry):
```lua
return {

  -- Treesitter is a new parser generator tool that we can
  -- use in Neovim to power faster and more accurate
  -- syntax highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false, -- last release is way too old and doesn't work on Windows
    build = function()
      local TS = require("nvim-treesitter")
      if not TS.get_installed then
        LazyVim.error("Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.")
        return
      end
      LazyVim.treesitter.ensure_treesitter_cli(function()
        TS.update(nil, { summary = true })
      end)
    end,
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    event = { "LazyFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" },
    ---@class lazyvim.TSConfig: TSConfig
    opts = {
      -- LazyVim config for treesitter
      indent = { enable = true, disable = { "python" } },
      highlight = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "go",
        "gomod",
        "gosum",
        "html",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "mermaid",
      },
    },
    ---@param opts lazyvim.TSConfig
    config = function(_, opts)
      local TS = require("nvim-treesitter")

      -- some quick sanity checks
      if not TS.get_installed then
        return LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
      elseif type(opts.ensure_installed) ~= "table" then
        return LazyVim.error("`nvim-treesitter` opts.ensure_installed must be a table")
      end

      -- setup treesitter
      TS.setup(opts)
      LazyVim.treesitter.get_installed(true) -- initialize the installed langs

      -- install missing parsers
      local install = vim.tbl_filter(function(lang)
        return not LazyVim.treesitter.have(lang)
      end, opts.ensure_installed or {})
      if #install > 0 then
        LazyVim.treesitter.ensure_treesitter_cli(function()
          TS.install(install, { summary = true }):await(function()
            LazyVim.treesitter.get_installed(true) -- refresh the installed langs
          end)
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
        callback = function(ev)
          if not LazyVim.treesitter.have(ev.match) then
            return
          end

          -- highlighting
          if vim.tbl_get(opts, "highlight", "enable") ~= false then
            pcall(vim.treesitter.start)
          end


        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
```
new_string:
```lua
return {

  -- Treesitter config/build/event/cmd now entirely from LazyVim core (was a stale hand-copy
  -- that predated upstream's indent/fold wiring and silently dropped indentexpr/foldexpr).
  -- Only the project's own parser additions survive here; opts_extend merges them into core's list.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "go", "gomod", "gosum", "java", "jsonc", "rust", "mermaid" },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
```

- [ ] **Step 3: Verify the fix (GREEN)**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+e /tmp/x.lua" "+lua vim.defer_fn(function() print('INDENTEXPR='..vim.bo.indentexpr); print('FOLDEXPR='..vim.wo.foldexpr); vim.cmd('qall') end, 400)" 2>&1 | tail -2
```
Expected: `INDENTEXPR=v:lua.LazyVim.treesitter.indentexpr()`, `FOLDEXPR=` LazyVim's fold expr (non-empty) — confirms both are now wired. (Fold is nominally disabled elsewhere by `nvim-ufo` in `editor.lua` setting `foldmethod`/`foldexpr` itself via `provider_selector`; this step just confirms treesitter's OWN opts are no longer silently dropped — if ufo overrides it later in the same session that's expected and unrelated.)

- [ ] **Step 4: Verify the 7 project-specific parsers still install**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-treesitter'}})" "+lua local ok, opts = pcall(function() return require('lazy.core.plugin').values(require('lazy.core.config').plugins['nvim-treesitter'], 'opts', false) end); print('OK='..tostring(ok)); if ok then print('ENSURE='..table.concat(opts.ensure_installed, ',')) end" "+qall" 2>&1 | tail -3
```
Expected: `ENSURE=` list includes `go`, `gomod`, `gosum`, `java`, `jsonc`, `rust`, `mermaid` alongside LazyVim's own defaults (bash, c, diff, html, etc.) — confirms `opts_extend` merged both sides.

- [ ] **Step 5: Full headless startup, no errors**

Run: `cd /Users/leo/.config/nvim && nvim --headless "+qall" 2>&1` — expect empty output.

---

### Task B: Fix `spell` not actually being disabled

**Files:**
- Modify: `lua/config/autocmds.lua:1-5`

**Acceptance criterion:** Opening a `markdown`/`gitcommit`/`text`/`plaintex`/`typst` file no longer turns on `spell`, even though `options.lua:8` sets `vim.opt.spell = false` globally — currently LazyVim core's own `wrap_spell` autocmd (`lazyvim/config/autocmds.lua`) unconditionally sets `vim.opt_local.spell = true` for those filetypes, silently overriding the global default, and the project's `autocmds.lua` only has a comment claiming it's handled, not an actual override.

- [ ] **Step 1: Verify current broken state (RED)**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+e /tmp/x.md" "+lua vim.defer_fn(function() print('SPELL='..tostring(vim.wo.spell)); vim.cmd('qall') end, 300)" 2>&1 | tail -1
```
Expected: `SPELL=true` (the bug — global `spell=false` from `options.lua` is being overridden).

- [ ] **Step 2: Clear LazyVim's `wrap_spell` autocmd for the `spell` half specifically**

`wrap` (soft line wrap for prose filetypes) is desirable and should stay; only `spell` should be suppressed. Modify `lua/config/autocmds.lua`, old_string:
```lua
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- spell 已在 options.lua 中全局禁用（vim.opt.spell = false）
```
new_string:
```lua
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- LazyVim core's `wrap_spell` autocmd force-enables `spell` for prose filetypes, overriding the
-- global `vim.opt.spell = false` in options.lua. Keep the wrap behavior, drop the spell override.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("lazyvim_wrap_spell", { clear = false }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spell = false
  end,
})
```

Note: this deliberately does NOT use `nvim_clear_autocmds` on LazyVim's `lazyvim_wrap_spell` group, since that group also is not guaranteed stable across LazyVim versions and clearing someone else's augroup by name is fragile. Instead, this adds a second `FileType` autocmd for the same patterns that runs after LazyVim's (both are registered via `VeryLazy`, and this project's `autocmds.lua` loads after LazyVim core's per lazy.nvim's own module load order) and simply re-disables `spell`, which is idempotent and robust to LazyVim renaming its internal group.

- [ ] **Step 3: Verify the fix (GREEN)**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+e /tmp/x.md" "+lua vim.defer_fn(function() print('SPELL='..tostring(vim.wo.spell)); print('WRAP='..tostring(vim.wo.wrap)); vim.cmd('qall') end, 300)" 2>&1 | tail -2
```
Expected: `SPELL=false`, `WRAP=true` (wrap still works, spell no longer does).

- [ ] **Step 4: Verify gitcommit and text filetypes too (not just markdown)**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+e /tmp/x.txt" "+set ft=gitcommit" "+lua vim.defer_fn(function() print('SPELL_GITCOMMIT='..tostring(vim.wo.spell)); vim.cmd('qall') end, 300)" 2>&1 | tail -1
```
Expected: `SPELL_GITCOMMIT=false`.

---

### Task C: Reduce `linting.lua`'s over-eager trigger events

**Files:**
- Modify: `lua/plugins/linting.lua:191-196` (only the trailing autocmd — the rest of the file, all the custom linter definitions for vulture/clangtidy/checkstyle/golangcilint, is genuine project customization and stays untouched)

**Acceptance criterion:** Switching between already-open buffers (`BufEnter`, e.g. via `:bnext`, window navigation, LSP jump-to-definition into an open buffer) no longer re-runs heavy external linters (`golangci-lint`, `clang-tidy`, `checkstyle` — all spawn a subprocess per invocation) on every single switch. Re-verified against LazyVim 16 core's CURRENT `linting.lua` (re-read immediately before writing this task): core uses `{"BufWritePost", "BufReadPost", "InsertLeave"}` (note `BufReadPost`, which fires once when a buffer is first loaded — not `BufEnter`, which fires on every re-visit to an already-loaded buffer) plus a 100ms debounce around the lint call. The project's version uses `BufEnter` instead of `BufReadPost` and has no debounce at all.

- [ ] **Step 1: Confirm current trigger set (documents the before-state; no separate RED command needed — the event list itself is the evidence)**

Run:
```bash
grep -n "nvim_create_autocmd" -A3 /Users/leo/.config/nvim/lua/plugins/linting.lua | tail -5
```
Expected (before fix): shows `{ "BufWritePost", "BufEnter", "InsertLeave" }` with a plain `callback = function() lint.try_lint() end` (no debounce).

- [ ] **Step 2: Swap the trigger events and add a debounce, mirroring LazyVim core's own pattern**

Modify `lua/plugins/linting.lua`, old_string:
```lua
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
```
new_string:
```lua
      -- BufReadPost (not BufEnter) + 100ms debounce, matching LazyVim core's own nvim-lint
      -- wiring: BufEnter re-fires on every switch to an already-open buffer, which re-spawns
      -- external processes (golangci-lint, clang-tidy, checkstyle) far more often than needed.
      local function debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = lint_augroup,
        callback = debounce(100, function()
          lint.try_lint()
        end),
      })
    end,
  },
}
```

- [ ] **Step 3: Verify BufEnter alone no longer triggers a lint pass**

Run (opens a Go file — swap the tmp file extension if you don't have Go tooling handy, the point is any filetype with a configured linter; count `golangci-lint`/relevant-linter invocations via a marker file since `lint.try_lint` itself doesn't print):
```bash
cat > /tmp/x.go <<'EOF'
package main
func main() {}
EOF
cd /Users/leo/.config/nvim && nvim --headless "+e /tmp/x.go" "+lua vim.defer_fn(function() local before = vim.diagnostic.count(0); vim.cmd('buffer 1 | buffer %'); vim.defer_fn(function() print('BUFENTER_TRIGGERED_NO_ERROR=true') end, 50) end, 300)" "+qall" 2>&1 | tail -3
```
This step is a weak/indirect check (nvim-lint doesn't expose an invocation counter) — the stronger confirmation is Step 2's diff itself (event list no longer contains `BufEnter`) plus Step 4's plain syntax/load check. Treat this step as a smoke test only: expect no Lua errors in the output.

- [ ] **Step 4: Verify the file still loads without errors and existing linters (vulture/clangtidy/checkstyle/golangcilint) are untouched**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-lint'}})" "+lua local lint = require('lint'); print('LINTERS='..table.concat(vim.tbl_keys(lint.linters), ','))" "+qall" 2>&1 | tail -2
```
Expected: `LINTERS=` includes `golangcilint`, `clangtidy` (if `clang-tidy` binary present), `checkstyle` (if binary present), `vulture` (if binary present) — same set as before this task, confirming the custom linter definitions (untouched by this edit) still register correctly.

---

### Task D: Swap archived `nvim-colorizer.lua` for the maintained fork

**Files:**
- Modify: `lua/plugins/ui.lua:477-486`

**Acceptance criterion:** Plugin source points at a repo that is not archived. Verified immediately before writing this task: `git ls-remote https://github.com/catgoose/nvim-colorizer.lua.git HEAD` and `git ls-remote https://github.com/NvChad/nvim-colorizer.lua.git HEAD` both resolve to the identical commit (`72a05f62c52241bc7441c820eb53946f92b2e6a4`) — confirms the fork is real, exists, and currently matches upstream exactly (GitHub is redirecting the old org path), so this is a same-content source swap, not a behavior change.

- [ ] **Step 1: Swap the plugin source**

Modify `lua/plugins/ui.lua`, old_string:
```lua
  {
    "NvChad/nvim-colorizer.lua",
    event = "LazyFile",
    opts = {
      filetypes = { "*", css = { css = true }, html = { css = true } },
    },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
  },
}
```
new_string:
```lua
  {
    "catgoose/nvim-colorizer.lua", -- NvChad/nvim-colorizer.lua is archived; same content, active fork
    event = "LazyFile",
    opts = {
      filetypes = { "*", css = { css = true }, html = { css = true } },
    },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
  },
}
```

- [ ] **Step 2: Verify it resolves and loads**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'nvim-colorizer.lua'}})" "+lua local ok = pcall(require, 'colorizer'); print('COLORIZER_LOADABLE='..tostring(ok))" "+qall" 2>&1 | tail -2
```
Expected: `COLORIZER_LOADABLE=true`.

Note: lazy.nvim tracks installed plugins by directory name (derived from the repo name, `nvim-colorizer.lua` in both cases), so the existing install directory and `lazy-lock.json` entry are reused — this does not force a fresh clone or lose the pinned commit. Run `:Lazy` interactively afterward and confirm the entry shows the new URL with no re-install needed (or a trivial remote-URL-only update).

---

### Task E: Trim the redundant `mini.nvim` monorepo dependency from `markdown.lua`

**Files:**
- Modify: `lua/plugins/languages/markdown.lua:19-27`

**Acceptance criterion:** `render-markdown.nvim` still resolves an icon provider (via the already-installed, standalone `nvim-mini/mini.icons`, confirmed separately active in `lua/plugins/ui.lua:3-21` with its own `nvim-web-devicons` shim), without pulling in the full `nvim-mini/mini.nvim` monorepo — which is otherwise unused: `lazy-lock.json` tracks `mini.ai`, `mini.icons`, `mini.nvim`, and `mini.pairs` as four independently-versioned plugins (confirmed LazyVim core installs `mini.ai`/`mini.pairs` as their own standalone repos, not via the `mini.nvim` bundle), so `mini.nvim` here exists solely because of this one `dependencies` line.

- [ ] **Step 1: Verify current dependency and confirm `mini.icons` already covers the actual need**

Run:
```bash
grep -n -A2 "package.preload\[.nvim-web-devicons.\]" /Users/leo/.config/nvim/lua/plugins/ui.lua
```
Expected: confirms `mini.icons`'s `init` function pre-registers a `nvim-web-devicons`-compatible module — this is what any icon-consuming plugin (including `render-markdown.nvim`) actually resolves via `require("nvim-web-devicons")`, independent of whether `mini.nvim` (the monorepo) is installed.

- [ ] **Step 2: Remove the `mini.nvim` dependency**

Modify `lua/plugins/languages/markdown.lua`, old_string:
```lua
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.nvim",
      -- 'echasnovski/mini.icons' -- 如果使用独立 mini 插件
      -- 'nvim-tree/nvim-web-devicons' -- 如果偏好使用 nvim-web-devicons
    },
```
new_string:
```lua
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      -- icon provider comes from the already-installed nvim-mini/mini.icons (ui.lua),
      -- which shims nvim-web-devicons — no need for the full mini.nvim monorepo here.
    },
```

- [ ] **Step 3: Verify render-markdown still loads and resolves icons without error**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+e /tmp/x.md" "+lua vim.defer_fn(function() local ok, rm = pcall(require, 'render-markdown'); print('RENDER_MARKDOWN_OK='..tostring(ok)); local ok2 = pcall(require, 'nvim-web-devicons'); print('DEVICONS_SHIM_OK='..tostring(ok2)); vim.cmd('qall') end, 400)" 2>&1 | tail -2
```
Expected: `RENDER_MARKDOWN_OK=true`, `DEVICONS_SHIM_OK=true`.

- [ ] **Step 4: Confirm `mini.nvim` (the monorepo) is no longer referenced anywhere**

Run:
```bash
grep -rn '"nvim-mini/mini.nvim"' /Users/leo/.config/nvim/lua/
```
Expected: no matches (empty output) — safe to `:Lazy clean` it later if desired (not part of this task; removing installed-but-now-orphaned plugins from disk is a separate, optional step the user can run interactively).

---

### Task F: Fix `leetcode.nvim` eager-loading on every startup

**Files:**
- Modify: `lua/plugins/tools.lua:17-26`

**Acceptance criterion:** `leetcode.nvim` (and its `build = ":TSUpdate html"` step) no longer loads on every Neovim startup via `event = "VeryLazy"`. Verified against the plugin's own README (`~/.local/share/nvim/lazy/leetcode.nvim/README.md`), which documents exactly this scenario: the project's config already sets `opts.arg = "leetcode.nvim"` (a leetcode.nvim-internal setting, unrelated to lazy.nvim loading), which only makes sense paired with the README's documented `lazy = leet_arg ~= vim.fn.argv(0, -1)` pattern — i.e. eager-load only when Neovim is invoked as `nvim leetcode.nvim` (a shell alias trick), lazy otherwise. The project set the `arg` half of this pattern but never the matching `lazy` condition, so it silently falls back to loading unconditionally on every `VeryLazy`.

- [ ] **Step 1: Confirm the plugin currently loads on every startup regardless of invocation**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua vim.defer_fn(function() print('LEETCODE_LOADED='..tostring(package.loaded['leetcode'] ~= nil)); vim.cmd('qall') end, 500)" 2>&1 | tail -1
```
Expected: `LEETCODE_LOADED=true` even with a completely unrelated headless invocation — confirms the bug (loads regardless of intent).

- [ ] **Step 2: Replace `event = "VeryLazy"` with the documented `lazy` condition**

Modify `lua/plugins/tools.lua`, old_string:
```lua
  {
    "kawre/leetcode.nvim",
    event = "VeryLazy",
    build = ":TSUpdate html",
```
new_string:
```lua
  {
    "kawre/leetcode.nvim",
    -- Only eager-load when invoked as `nvim leetcode.nvim` (matches opts.arg below, per the
    -- plugin's own README pattern) — otherwise stays unloaded until :Leet or similar is run.
    lazy = "leetcode.nvim" ~= vim.fn.argv(0, -1),
    cmd = "Leet",
    build = ":TSUpdate html",
```

- [ ] **Step 3: Verify it no longer loads on an unrelated headless startup**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua vim.defer_fn(function() print('LEETCODE_LOADED='..tostring(package.loaded['leetcode'] ~= nil)); vim.cmd('qall') end, 500)" 2>&1 | tail -1
```
Expected: `LEETCODE_LOADED=false`.

- [ ] **Step 4: Verify `:Leet` still loads it on demand**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy.core.loader').load({'leetcode.nvim'}, {})" "+lua vim.defer_fn(function() print('LEETCODE_LOADED_VIA_CMD='..tostring(package.loaded['leetcode'] ~= nil)); vim.cmd('qall') end, 300)" 2>&1 | tail -1
```
Expected: `LEETCODE_LOADED_VIA_CMD=true`.

---

### Task G: Add `node_modules` to the Snacks explorer exclude list

**Files:**
- Modify: `lua/plugins/tools.lua:220-236`

**Refactor: behavior change, not a bug fix, low-risk config addition** — no AC beyond "the excluded pattern list contains the new entry and the explorer still opens."

- [ ] **Step 1: Add `node_modules` to the exclude list**

Modify `lua/plugins/tools.lua`, old_string:
```lua
            -- 排除列表：只排除真正不需要看的文件，避免误杀同名业务目录
            exclude = {
              -- 系统垃圾文件
              ".DS_Store",
              "thumbs.db",
              "desktop.ini",
              "Thumbs.db",

              -- 版本控制内部文件
              ".git",
              ".svn",
              ".hg",

              -- 编辑器临时文件
              "*.swp",
              "*.swo",
              "*~",
            },
```
new_string:
```lua
            -- 排除列表：只排除真正不需要看的文件，避免误杀同名业务目录
            exclude = {
              -- 系统垃圾文件
              ".DS_Store",
              "thumbs.db",
              "desktop.ini",
              "Thumbs.db",

              -- 版本控制内部文件
              ".git",
              ".svn",
              ".hg",

              -- 编辑器临时文件
              "*.swp",
              "*.swo",
              "*~",

              -- 大型依赖目录（前端仓库常见，展开代价高）
              "node_modules",
            },
```

- [ ] **Step 2: Verify the config loads without error**

Run: `cd /Users/leo/.config/nvim && nvim --headless "+lua require('lazy').load({plugins={'snacks.nvim'}})" "+qall" 2>&1` — expect empty output.

---

### Task H: Clean up dead `options.lua` config and reformat `keymaps.lua`

**Files:**
- Modify: `lua/config/options.lua:11,29-36,37`
- Modify: `lua/config/keymaps.lua` (formatting only, via `stylua`, no logic change)

**Refactor: behavior unchanged** (all three removed lines/blocks are confirmed dead — `showtabline` is overwritten by `bufferline.nvim` on load, `build_cmd` has zero readers anywhere in `lua/`, and the `sh` extension mapping duplicates Neovim's own built-in filetype detection) — the `keymaps.lua` reformat is purely whitespace, verified against `stylua.toml`'s existing 2-space/`indent_type = "Spaces"` config that the rest of the codebase already follows.

- [ ] **Step 1: Confirm `build_cmd` truly has no readers**

Run: `grep -rn "build_cmd" /Users/leo/.config/nvim/lua/ /Users/leo/.config/nvim/init.lua` — expect only the one definition line in `options.lua`, no usage sites. If a usage site turns up, stop and do not remove this line.

- [ ] **Step 2: Confirm `showtabline` is overwritten by bufferline**

Run: `grep -n "showtabline\|always_show_bufferline" /Users/leo/.config/nvim/lua/plugins/ui.lua` — `bufferline.nvim` manages the tabline directly once loaded (`event = "VeryLazy"`, unconditional), making the manual `vim.opt.showtabline = 0` in `options.lua` a startup-only value immediately superseded. Confirm this is still the case (no `showtabline` reference in `ui.lua` limiting when bufferline takes over).

- [ ] **Step 3: Remove the three dead lines from `options.lua`**

Modify `lua/config/options.lua`, old_string:
```lua
vim.g.build_cmd = "make"
```
new_string: *(delete the line entirely — apply as an empty replacement, i.e. remove this line from the file)*

Modify `lua/config/options.lua`, old_string:
```lua
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
  },
  extension = {
    sh = "sh",
  },
})
vim.opt.showtabline = 0
```
new_string:
```lua
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
  },
})
```

(The `extension = { sh = "sh" }` mapping is redundant — Neovim's built-in filetype detection already maps `.sh` to `sh` natively; this line only ever re-asserted the default. `showtabline` is dropped per Step 2's confirmation; if that step found bufferline is somehow NOT overriding it in some mode, skip this half of the edit and report instead.)

- [ ] **Step 4: Verify `options.lua` still loads without error and Ruff/PATH logic (untouched) still works**

Run:
```bash
cd /Users/leo/.config/nvim && nvim --headless "+lua print('RUFF_CONFIG='..(vim.env.RUFF_CONFIG or 'nil')); print('AUTOFORMAT='..tostring(vim.g.autoformat))" "+qall" 2>&1 | tail -2
```
Expected: `RUFF_CONFIG=` shows the path (untouched logic), `AUTOFORMAT=true` — confirms the surrounding lines this task didn't touch are still intact.

- [ ] **Step 5: Snapshot, then reformat `keymaps.lua` with stylua (whitespace only)**

Run:
```bash
cd /Users/leo/.config/nvim && mkdir -p docs/plans/sdd-work/snapshots/task-H-before && cp lua/config/keymaps.lua docs/plans/sdd-work/snapshots/task-H-before/keymaps.lua && stylua lua/config/keymaps.lua
```

- [ ] **Step 6: Verify stylua made no logic changes — diff ignoring whitespace must be empty**

Run:
```bash
cd /Users/leo/.config/nvim && diff -u -b docs/plans/sdd-work/snapshots/task-H-before/keymaps.lua lua/config/keymaps.lua
```
Expected: empty output (`-b` ignores whitespace-only differences) — confirms stylua changed indentation/spacing only, no `desc` strings, action strings, or logic were altered.

- [ ] **Step 7: Full headless startup, no errors**

Run: `cd /Users/leo/.config/nvim && nvim --headless "+qall" 2>&1` — expect empty output.

---

## Final Verification (run once, after all 8 tasks)

- [ ] Full headless startup with no errors: `nvim --headless "+qall" 2>&1` — expect empty output.
- [ ] `:Lazy sync` interactively — confirm `catgoose/nvim-colorizer.lua` installs cleanly and no plugin shows a failed state.
- [ ] Open a markdown file, confirm `spell` is off and rendering (render-markdown, unrelated to this plan) still looks correct.
- [ ] Open a Go or C++ file, switch to another already-open buffer and back a few times, confirm no visible lag/flicker from linting (informal — the real fix is the event/debounce change, already verified mechanically in Task C).
