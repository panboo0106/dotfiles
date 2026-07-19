-- =============================================================================
-- Shared Configuration Utilities
-- =============================================================================
-- Common functions used across multiple configuration files.
-- =============================================================================

local M = {}

--- Find a configuration file using vim.fn.findfile with project root search
--- @param files string|string[] List of filenames to search for
--- @param start_path? string Optional starting path
--- @return string The found config file path, or empty string if not found
function M.find_config_with_findfile(files, start_path)
  files = type(files) == "table" and files or { files }
  local current = start_path or vim.fn.expand("%:p:h")

  for _, file in ipairs(files) do
    local found = vim.fn.findfile(file, current .. ";")
    if found ~= "" then
      return found
    end
  end

  return ""
end

return M
