if !exists('g:loaded_wisetab')
	finish
endif

let s:save_cpo = &cpo
set cpo&vim

let s:wisetab_ts = get(g:, 'wisetab_tabstop', 0)

" Used as tabstop in front of the line when &smarttab == 1
let s:wisetab_sw = get(g:, 'wisetab_shiftwidth', 0)

function! wisetab#calculateParams()
	let s:ts = s:wisetab_ts
	if s:ts == 0
		let s:ts = &softtabstop < 0 ? &shiftwidth : (&softtabstop == 0 ? &tabstop : &softtabstop)
	endif
	let s:sw = &smarttab == 1 ? s:wisetab_sw : s:ts
	if s:sw == 0
		let s:sw = &shiftwidth == 0 ? &tabstop : &shiftwidth
	endif
endfunction

function! wisetab#InsertSpaceIndent()
	let vcol = virtcol('.') - 1
	let ts = vcol == 0 ? s:sw : s:ts
	let tab = &tabstop
	let s = ''
	let tsvcol = ts * (vcol / ts + 1)
	if vcol == 0 || getline('.')[col('.') - 2] != ' '
		if ts == tab
			return "\<C-v>" . '	'
		endif
		while vcol < tsvcol
			let ntsvcol = tab * (vcol / tab + 1)
			if ntsvcol <= tsvcol
				let s = s . "\<C-v>	"
				let vcol = ntsvcol
			else
				let s = s . "\<C-v> "
				let vcol = vcol + 1
			endif
		endwhile
	else
		while vcol < tsvcol
			let s = s . "\<C-v> "
			let vcol = vcol + 1
		endwhile
	endif
	return s
endfunction

function! wisetab#CopyIndent(r)
	let achar = "a"
	let ts = &tabstop
	let pos = getpos('.')
	let r = a:r + pos[1]        " pos[1] : lnum
	let ls = getline(pos[1])    " pos[1] : lnum
	let lm = strlen(ls)
	let rs = getline(r)
	let rm = strlen(rs)
	let c = 0
	let d = 0
	let i = 0
	let j = 0
	while i < lm
		let lc = ls[i]
		if lc == ' '
			let c = c + 1
		elseif lc == '	'
			let c = c + ts - ( c % ts )
		else
			break
		endif
		let i = i + 1
	endwhile
	while j < rm && d < c
		let rc = rs[j]
		if rc == ' '
			let d = d + 1
		elseif rc == '	' && d + ts - ( d % ts ) <= c
			let d = d + ts - ( d % ts )
		else
			break
		endif
		let j = j + 1
	endwhile
	let rs = strpart(rs, 0, j)
	while d < c
		if &expandtab == 0 && d + ts - ( d % ts ) <= c
			let rs = rs . '	'
			let d = d + ts - ( d % ts )
		else
			let rs = rs . ' '
			let d = d + 1
		endif
	endwhile
	let pos[2] = strlen(rs) + 1
	let rs = rs . 'a' . strpart(ls, i)
	call setline('.', rs)
	call setpos('.', pos)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
