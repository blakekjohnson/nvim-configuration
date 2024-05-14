-- Search settings
vim.cmd("set hlsearch")                   -- Highlight search results
vim.cmd("set incsearch")                  -- Incremental search

-- Tab settings
vim.cmd("set tabstop=2")                  -- Set tab width to 2
vim.cmd("set softtabstop=2")              -- Use multiple spaces for tabstops
vim.cmd("set expandtab")                  -- Convert tabs to white space

-- Indent settings
vim.cmd("set shiftwidth=2")               -- Set width for auto indent
vim.cmd("set autoindent")                 -- Enable auto indenting
vim.cmd("filetype plugin indent on")      -- Allow auto indenting based on filetype

-- Miscellaneous
vim.cmd("set number")                     -- Show line numbers
vim.cmd("set cc=80")                      -- Set column border at 80 chars
vim.cmd("syntax on")                      -- Enable syntax highlighting

-- Install plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim...')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

-- Install plugins
require('lazy').setup({
  -- Kanagawa theme
  {'rebelot/kanagawa.nvim'},

  -- LSP Support
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
    },
  },

  -- Autocomplete
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      {'L3MON4D3/LuaSnip'},
    },
  },
})

-- Set theme
vim.opt.termguicolors = true
vim.cmd.colorscheme('kanagawa-dragon')

-- Enable LSP Zero config
local lsp_zero = require('lsp-zero').preset({manage_nvim_cmp = false})
lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- Haskell
require('lspconfig').hls.setup({})
-- Lua
require('lspconfig').lua_ls.setup {
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
      return
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT'
      },
      workspace = {
        checkThirdParty = false,
        telemetry = { enable = false },
        library = {
          vim.env.VIMRUNTIME
        }
      }
    })
  end,
  settings = {
    Lua = {}
  }
}

-- Enable language servers
lsp_zero.setup_servers({'hls','lua_ls'})

-- Autocompletion keybindings
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- Enter key confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl Space opens completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Scroll up and down in completion docs
    ['<C-k>'] = cmp.mapping.scroll_docs(-4),
    ['<C-j>'] = cmp.mapping.scroll_docs(4),
  }),
})

