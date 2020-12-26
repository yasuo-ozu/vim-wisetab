if exists('g:loaded_wisetab')
	finish
endif
let loaded_wisetab = 1

let s:save_cpo = &cpo
set cpo&vim

if &expandtab == 1
	finish
endif

augroup wisetab
	autocmd!
	autocmd OptionSet smarttab,shiftwidth,softtabstop,tabstop :call wisetab#calculateParams()
augroup END

call wisetab#calculateParams()

inoremap <silent> <expr> <C-i> wisetab#InsertSpaceIndent()
inoremap <silent> <CR> <CR>a<BS><ESC>:call wisetab#CopyIndent(-1)<CR>i<Right><BS>
nnoremap <silent> <nowait> o oa<BS><Esc>:call wisetab#CopyIndent(-1)<CR>i<Right><BS>
nnoremap <silent> <nowait> O Oa<BS><Esc>:call wisetab#CopyIndent(1)<CR>i<Right><BS>

let &cpo = s:save_cpo
unlet s:save_cpo
