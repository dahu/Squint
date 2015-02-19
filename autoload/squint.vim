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
  let info.dependencies = [{'name': 'vimple', 'version': 0.9}]
  return info
endfunction

" Library Interface: {{{1

sign define squint text=s> texthl=Search

let s:squints = 0

function! squint#save_pos()
  let s:squints += 1
  exe ':sign place ' . s:squints . ' line=' . (line('.') - 1) . ' name=squint buffer=' . bufnr('%')
endfunction

function! squint#zoom_in(type, ...)
  let sel_save     = &selection
  let &selection   = "inclusive"
  let reg_save     = @@
  let ft           = &ft
  let parent       = bufnr('%')
  let parent_name  = bufname('%')

  call squint#save_pos()

  if a:0
    silent exe "normal! gvd"
  elseif a:type == 'line'
    silent exe "normal! '[V']d"
  else
    silent exe "normal! `[v`]d"
  endif

  call squint#show(split(@@, "\n"))

  let &ft = ft
  let b:zoom_parent = parent
  let b:squint = s:squints

  let &selection = sel_save
  let @@ = reg_save
endfunction

function! squint#zoom_out()
  if exists('b:zoom_parent')
    let parent   = b:zoom_parent
    let squint   = b:squint
    let content  = getline(1, '$')
    call squint#close()

    exe 'sign jump '    . squint . ' buffer=' . parent
    exe 'sign unplace ' . squint . ' buffer=' . parent
    call append(line('.'), content)
  endif
endfunction

function! squint#show(lines)
  let parent = bufnr('%')
  let parent_alt = bufnr('#')
  let dir = expand('%:p:h')
  let name = expand('%:p:t:r')
  let ext = expand('%:e')
  let i = 1
  let newname = dir . '/.squint_' . i . '_'. name . ext
  " XXX is newname persistant? how long should it exists? What happens with
  " nested zoom-in?
  while !empty(glob(newname))
    let i += 1
    let newname = substitute(newname, '/\.squint_\d\+', i, '')
  endwhile
  exec 'hide edit ' . newname
  call setline(1, a:lines)
  let b:squint_parent = parent
  let b:squint_parent_alt = parent_alt
endfunction

function! squint#close()
  " XXX Do we want to keep this file?
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
