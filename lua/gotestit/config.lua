local M = {}

M.config = {
  commands = {
    gotestsum = 'gotestsum'
  }
}

M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  vim.cmd('highlight CustomPassHighlight guifg=#181825 guibg=LightGreen')
  vim.cmd('highlight CustomFailHighlight guifg=#181825 guibg=#f38ba8')

  vim.api.nvim_create_user_command('GoRunThisTest', function()
    require('gotestit.gotestit').run_this()
  end, {})

  vim.api.nvim_create_user_command('GoRunAllTests',
    '<cmd>FloatermNew --height=0.7 --width=0.7 --autoclose=0 --title=gotestsum --name=gotestsum ' ..
    M.config.commands.gotestsum .. '  --format testname<CR>',
    {})
end

return M
