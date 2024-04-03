local M = {}

M.setup = function()
  vim.api.nvim_create_user_command('GoRunThisTest', function()
    require('gotestit.gotestit').run_this()
  end, {})

  vim.keymap.set('n', '<leader>lTT', '<cmd>GoRunThisTest<CR>', {})
  vim.keymap.set('n', '<leader>lTG',
    '<cmd>FloatermNew --height=0.7 --width=0.7 --autoclose=0 --title=gotestsum --name=gotestsum gotestsum --format testname<CR>',
    { desc = 'GoRunAllTests' })
  vim.cmd('highlight CustomPassHighlight guifg=#181825 guibg=LightGreen')
  vim.cmd('highlight CustomFailHighlight guifg=#181825 guibg=#f38ba8')
end

return M
