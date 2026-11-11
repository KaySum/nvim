-- Sidekick on Rex: agent CLIs run in Rex splits via the agent_* actions in ~/.config/rex/sidekick.lua.
-- Sessions are external, so sidekick never opens an nvim terminal.
local Rex = require("rex")

local M = {}

---@class sidekick.cli.muxer.Rex: sidekick.cli.Session
---@field rex_block string
local Backend = {}
Backend.__index = Backend
Backend.priority = 60

-- is_running() is polled by sidekick (e.g. the statusline), so share one listing briefly.
local agents, listed_at = nil, 0
local function list(fresh)
  if fresh or not agents or vim.uv.now() - listed_at > 1000 then
    agents = (Rex.call("agent_list") or {}).agents or {}
    listed_at = vim.uv.now()
  end
  return agents
end

local function watch()
  if require("sidekick.config").cli.watch then
    require("sidekick.cli.watch").enable()
  end
end

function Backend:init()
  self.external = true
end

function Backend:start()
  local unset, set = {}, {}
  for k, v in pairs(self.tool.env or {}) do
    if v == false then
      vim.list_extend(unset, { "-u", k })
    else
      set[#set + 1] = k .. "=" .. tostring(v)
    end
  end
  local cmd = vim.list_extend(vim.list_extend(vim.list_extend({ "env" }, unset), set), self.tool.cmd)
  local res = Rex.call("agent_open", {
    name = self.tool.name,
    cmd = cmd,
    cwd = self.cwd,
    nvim = Rex.nvim_addr(),
  })
  if not res then
    return
  end
  self.rex_block = res.block_id
  self.id = "rex: " .. res.block_id
  self.started = true
  agents = nil
  watch()
end

-- Reattaching brings the agent beside this nvim, like sidekick showing its terminal.
function Backend:attach()
  Rex.call("agent_attach", { block_id = self.rex_block, nvim = Rex.nvim_addr() })
  watch()
end

function Backend:detach()
  agents = nil
  vim.system({ "rex", "block", "close", "-s", vim.env.REX_SESSION, self.rex_block })
end

function Backend:is_running()
  for _, a in ipairs(list()) do
    if a.block_id == self.rex_block then
      return true
    end
  end
  return false
end

function Backend:send(text)
  Rex.call("agent_send", { block_id = self.rex_block, text = text, paste = true })
end

function Backend:submit()
  Rex.call("agent_send", { block_id = self.rex_block, text = "\r" })
end

function Backend.sessions()
  local tools = require("sidekick.config").cli.tools
  local ret = {} ---@type sidekick.cli.session.State[]
  for _, a in ipairs(list(true)) do
    -- Agents owned by another live nvim stay with it; Rex also refuses to attach them here.
    if tools[a.name] and (a.owner == nil or a.owner == vim.env.REX_BLOCK) then
      ret[#ret + 1] = { id = "rex: " .. a.block_id, cwd = a.cwd, tool = a.name, rex_block = a.block_id }
    end
  end
  return ret
end

---@param filter? sidekick.cli.Filter
local function select(filter)
  require("sidekick.cli").select({
    filter = filter,
    auto = filter ~= nil,
    cb = function(state)
      if not state then
        return
      end
      local again = state.attached -- picking an already attached agent still brings it here
      state = require("sidekick.cli.state").attach(state, { show = true })
      if again and state.session.backend == "rex" then
        state.session:attach()
      end
    end,
  })
end

-- Switch to the tab's agent; otherwise bring back an attached one, or pick one.
local function toggle()
  Rex.call("agent_toggle", nil, function(res)
    if res.agent then
      return
    end
    local attached = #require("sidekick.cli.state").get({ attached = true }) > 0
    select(attached and { attached = true } or nil)
  end)
end

-- Close the tab's agent (the one toggle switches to), attached to this nvim or not.
local function close()
  Rex.call("agent_close", nil, function(res)
    if not res.agent then
      return vim.notify("No agent in this tab", vim.log.levels.WARN, { title = "Sidekick" })
    end
    agents = nil
    local Session = require("sidekick.cli.session")
    local session = Session._attached["rex: " .. res.block_id]
    if session then
      Session.detach(session)
    end
  end)
end

M.enabled = false -- until setup() finishes

-- Each key runs the Rex version while the override is on, and sidekick's own action otherwise.
local function either(rex_fn, sidekick_fn)
  return function()
    if M.enabled then
      return rex_fn()
    end
    require("sidekick.cli")[sidekick_fn]()
  end
end

M.focus = either(toggle, "focus") -- <c-.>
M.toggle = either(toggle, "toggle") -- <leader>aa
M.select = either(select, "select") -- <leader>as
M.close = either(close, "close") -- <leader>ad

local original -- sidekick's own mux settings, put back while the override is off
local suspended = {} -- this nvim's attached Rex agents, set aside (still running) while it's off

--- Connects or disconnects the override. Off, sidekick is back to its own config and knows
--- nothing about Rex agents; on again, the agents set aside are reattached.
---@param enabled boolean
function M.set(enabled)
  local Session = require("sidekick.cli.session")
  local mux = require("sidekick.config").cli.mux
  M.enabled = enabled
  if enabled then
    Session.register("rex", Backend)
    mux.enabled, mux.backend = true, "rex"
    for id, s in pairs(suspended) do
      Session._attached[id] = s
    end
    suspended = {}
  else
    Session.backends.rex = nil
    mux.enabled, mux.backend = original.enabled, original.backend
    for id, s in pairs(Session._attached) do
      if s.backend == "rex" then
        suspended[id], Session._attached[id] = s, nil
      end
    end
  end
end

--- Call after require("sidekick").setup().
function M.setup()
  local mux = require("sidekick.config").cli.mux
  original = { enabled = mux.enabled, backend = mux.backend }
  -- sidekick validates mux.backend against tmux|zellij on the next tick, so switch after that.
  vim.schedule(function()
    M.set(true)
  end)
  vim.api.nvim_create_user_command("SidekickRex", function(cmd)
    local arg = cmd.args ~= "" and cmd.args or "toggle"
    M.set(arg == "on" or (arg == "toggle" and not M.enabled))
    -- Rex also stops handling ctrl+. here, and the agent keys in agents this nvim owns.
    Rex.call("agent_override", { enabled = M.enabled }, function() end)
    vim.notify("Rex agent splits " .. (M.enabled and "on" or "off"), vim.log.levels.INFO, { title = "Sidekick" })
  end, {
    nargs = "?",
    complete = function()
      return { "on", "off", "toggle" }
    end,
    desc = "Connect or disconnect sidekick's Rex override",
  })
end

return M
