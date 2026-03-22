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
  'neovim/nvim-lspconfig',
  dependencies = { 'saghen/blink.cmp' },

  -- example using `opts` for defining servers
  opts = {
    servers = {
      lua_ls = {},
	  clangd = {}
    }
  },
  config = function(_, opts)
    for server, config in pairs(opts.servers) do
      -- passing config.capabilities to blink.cmp merges with the capabilities in your
      -- `opts[server].capabilities, if you've defined it
      config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
      vim.lsp.config(server, config)
    end
  end	
},
{
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = { 'rafamadriz/friendly-snippets' },

  -- use a release tag to download pre-built binaries
  version = '1.*',
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
  
	  keymap = {
	  -- set to 'none' to disable the 'default' preset
	  preset = 'none',

	  ['<Up>'] = { 'select_prev', 'fallback' },
	  ['<Down>'] = { 'select_next', 'fallback' },
	  
	  -- show with a list of providers
	  ['<c-space>'] = {'show', 'fallback'},

	  -- control whether the next command will be run when using a function
	  ['<C-n>'] = { 
		function(cmp)
		  if some_condition then return end -- runs the next command
		  if some_other_condition then return "a" end -- simulate keypresses, doesn't run the next command
		  return true -- doesn't run the next command
		end,
		'select_next'
	  },
	  ["<cr>"] = {'accept', 'fallback'},
	},

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = false } },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" },
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

