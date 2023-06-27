{ config, pkgs, ... }:
let
  color = pkgs.writeText "color.vim" (import ./theme.nix config.colorscheme);
in
{
  imports = [
    ./lsp.nix
    ./syntaxes.nix
    ./ui.nix
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    #extraPackages = with pkgs; [];

    plugins = with pkgs.vimPlugins; [
      # core
      vim-sensible
      vim-surround
      vim-repeat
      vim-unimpaired
      vim-tmux-focus-events

      # navigation
      ranger-vim
      popup-nvim
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim # do make?

      # other
      vim-LanguageTool
      nerdcommenter
      emmet-vim
      vim-argwrap
      targets-vim
    ];

    # TODO config
    extraConfig = /* vim */ ''
    " Section: Options
    " configure persistent undo
    set undodir=~/.vim/undodir
    set undofile

    " store all backups and swapfiles in one spot
    set backupdir=~/.vim/backupdir
    set directory=~/.vim/swapdir

    set clipboard+=unnamed " always use the clipboard for all operations
    set hidden " hide buffer instead of unloading it.
    set textwidth=80
    set conceallevel=1 " uses pretty characters
    set ignorecase " searches are case insensitive...
    set smartcase  " ... unless they contain at least one capital letter
    set number " show line numbers
    set relativenumber " use relative numbers
    set suffixes+=.pyc " also ignore these in filename completion
    set splitright " vertical splits go right
    set splitbelow " horizontal splits go below
    set wildmode=longest,list " complete command line on longest substring, then list alternatives
    set wildignore+=*/cache,*/vendor,*/env,*.pyc,*/venv,*/__pycache__,*/.git,*/node_modules " ignore in tab-completion
    set autowrite " write file before changing buffer with some commands
    set formatoptions=tcqjn1 " t - autowrap normal text
                             " c - autowrap comments
                             " q - gq formats comments
                             " j - remove comment leader when joining
                             " n - autowrap lists
                             " 1 - break _before_ single-letter words
    set signcolumn=yes " always show
    set showmatch " show matching bracket when inserted
    set timeoutlen=300 " lower number for whichkey

    " Section: Maps
    " Set custom leader key
    let mapleader = " "
    let maplocalleader = " "

    " Useful macros I use the most
    nmap \A :set formatoptions+=a<CR>:echo "autowrap enabled"<CR>
    nmap \a :set formatoptions-=a<CR>:echo "autowrap disabled"<CR>
    nmap \n :setlocal number! relativenumber!<CR>:setlocal number? relativenumber?<CR>
    nmap \x :cclose<CR> " close quickfix
    nmap \h :syntax sync fromstart<CR> " refresh syntax highlighting
    nmap <Leader>h :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':'''<CR><CR>

    " Correct next line jump within wrapped lines
    nmap j gj
    nmap k gk

    " Don't interrupt visual mode indent
    vnoremap < <gv
    vnoremap > >gv

    " Edit last buffer
    nmap <C-e> :e#<CR>

    " Super fast window movement shortcuts
    nnoremap <C-J> <C-W><C-J>
    nnoremap <C-K> <C-W><C-K>
    nnoremap <C-L> <C-W><C-L>
    nnoremap <C-H> <C-W><C-H>
    nnoremap <C-]> <C-w><C-]>

    " Visual mode pressing * or # searches for the current selection
    vnoremap <silent> * :<C-u>call VisualSelection(''', ''')<CR>/<C-R>=@/<CR><CR>
    vnoremap <silent> # :<C-u>call VisualSelection(''', ''')<CR>?<C-R>=@/<CR><CR>

    " Select the stuff I just pasted
    nnoremap gV `[V`]

    " Swap CTRL=] and g CTRL-] to make :tjump the default
    nnoremap <c-]> g<c-]>
    vnoremap <c-]> g<c-]>
    nnoremap g<c-]> <c-]>
    vnoremap g<c-]> <c-]>

    " Section: Autocommands
    augroup vimrc
        autocmd!

        " Reload vimrc automatically when editing
        autocmd! BufWritePost ~/.vimrc source $MYVIMRC
        autocmd! BufWritePost .vimrc source $MYVIMRC " Editing in dotfiles repo

        " vue syntax always messes up
        "autocmd FileType vue syntax sync fromstart

        " Debugging helpers
        autocmd BufEnter *.py iabbr xxx print("XXX",
        autocmd BufEnter *.py iabbr yyy print("YYY",
        autocmd BufEnter *.py iabbr zzz print("ZZZ",
        autocmd BufEnter *.js iabbr xxx console.log("XXX",
        autocmd BufEnter *.js iabbr yyy console.log("YYY",
        autocmd BufEnter *.js iabbr zzz console.log("ZZZ",
        autocmd BufEnter *.jsx iabbr xxx console.log("XXX",
        autocmd BufEnter *.jsx iabbr yyy console.log("YYY",
        autocmd BufEnter *.jsx iabbr zzz console.log("ZZZ",
        autocmd BufEnter *.vue iabbr xxx console.log("XXX",
        autocmd BufEnter *.vue iabbr yyy console.log("YYY",
        autocmd BufEnter *.vue iabbr zzz console.log("ZZZ",

        " Django templates
        autocmd BufNewFile,BufEnter,BufRead *templates/*.html setf htmldjango
        autocmd FileType htmldjango setlocal commentstring={#\ %s\ #}
        " Disable autowrapping in Django templates
        autocmd FileType htmldjango setlocal formatoptions-=t

        " Column highlighting
        autocmd BufNewFile,BufRead * call matchadd('ColorColumn', '\%81v', 80)
        autocmd BufNewFile,BufRead * call matchadd('Error', '\%121v', 100)


        " Section: Plugins
        " telescope
        nnoremap ; <cmd>Telescope buffers<CR>
        nnoremap <Leader>ff <cmd>Telescope find_files<CR>
        nnoremap <Leader>fF <cmd>Telescope git_files<CR>
        nnoremap <Leader>fg <cmd>Telescope live_grep<CR>
        nnoremap <Leader>fG <cmd>Telescope live_grep<CR>
        nnoremap <Leader>fT <cmd>Telescope tags<CR>
        nnoremap <Leader>ft <cmd>Telescope current_buffer_tags<CR>
        nnoremap <Leader>fl <cmd>Telescope lsp_references<CR>

        " ranger
	map <leader>rr :RangerEdit<cr>
        map <leader>rv :RangerVSplit<cr>
        map <leader>rs :RangerSplit<cr>
        map <leader>rt :RangerTab<cr>
        map <leader>ri :RangerInsert<cr>
        map <leader>ra :RangerAppend<cr>
        map <leader>rc :set operatorfunc=RangerChangeOperator<cr>g@
        map <leader>rd :RangerCD<cr>
        map <leader>rld :RangerLCD<cr>

	" Lightline
        " If this comes after we set our colorscheme than lightline won't properly set it's own colors.
        let g:lightline = {
            \'colorscheme': 'default',
            \}
        "let g:lightline.component_expand = {
        "    \'linter_checking': 'lightline#ale#checking',
        "    \'linter_warnings': 'lightline#ale#warnings',
        "    \'linter_errors': 'lightline#ale#errors',
        "    \'linter_ok': 'lightline#ale#ok',
        "    \}
        let g:lightline.component_type = {
            \'linter_checking': 'left',
            \'linter_warnings': 'warning',
            \'linter_errors': 'error',
            \'linter_ok': 'left',
            \}
        let g:lightline.active = {
            \'right': [[ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok', 'lineinfo', 'percent', 'fileformat', 'fileencoding', 'filetype' ]]
            \}
        let g:lightline.component = {
            \'filename': "%{expand('%:p:h:t')}/%t"
            \}

	" Surround shortcut to correctly wrap word
        nmap ysw ysiW

        " nerdcommenter support for vue files
        let g:ft = '''
        function! NERDCommenter_before()
          if &ft == 'vue'
            let g:ft = 'vue'
            let stack = synstack(line('.'), col('.'))
            if len(stack) > 0
              let syn = synIDattr((stack)[0], 'name')
              if len(syn) > 0
                exe 'setf ' . substitute(tolower(syn), '^vue_', ''', ''')
              endif
            endif
          endif
        endfunction
        function! NERDCommenter_after()
          if g:ft == 'vue'
            setf vue
            let g:ft = '''
          endif
        endfunction

	" Argwrap
        nnoremap <leader>W :ArgWrap<CR>
        let g:argwrap_tail_comma = 1

        " LanguageTool
        let g:languagetool_cmd='/usr/bin/languagetool'
        let g:languagetool_lang='en-CA'

        " treesitter
        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
        set nofoldenable  " Disable folding at startup.

        " indent-blankline
        highlight IndentBlanklineChar guifg=#e4e4e4 gui=nocombine
        let g:indent_blankline_use_treesitter = v:true
        let g:indent_blankline_show_first_indent_level = v:false
        let g:indent_blankline_filetype = ['vim', 'python', 'html', 'htmldjango', 'javascript', 'jsx', 'vue', 'css', 'scss']
    '';
    extraLuaConfig = /* lua */ ''
    '';
  };

  xdg.configFile."nvim/init.lua".onChange = ''
    XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
    for server in $XDG_RUNTIME_DIR/nvim.*; do
      nvim --server $server --remote-send ':source $MYVIMRC<CR>' &
    done
  '';

  xdg.desktopEntries = {
    nvim = {
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "nvim %F";
      icon = "nvim";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
      terminal = true;
      type = "Application";
      categories = [ "Utility" "TextEditor" ];
    };
  };
}
