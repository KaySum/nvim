local M = {}

local ACTIVE_MARKER = "●"

local function term_meta(buf)
  return vim.b[buf].snacks_terminal or {}
end

local function focus_terminal(count)
  Snacks.terminal.focus(nil, { cwd = LazyVim.root(), count = count })
end

local mru_term_id

local function focus_mru_terminal()
  focus_terminal(vim.v.count > 0 and vim.v.count or mru_term_id or 1)
end

local function open_terminal(id)
  return function()
    focus_terminal(id)
  end
end

local function process_tree()
  local ok, out = pcall(vim.fn.system, { "ps", "-Ao", "pid=,ppid=,comm=" })
  if not ok or vim.v.shell_error ~= 0 then
    return nil
  end
  local comm, children = {}, {}
  for line in out:gmatch("[^\n]+") do
    local pid_s, ppid_s, name = line:match("^%s*(%d+)%s+(%d+)%s+(.+)$")
    local pid, ppid = tonumber(pid_s), tonumber(ppid_s)
    if pid and ppid then
      comm[pid] = name
      children[ppid] = children[ppid] or {}
      table.insert(children[ppid], pid)
    end
  end
  return { comm = comm, children = children }
end

local function foreground_process(tree, pid)
  if not (tree and pid) then
    return nil
  end
  local deepest, max_depth = pid, 0
  local function walk(p, depth)
    if depth > max_depth then
      deepest, max_depth = p, depth
    end
    for _, child in ipairs(tree.children[p] or {}) do
      walk(child, depth + 1)
    end
  end
  walk(pid, 0)
  local name = tree.comm[deepest]
  return name and vim.fn.fnamemodify(name, ":t") or nil
end

local function term_cwd(buf)
  -- terminal buffers are named "term://{cwd}//{pid}:{cmd}"
  local title = vim.b[buf].term_title or ""
  return vim.fn.fnamemodify(title:match("^term://(.-)//") or "", ":~")
end

local function describe_terminal(buf, tree)
  local process = foreground_process(tree, vim.b[buf].terminal_job_pid)
  return vim.trim((process or "") .. "  " .. term_cwd(buf))
end

local function terminal_label(t, tree)
  local id = term_meta(t.buf).id
  local marker = id == mru_term_id and ACTIVE_MARKER or " "
  local name = vim.b[t.buf].terminal_name
  local label = name and ("[" .. name .. "] ") or ""
  return ("%s (%s)  %s%s"):format(marker, id or "?", label, describe_terminal(t.buf, tree))
end

local function pick_terminal(prompt, on_choice)
  local terms = Snacks.terminal.list()
  if #terms == 0 then
    return vim.notify("No active terminals", vim.log.levels.INFO)
  end
  table.sort(terms, function(a, b)
    return (term_meta(a.buf).id or 0) < (term_meta(b.buf).id or 0)
  end)
  local tree = process_tree()
  vim.ui.select(terms, {
    prompt = prompt,
    format_item = function(t)
      return terminal_label(t, tree)
    end,
  }, function(t)
    if t then
      on_choice(t)
    end
  end)
end

local function switch_terminal()
  pick_terminal("Terminals", function(t)
    t:show():focus()
  end)
end

local function rename_terminal()
  pick_terminal("Rename terminal", function(t)
    vim.ui.input({
      prompt = "Terminal name: ",
      default = vim.b[t.buf].terminal_name,
      -- line up with the select picker, which centers a 0.4-high box (top ~0.3).
      win = { row = 0.3 },
    }, function(name)
      if name then
        vim.b[t.buf].terminal_name = name ~= "" and name or nil
      end
    end)
  end)
end

-- Winbar for terminal windows: snacks' default "<id>: <title>", with a "[name]"
-- prefix added when the terminal has been renamed. Wire into styles.terminal.wo.
M.winbar = table.concat({
  "%{get(b:snacks_terminal,'id','')}: ",
  "%{empty(get(b:,'terminal_name','')) ? '' : '['.get(b:,'terminal_name','').'] '}",
  "%{get(b:,'term_title','')}",
})

M.keys = {
  { "<leader>t", "", desc = "+terminal" },
  { "<leader>tt", switch_terminal, desc = "Switch Terminal" },
  { "<leader>tr", rename_terminal, desc = "Rename Terminal" },
}
for i = 1, 9 do
  M.keys[#M.keys + 1] = { "<leader>t" .. i, open_terminal(i), desc = "Terminal #" .. i }
end

function M.setup()
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("mru_terminal", { clear = true }),
    callback = function(ev)
      mru_term_id = term_meta(ev.buf).id or mru_term_id
    end,
  })

  -- LazyVimKeymapsDefaults fires after LazyVim's default <C-/>, so this wins.
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimKeymapsDefaults",
    callback = function()
      vim.keymap.set({ "n", "t" }, "<c-/>", focus_mru_terminal, { desc = "Terminal (Root Dir)" })
      vim.keymap.set({ "n", "t" }, "<c-_>", focus_mru_terminal, { desc = "which_key_ignore" })
    end,
  })
end

return M
