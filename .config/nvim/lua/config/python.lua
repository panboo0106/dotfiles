local M = {}

-- Resolve at initialization/run time so venv-selector changes are respected.
function M.resolve(root)
  for _, env in ipairs({ "VIRTUAL_ENV", "CONDA_PREFIX" }) do
    local dir = vim.env[env]
    local python = dir and (dir .. "/bin/python")
    if python and vim.fn.executable(python) == 1 then
      return python
    end
  end

  root = root
    or vim.fs.root(vim.api.nvim_buf_get_name(0), {
      ".venv",
      "venv",
      ".env",
      "env",
      "pyproject.toml",
      "uv.lock",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      ".git",
    })
    or vim.fn.getcwd()
  for _, name in ipairs({ ".venv", "venv", ".env", "env" }) do
    local python = root .. "/" .. name .. "/bin/python"
    if vim.fn.executable(python) == 1 then
      return python
    end
  end
  local python = vim.fn.exepath("python3")
  return python ~= "" and python or vim.fn.exepath("python")
end

return M
