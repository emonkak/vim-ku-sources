" ku source: register
" Version: 0.0.0
" Copyright (C) 2010-2011 emonkak <emonkak@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Variables  "{{{1

let s:cached_items = []




" Interface  "{{{1
function! ku#register#available_sources()  "{{{2
  return ['register']
endfunction




function! ku#register#on_source_enter(source_name_ext)  "{{{2
  let _ = []
  let registers = split('"*+0123456789abcdefghijklmnopqrstuvwxyz', '.\zs')
  for i in range(0, len(registers) - 1)
    let register_type = s:register_type_from_wise_name(registers[i])
    if register_type != ''
      let body = getreg(registers[i])
      let body = body[: match(body, '.\ze[\n\r]')]
      call add(_, {
      \   'abbr': printf('%s [%s] %s', registers[i], register_type, body),
      \   'word': body,
      \   'dup': 1,
      \   'ku_register': registers[i],
      \   'ku__sort_priority': i,
      \ })
    endif
  endfor
  let s:cached_items = _
endfunction




function! ku#register#action_table(source_name_ext)  "{{{2
  return {
  \   'default': 'ku#register#action_put',
  \   'delete': 'ku#register#action_delete',
  \   'put': 'ku#register#action_put',
  \   'Put': 'ku#register#action_Put',
  \ }
endfunction




function! ku#register#key_table(source_name_ext)  "{{{2
  return {
  \   "\<C-d>": 'delete',
  \   'd': 'delete',
  \   'P': 'Put',
  \   'p': 'put',
  \ }
endfunction




function! ku#register#gather_items(source_name_ext, pattern)  "{{{2
  return s:cached_items
endfunction




" Misc.  "{{{1
function! s:register_type_from_wise_name(name)  "{{{2
  let type = getregtype(a:name)[0]
  if type ==# 'v'
    return 'char'
  elseif type ==# 'V'
    return 'line'
  elseif type =~# "^\<C-v>"
    return 'block'
  else
    return ''
  endif
endfunction




" Actions  "{{{2
function! ku#register#action_delete(item)  "{{{3
  if a:item.ku__completed_p
    call setreg(a:item.ku_register, '')
    return 0
  else
    return 'Nothing in register: ' . string(a:item.ku_register)
  endif
endfunction


function! ku#register#action_Put(item)  "{{{3
  if a:item.ku__completed_p
    execute 'normal! "' . a:item.ku_register . 'P'
    return 0
  else
    return 'Nothing in register: ' . string(a:item.ku_register)
  endif
endfunction


function! ku#register#action_put(item)  "{{{3
  if a:item.ku__completed_p
    execute 'normal! "' . a:item.ku_register . 'p'
    return 0
  else
    return 'Nothing in register: ' . string(a:item.ku_register)
  endif
endfunction




" __END__  "{{{1
" vim: foldmethod=marker
