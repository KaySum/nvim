-- Minimal client for the Rex server this nvim runs in (REX_SESSION / REX_BLOCK).
local M = {}

M.enabled = vim.env.REX_SESSION ~= nil and vim.env.REX_BLOCK ~= nil

--- Runs a Rex action (`rex do`) as this nvim's pane and returns its decoded result.
--- Synchronous unless `on_done` is given. Errors are notified and return nil.
---@param action string
---@param args? table
---@param on_done? fun(res:table)
---@return table?
function M.call(action, args, on_done)
  local cmd = { "rex", "do", "-s", vim.env.REX_SESSION, "-b", vim.env.REX_BLOCK, "--json", action }
  if args then
    vim.list_extend(cmd, { "--args", vim.json.encode(args) })
  end
  local function handle(r)
    if r.code ~= 0 then
      vim.schedule(function()
        vim.notify(vim.trim(r.stderr), vim.log.levels.ERROR, { title = "rex " .. action })
      end)
      return
    end
    local res = vim.json.decode(r.stdout, { luanil = { object = true } })
    return type(res) == "table" and res or {}
  end
  if on_done then
    vim.system(cmd, { text = true }, function(r)
      local res = handle(r)
      if res then
        vim.schedule_wrap(on_done)(res)
      end
    end)
  else
    return handle(vim.system(cmd, { text = true }):wait())
  end
end

--- What Rex needs to reach back into this nvim (`nvim --server ... --remote-send`).
function M.nvim_addr()
  return { vim.v.progpath, vim.v.servername }
end

return M
