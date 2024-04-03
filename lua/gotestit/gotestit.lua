local api = vim.api
local M = {}

function M.run_this()
  -- get function
  local linenr = vim.api.nvim_win_get_cursor(0)[1]

  local nodes = M.get_flocations()
  local nearest_func = M.get_outer_or_closest(linenr, nodes)

  -- get test output
  -- local current_word = vim.fn.expand("<cword>")

  local run_cmd = "go test -v -run " .. nearest_func

  local result = vim.fn.systemlist(run_cmd)

  -- open window
  local height = #result

  if height == 0 then
    return
  end

  local height_cmd = height .. 'new test_output'

  api.nvim_command(height_cmd)
  vim.bo.filetype = 'go'
  -- set keymap
  local bufnr = api.nvim_get_current_buf()
  vim.keymap.set('n', 'q', '<cmd>bunload!<cr>', { desc = 'Close buffer', buffer = bufnr })
  -- insert test output
  api.nvim_buf_set_lines(bufnr, 0, -1, false, result)

  -- apply highlights
  if M.buffer_contains('FAIL') then
    vim.cmd([[ match CustomFailHighlight /\<FAIL\>/ ]])
  else
    vim.cmd([[ match CustomPassHighlight /\<PASS\>/ ]])
  end
end

function M.buffer_contains(word)
  local buffer_contents = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for _, line in ipairs(buffer_contents) do
    local _, occurrences = line:gsub(word, "")
    if occurrences > 0 then
      return true
    end
  end

  return false
end

function M.get_flocations()
  local ts = vim.treesitter
  local parsers = require('nvim-treesitter.parsers')

  -- This just prints a node as '<userdata1>'. Not helpful!
  -- local p = function(value)
  --   print(vim.inspect(value))
  -- end

  -- This is what we want!
  -- local print_node = function(node)
  --   p(ts.get_node_text(node, 0))
  -- end

  local parser = parsers.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()

  -- print_node(root) -- returns the whole buffer
  local lang = (parser:lang())
  -- p(lang)          -- e.g. "lua"

  -- get go function names
  local query_string = [[
(function_declaration
  name: (identifier) @name) @func
  ]]

  local query = ts.query.parse(lang, query_string)

  local nodes = {}
  for _, matches, _ in query:iter_matches(root, 0) do
    -- 1 is the func name, 2 the entire func scope
    local name_node = matches[1]
    local func_node = matches[2]
    -- print_node(node)
    -- prints go function names
    local name = ts.get_node_text(name_node, 0)


    -- (integer) start_row
    -- (integer) start_col
    -- (integer) end_row
    -- (integer) end_col
    local sRow, _, eRow, _ = ts.get_node_range(func_node)
    -- print("row: ", sRow)
    nodes[name] = { s = sRow + 1, e = eRow + 1 }
  end
  -- p(nodes)
  return nodes
end

---@param linenr integer
---@param nodes table
---@return string
function M.get_outer_or_closest(linenr, nodes)
  local distance = 100
  local fname = ''
  for name, node in pairs(nodes) do
    -- print("linenr ", linenr)
    -- print("start", node.s)
    -- print("end", node.e)
    if node.s <= linenr then
      if node.e >= linenr then
        -- print("got to here")
        return name
      end
    end
    local diff = vim.fn.abs(node.s - linenr)
    -- print("linenr ", linenr)
    -- print("diff: ", diff)
    if diff < distance then
      distance = diff
      fname = name
    end
  end
  return fname
end

return M
