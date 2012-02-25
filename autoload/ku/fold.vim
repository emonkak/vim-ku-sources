" ku source: fold
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
function! ku#fold#available_sources()  "{{{2
  return ['fold']
endfunction




function! ku#fold#on_source_enter(source_name_ext)  "{{{2
  let _ = []

  let original_winnr = winnr()
  let original_foldtext = &l:foldtext

  try
    noautocmd wincmd p
    setlocal foldtext&

    let lnum = 1
    while lnum < line('$')
      if foldclosed(lnum) > 0
        let result = matchlist(foldtextresult(lnum),
        \                      '^+-\+\(\s*\d\+\)\slines:\s\(.\{-}\)\s*$')
        let lines = result[1]
        let text = result[2]
        call add(_, {
        \   'abbr': repeat(' ', (foldlevel(lnum) - 1) * 2) . text,
        \   'word': text,
        \   'menu': lines . ' lines',
        \   'ku__sort_priority': lnum,
        \ })
        let lnum = foldclosedend(lnum)
      endif
      let lnum += 1
    endwhile
  finally
    let &l:foldtext = original_foldtext
    execute original_winnr 'wincmd w'
  endtry

  let s:cached_items = _
endfunction




function! ku#fold#action_table(source_name_ext)  "{{{2
  return {
  \   'default': 'ku#fold#action_open',
  \   'open': 'ku#fold#action_open',
  \ }
endfunction




function! ku#fold#key_table(source_name_ext)  "{{{2
  return {
  \   'o': 'open',
  \ }
endfunction




function! ku#fold#gather_items(source_name_ext, pattern)  "{{{2
  return s:cached_items
endfunction




" Misc.  "{{{1
" Actions  "{{{2
function! ku#fold#action_open(item)  "{{{3
  call cursor(a:item.ku__sort_priority, 1)
  normal! zMzvzt
  return 0
endfunction




" __END__  "{{{1
" vim: foldmethod=marker
