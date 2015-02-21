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

if mapcheck('<plug>squint_zoom_in', 'n') == ''
  nmap <plug>squint_zoom_in  [[V][:<c-u>call squint#visual_zoom_in()<cr>
endif

xmap <plug>squint_zoom_in       :<c-u>call squint#visual_zoom_in()<cr>
nmap <plug>squint_zoom_out      :<c-u>call squint#zoom_out()<cr>

if !hasmapto('<plug>squint_zoom_in', 'n')
  nmap <unique><silent> <Leader>z <plug>squint_zoom_in
endif

if !hasmapto('<plug>squint_zoom_in', 'v')
  xmap <unique><silent> <Leader>z <plug>squint_zoom_in
endif

if !hasmapto('<plug>squint_zoom_out', 'n')
  nmap <unique><silent> <Leader>Z <plug>squint_zoom_out
endif

" Support Vimoutliner
nmap <plug>squint_votl_hoist    :<c-u>call squint#votl_hoist()<cr>
nmap <plug>squint_votl_dehoist  <plug>squint_zoom_out

if !hasmapto('<plug>squint_votl_hoist', 'n')
  nmap <unique><silent> <localleader>h <plug>squint_votl_hoist
endif

if !hasmapto('<plug>squint_votl_dehoist', 'n')
  nmap <unique><silent> <localleader>Z <plug>squint_votl_dehoist
endif

" Commands: {{{1

command! -bar -nargs=0 -range Squint <line1>,<line2>call squint#range_zoom_in()

" Teardown: {{{1

let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
