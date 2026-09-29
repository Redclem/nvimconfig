local opt = vim.opt

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.number = true
opt.cursorline = true
opt.termguicolors = true

vim.o.number = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true

require("config.lazy")

plugins = {
{
  "neanias/everforest-nvim",
  version = false,
  lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  -- Optional; default configuration will be used if setup isn't called.
  config = function()
    require("everforest").setup({
      -- Your config here
      background="hard",
      
    })
  end,
},
{
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {}, -- needed even when using default config

	-- recommended: disable vim's auto-folding
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
	end,
},
{
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
},
{
	'akinsho/bufferline.nvim',
	version = "*",
	dependencies = 'nvim-tree/nvim-web-devicons'
},
{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
{
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
};
{"tpope/vim-fugitive"},
{"lewis6991/gitsigns.nvim"},
{
  "ms-jpq/coq_nvim",
  branch = "coq",
  lazy = false,
  init = function()
    vim.g.coq_settings = {
      auto_start = "shut-up", -- starts silently without popup notices
    }
    end,
  dependencies = {
    { "ms-jpq/coq.artifacts", branch = "artifacts" },
    { "ms-jpq/coq.thirdparty", branch = "3p" },
  },
},
{
  'neovim/nvim-lspconfig',
  lazy = false,
  dependencies = {
    -- main one
    { "ms-jpq/coq_nvim", branch = "coq" },

    -- 9000+ Snippets
    { "ms-jpq/coq.artifacts", branch = "artifacts" },

    -- lua & third party sources -- See https://github.com/ms-jpq/coq.thirdparty
    -- Need to **configure separately**
    { 'ms-jpq/coq.thirdparty', branch = "3p" }
    -- - shell repl
    -- - nvim lua api
    -- - scientific calculator
    -- - comment banner
    -- - etc
  },
  init = function()
    vim.g.coq_settings = {
        -- Your COQ settings here
      auto_start = "shut-up", -- starts silently without popup notices
    }
  end,
  config = function(_, opts)
    coq = require('coq')
    for server, config in pairs(opts.servers) do
      config = coq.lsp_ensure_capabilities(config.capabilities)
      vim.lsp.config(server, config)
    end
  end,

  -- example using `opts` for defining servers
  opts = {
    servers = {
      lua_ls = {},
	  clangd = {}
    }
  },
},
{"nvim-treesitter/nvim-treesitter"},
{
	"geg2102/nvim-python-repl",
	dependencies = "nvim-treesitter",
	ft = {"python", "lua", "scala"}, 
	config = function()
	require("nvim-python-repl").setup({
	    execute_on_send = false,
	    vsplit = false,
	})
end
}
}

vim.g.coq_settings = {
  auto_start = "shut-up" 
}

require("lazy").setup(plugins)

vim.o.background="dark"

vim.cmd([[colorscheme everforest]])

require("lualine").setup({
	options = {
		theme = "everforest"
	}
})

require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
	sync_install=false,
	auto_install=true,
	highlight={enable=true},
	indent={enable=true},
})

opt.foldmethod="expr"
opt.foldexpr="nvim_treesitter#foldexpr()"

require("ibl").setup()

require("nvim-tree").setup({
	update_focused_file = {
		enable = true,
		update_root = true,
	},
})

require("nvim-python-repl").setup({
    execute_on_send=true, 
    vsplit=true,
    spawn_command={
        python="ipython3", 
    }
})

vim.keymap.set("n", "<F5>s", function() require('nvim-python-repl').send_statement_definition() end)

vim.keymap.set("v", "<F5>v", function() require('nvim-python-repl').send_visual_to_repl() end)

vim.keymap.set("n", "<F5>b", function() require('nvim-python-repl').send_buffer_to_repl() end)

vim.api.nvim_create_autocmd("VimEnter", {callback = function(args) require("nvim-tree.api").tree.open() end})


require("origami").setup {
	useLspFoldsWithTreesitterFallback = {enabled = true}, -- required for `autoFold`
	pauseFoldsOnSearch = true,
	foldtext = {
		enabled = true,
		padding = {width=3},
		lineCount = {
			template = "%d lines", -- `%d` is replaced with the number of folded lines
			hlgroup = "Comment",
		},
		diagnosticsCount = true, -- uses hlgroups and icons from `vim.diagnostic.config().signs`
		gitsignsCount = true, -- requires `gitsigns.nvim`
	},
	autoFold = {
		enabled = true,
		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
	},
	foldKeymaps = {
		setup = true, -- modifies `h` and `l`
		hOnlyOpensOnFirstColumn = false,
	},
}

require("cfg_bl")
require("cfg_lsp")

