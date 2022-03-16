call plug#begin()

Plug 'navarasu/onedark.nvim'
" UI related
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'luochen1990/rainbow'
" Autocomplete
Plug 'ervandew/supertab'
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
set completeopt=menuone,noinsert,noselect,preview
set shortmess+=c

set number " Line numbers
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
" inoremap <expr> <Tab> pumvisible() ? <C-n> : <Tab>


lua <<EOF
local nvim_lsp = require'lspconfig'

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
}

require('rust-tools').setup(opts)
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

nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> ga    <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>
