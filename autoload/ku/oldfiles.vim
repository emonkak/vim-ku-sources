" ku source: fold
" Version: 0.0.0
" Copyright (C) 2016 Shota Nozaki <emonkak@gmail.com>
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
function! ku#oldfiles#available_sources()  "{{{2
  return ['oldfiles']
endfunction




function! ku#oldfiles#on_source_enter(source_name_ext)  "{{{2
  let _ = []

  redir => output
  silent oldfiles
  redir END

  for line in split(output, "\n")
    let matches = matchlist(line, '^\(\d\+\):\s\(.\+\)$')
    if !empty(matches)
      call add(_, {
      \   'word': matches[2],
      \   'menu': printf('file %*d', len(bufnr('$')), matches[1]),
      \   'ku__sort_priority': matches[1] + 0,
      \ })
    endif
  endfor

  let s:cached_items = _
endfunction




function! ku#oldfiles#action_table(source_name_ext)  "{{{2
  return {
  \   'default': 'ku#oldfiles#action_open',
  \   'open': 'ku#oldfiles#action_open',
  \ }
endfunction




function! ku#oldfiles#key_table(source_name_ext)  "{{{2
  return {
  \   "\<C-o>": 'open',
  \   'o': 'open',
  \ }
endfunction




function! ku#oldfiles#gather_items(source_name_ext, pattern)  "{{{2
  return s:cached_items
endfunction




" Misc.  "{{{1
" Actions  "{{{2
function! ku#oldfiles#action_open(item)  "{{{3
  execute 'edit' fnameescape(a:item.word)
endfunction




" __END__  "{{{1
" vim: foldmethod=marker
