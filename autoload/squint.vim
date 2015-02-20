" Vim global plugin to focus your attention where it's needed
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" Version:	0.1
" Description:	Zooms the current function or visual selection into a new
"		scratch buffer.
" License:	Vim License (see :help license)
" Location:	autoload/squint.vim
" Website:	https://github.com/dahu/squint
"
" See squint.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help squint

" Vimscript Setup: {{{1

let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_lib_squint")
      \ || &compatible
  let &cpo = s:save_cpo
  finish
endif
let g:loaded_lib_squint = 1

" Vim Script Information Function: {{{1

function! squint#info()
  let info = {}
  let info.name = 'squint'
  let info.version = 0.1
  let info.description = 'Focus your attention where it''s needed.'
  let info.dependencies = []
  return info
endfunction

" Library Interface: {{{1

sign define squint_first text=s< texthl=Search
sign define squint_last  text=s> texthl=Search

let s:squints = 0

function! squint#save_pos(first_line, last_line)
  let s:squints += 1
  let squint_number = s:squints
  exe ':sign place ' . s:squints . ' line=' . a:first_line . ' name=squint_first buffer=' . bufnr('%')
  let s:squints += 1
  exe ':sign place ' . s:squints . ' line=' . a:last_line  . ' name=squint_last  buffer=' . bufnr('%')
  return squint_number
endfunction

function! squint#zoom_in()
  let sel_save     = &selection
  let &selection   = "inclusive"
  let reg_save     = @@

  if visualmode() !=# 'V'
    silent exe "normal! gvVy"
  else
    silent exe "normal! gvy"
  endif

  call squint#show(split(@@, "\n", 1))

  let &selection = sel_save
  let @@ = reg_save
endfunction

function! squint#zoom_out()
  if exists('b:squint_parent')
    let parent  = b:squint_parent
    let number  = b:squint_number
    let content = getline(1, '$')
    call squint#close()

    exe 'sign jump '    . number . ' buffer=' . parent
    exe 'sign unplace ' . number . ' buffer=' . parent
    let line = line('.')

    let number += 1
    exe 'sign jump '    . number . ' buffer=' . parent
    exe 'sign unplace ' . number . ' buffer=' . parent

    exe line . ',' . line('.') . 'delete'

    call append(line - 1, content)
  endif
endfunction

function! squint#show(lines)
  let parent      = bufnr('%')
  let parent_name = bufname('%')
  let parent_alt  = bufnr('#')
  let name        = expand('%:p:t:r')
  let ext         = expand('%:e')
  let i           = 1
  let ft          = &ft
  let number      = squint#save_pos(getpos("'[")[1], getpos("']")[1])

  if exists('g:squint_dir')
    let dir = g:squint_dir
    let prefix = ''
  else
    let dir = expand('%:p:h')
    let prefix     = '.squint_'
  endif

  let newname = dir . '/' . prefix . join([i, number, name, ext], '_')
  while !empty(glob(newname))
    let i += 1
    let newname = substitute(newname, '\d\+\ze_\d\+_\f', i, '')
  endwhile

  exec 'hide edit ' . newname
  call setline(1, a:lines)
  $ g/^$/delete
  1
  let &ft = ft
  let b:squint_parent     = parent
  let b:squint_parent_alt = parent_alt
  let b:squint_number     = number
endfunction

function! squint#close()
  write
  exec 'buffer ' . b:squint_parent
  bwipe #
  if get(b:, 'squint_parent_alt', -1) != -1 && buflisted(b:squint_parent_alt)
    " XXX recent patch allows writting to @#
    exec 'buffer ' . b:squint_parent_alt
    silent! buffer #
  endif
endfunction

" Teardown:{{{1

let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
