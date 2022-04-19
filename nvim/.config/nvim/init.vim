call plug#begin()

Plug 'nvim-telescope/telescope-ui-select.nvim'

Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'terrortylor/nvim-comment'
" Tabs
Plug 'kyazdani42/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'

Plug 'navarasu/onedark.nvim'
" UI related
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'luochen1990/rainbow'
" Autoclose
Plug 'jiangmiao/auto-pairs'
" Rust
Plug 'simrat39/rust-tools.nvim'
Plug 'hrsh7th/vim-vsnip'
Plug 'nvim-lua/popup.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'neovim/nvim-lsp'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'mfussenegger/nvim-dap'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/nvim-cmp'
Plug 'Chiel92/vim-autoformat'
call plug#end()

" Sets

set termguicolors

set completeopt=menuone,noinsert,noselect,preview
set shortmess+=c

set number relativenumber " Line numbers

" Turn off backup
set nobackup
set noswapfile
set nowritebackup
" Search configuration
set ignorecase                    " ignore case when searching
set smartcase                     " turn on smartcase
" Tab and Indent configuration
set autoindent noexpandtab tabstop=2 shiftwidth=2
" Set Split directions
set splitbelow
set splitright

set updatetime=300
" Show diagnostic popup on cursor hold
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
" Vars

" Themes
let g:onedark_config = {
			\ 'style': 'warmer',
			\ 'transparent': v:true,
			\ 'diagnostics': {
				\ 'background': v:false,
				\},
				\}
colorscheme onedark
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
" UI configuration
syntax on
syntax enable
"let g:indentLine_char_list = ['|', '¦', '┆', '┊']
" Airline
let g:airline_left_sep  = ''
let g:airline_right_sep = ''
let g:airline#extensions#ale#enabled = 1
let airline#extensions#ale#error_symbol = 'E:'
let airline#extensions#ale#warning_symbol = 'W:'

" binds
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-L> <C-W><C-L>
nnoremap <silent>ff <cmd>Telescope find_files<cr>
nnoremap <esc> :noh<cr>
autocmd BufWrite * :Autoformat

autocmd InsertEnter * :silent !qwer
autocmd InsertLeave * :silent !qwfp
autocmd VimEnter * :silent !qwfp
autocmd VimLeave * :silent !qwer

nnoremap <Tab> <cmd>BufferNext<cr>
nnoremap <S-Tab> <cmd>BufferPrevious<cr>
nmap <C-_> <cmd>CommentToggle<cr>
" inoremap <expr> <Tab> pumvisible() ? <C-n> : <Tab>


lua <<EOF
local nvim_lsp = require'lspconfig'

vim.cmd [[
highlight! DiagnosticLineNrHint guifg=#0000FF gui=bold
highlight! DiagnosticLineNrInfo guifg=#00FFFF gui=bold
highlight! DiagnosticLineNrWarn guifg=#FFA500 gui=bold
highlight! DiagnosticLineNrError guifg=#FF0000 gui=bold

sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
]]

local extension_path = vim.env.HOME .. '/.config/nvim/misc/vadimcn.vscode-lldb-1.7.0/'
local codelldb_path = extension_path .. 'adapter/codelldb'
local liblldb_path = extension_path .. 'lldb/lib/liblldb.so'

local opts = {
	tools = { -- rust-tools options
	autoSetHints = true,
	hover_with_actions = true,
	inlay_hints = {
		},
	},

-- all the opts to send to nvim-lspconfig
-- these override the defaults set by rust-tools.nvim
-- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
server = {
	-- on_attach is a callback called when the language server attachs to the buffer
	-- on_attach = on_attach,
	settings = {
		-- to enable rust-analyzer settings visit:
		-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
		["rust-analyzer"] = {
			-- enable clippy on save
			checkOnSave = {
				command = "clippy"
				},
			}
		}
	},
dap = {
	adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path)
	},
}

require('rust-tools').setup(opts)
local dap, dapui = require('dap'), require('dapui')

local lldb_host = "127.0.0.1"
local lldb_port = 34567

dap.configurations.rust = {
	{
			name = "Debug",
			type = "lldb",
			request = "launch",
			host = lldb_host,
			port = lldb_port,
			program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}

dap.adapters.lldb = function(callback, config)
callback({ type = "server", host = config.host, port = config.port })
end

dap.listeners.after.event_initialized["dapui_config"] = function()
dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
dapui.close()
end

EOF


" Setup Completion
" See https://github.com/hrsh7th/nvim-cmp#basic-configuration
lua <<EOF
local cmp = require'cmp'
cmp.setup({
-- Enable LSP snippets
snippet = {
	expand = function(args)
	vim.fn["vsnip#anonymous"](args.body)
end,
},
mapping = {
	['<C-p>'] = cmp.mapping.select_prev_item(),
	['<C-n>'] = cmp.mapping.select_next_item(),
	-- Add tab support
	['<S-Tab>'] = cmp.mapping.select_prev_item(),
	['<Tab>'] = cmp.mapping.select_next_item(),
	['<C-d>'] = cmp.mapping.scroll_docs(-4),
	['<C-f>'] = cmp.mapping.scroll_docs(4),
	['<C-Space>'] = cmp.mapping.complete(),
	['<C-e>'] = cmp.mapping.close(),
	['<CR>'] = cmp.mapping.confirm({
	behavior = cmp.ConfirmBehavior.Insert,
	select = true,
	})
},

-- Installed sources
sources = {
	{ name = 'nvim_lsp' },
	{ name = 'vsnip' },
	{ name = 'path' },
	{ name = 'buffer' },
	},
})
EOF

lua << EOF
--require('vgit').setup() -- Git Gutter
--require "lsp_signature".setup({})
require('nvim_comment').setup()
require('indent_blankline').setup({
show_current_context = true,
show_current_context_start = true,
})
-- This is your opts table
require("telescope").setup {
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown {
				-- even more opts
				}
			}
		}
	}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")
EOF

nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
"nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> ga    <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>

nnoremap <silent> gb <cmd>lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> gq <cmd>!~/.config/nvim/misc/vadimcn.vscode-lldb-1.7.0/adapter/./codelldb --liblldb ~/.config/nvim/misc/vadimcn.vscode-lldb-1.7.0/lldb/lib/liblldb.so --port 34567 &<CR><cmd>lua require'dap'.continue()<CR>
nnoremap <silent> gi <cmd>lua require'dap'.step_into()<CR>
nnoremap <silent> go <cmd>lua require'dap'.step_over()<CR>
