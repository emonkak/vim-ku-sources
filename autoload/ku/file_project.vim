" ku source: file_project
" Version: 0.0.0
" Copyright (C) 2012 emonkak <emonkak@gmail.com>
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

let s:cached_items = {}




" Interface  "{{{1
function! ku#file_project#available_sources()  "{{{2
  return ['file_project']
endfunction




function! ku#file_project#on_source_enter(source_name_ext)  "{{{2
  let s:cached_items = {}
  call ku#file_rec#on_source_enter(a:source_name_ext)
endfunction




function! ku#file_project#action_table(source_name_ext)  "{{{2
  return ku#file#action_table(a:source_name_ext)
endfunction




function! ku#file_project#key_table(source_name_ext)  "{{{2
  return ku#file#key_table(a:source_name_ext)
endfunction




function! ku#file_project#gather_items(source_name_ext, pattern)  "{{{2
  let directories = split(getcwd(), ku#path_separator(), !0)
  \               + split(a:pattern, ku#path_separator())

  while !empty(directories)
    let project_path = join(directories, ku#path_separator())
    if has_key(s:cached_items, project_path)
      return s:cached_items[project_path]
    endif

    let git_dir = ku#make_path(project_path, '.git')
    if isdirectory(git_dir) || filereadable(git_dir)
      let items = s:gather_items_from_git(project_path, a:pattern)
      let s:cached_items[project_path] = items
      return items
    endif

    call remove(directories, -1)
  endwhile

  return ku#file_rec#gather_items(a:source_name_ext, a:pattern)
endfunction




function! ku#file_project#acc_valid_p(source_name_ext, item, sep)  "{{{2
  return ku#file#acc_valid_p(a:source_name_ext, a:item, a:sep)
endfunction




" Misc.  "{{{1
function! s:gather_items_from_git(project_path, pattern)  "{{{2
  let _ = []

  let original_cwd = getcwd()
  if original_cwd < a:project_path
    cd `=a:project_path`
  endif
  let result = system('git ls-files -vcm')
  cd `=original_cwd`

  if v:shell_error != 0
    return _
  endif

  let TAGS = {
  \   'H': 'cached',
  \   'S': 'skip',
  \   'M': 'unmerged',
  \   'R': 'deleted',
  \   'C': 'modified',
  \   'K': 'killed',
  \ }

  for entry in split(result, "\n")
    let [tag, file] = split(entry, '^\S\zs\s', !0)
    let file = a:pattern . substitute(file, '/$', '', '')

    call add(_, {
    \   'word': file,
    \   'abbr': file . (isdirectory(file) ? ku#path_separator() : ''),
    \   'menu': get(TAGS, tag, 'other'),
    \   'ku__sort_priority': tag ==# '?',
    \ })
  endfor

  return _
endfunction




" __END__  "{{{1
" vim: foldmethod=marker
