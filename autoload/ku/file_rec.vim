" ku source: file_rec
" Version: 0.0.0
" Copyright (C) 2011 emonkak <emonkak@gmail.com>
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

let g:ku_file_rec_ignore_pattern =
\ get(g:, 'ku_file_rec_ignore_pattern', '\.\(dll\|exe\|hi\|o\|swp\)$')
let g:ku_file_rec_max_candidates =
\ get(g:, 'ku_file_rec_max_candidates', 1000)




" Interface  "{{{1
function! ku#file_rec#available_sources()  "{{{2
  return ['file_rec', 'file_rec/current']
endfunction




function! ku#file_rec#on_source_enter(source_name_ext)  "{{{2
  let _ = 'ku#file#on_source_enter'
  if exists('*{_}')
    call {_}(a:source_name_ext)
  endif
endfunction




function! ku#file_rec#on_source_leave(source_name_ext)  "{{{2
  let _ = 'ku#file#on_source_leave'
  if exists('*{_}')
    call {_}(a:source_name_ext)
  endif
endfunction




function! ku#file_rec#on_before_action(source_name_ext, item)  "{{{2
  let _ = 'ku#file#on_before_action'
  if exists('*{_}')
    return {_}(a:source_name_ext, a:item)
  endif
endfunction




function! ku#file_rec#action_table(source_name_ext)  "{{{2
  return ku#file#action_table(a:source_name_ext)
endfunction




function! ku#file_rec#key_table(source_name_ext)  "{{{2
  return ku#file#key_table(a:source_name_ext)
endfunction




function! ku#file_rec#gather_items(source_name_ext, pattern)  "{{{2
  let items = []
  let directories = [{'abbr': a:pattern}]

  while !empty(directories)
  \     && len(items) + len(directories) < g:ku_file_rec_max_candidates
    let directory = remove(directories, 0)
    for item in ku#file#gather_items(a:source_name_ext, directory.abbr)
      if item.word !~# g:ku_file_rec_ignore_pattern
        call add(item.menu ==# 'dir' ? directories : items, item)
      endif
    endfor
  endwhile

  return extend(items, directories)
endfunction




function! ku#file_rec#acc_valid_p(source_name_ext, item, sep)  "{{{2
  return ku#file#acc_valid_p(a:source_name_ext, a:item, a:sep)
endfunction




function! ku#file_rec#special_char_p(source_name_ext, char)  "{{{2
  return ku#file#special_char_p(a:source_name_ext, a:char)
endfunction




" __END__  "{{{1
" vim: foldmethod=marker
