" Vim global plugin to focus your attention where it's needed
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" Version:	0.1
" Description:	Zooms the current function or visual selection into a new
"		scratch buffer.
" License:	Vim License (see :help license)
" Location:	plugin/squint.vim
" Website:	https://github.com/dahu/squint
"
" See squint.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help squint

" Vimscript Setup: {{{1

let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_squint")
      \ || &compatible
  let &cpo = s:save_cpo
  finish
endif
let g:loaded_squint = 1

" Maps: {{{1

nmap <plug>squint_zoom_in :call squint#save_pos()<cr>[[V][<plug>squint_zoom_in
xmap <plug>squint_zoom_in :<c-u>call squint#zoom_in(visualmode(), 1)<cr>

if !hasmapto('<plug>squint_zoom_in', 'n')
  nmap <unique><silent> <Leader>z <plug>squint_zoom_in
endif

if !hasmapto('<plug>squint_zoom_in', 'v')
  xmap <unique><silent> <Leader>z <plug>squint_zoom_in
endif

" Teardown: {{{1

let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
