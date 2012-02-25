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

let s:cached_items = []




" Interface  "{{{1
function! ku#file_project#available_sources()  "{{{2
  return ['file_project']
endfunction




function! ku#file_project#on_before_action(source_name_ext, item)  "{{{2
  if has_key(a:item, '_ku_project_path')
    let a:item.word = ku#make_path(a:item._ku_project_path, a:item.word)
  endif
  return a:item
endfunction




function! ku#file_project#on_source_enter(source_name_ext)  "{{{2
  let s:cached_items = []
  let directories = split(getcwd(), ku#path_separator(), !0)

  while !empty(directories)
    let project_path = join(directories, ku#path_separator())

    if isdirectory(ku#make_path(project_path, '.git'))
      let s:cached_items = s:gather_items_from_git(project_path)
      break
    else
      " TODO: Supports other VCS
    endif

    call remove(directories, -1)
  endwhile

  if empty(s:cached_items)
    call ku#file_rec#on_source_enter(a:source_name_ext)
  endif
endfunction




function! ku#file_project#action_table(source_name_ext)  "{{{2
  return ku#file#action_table(a:source_name_ext)
endfunction




function! ku#file_project#key_table(source_name_ext)  "{{{2
  return ku#file#key_table(a:source_name_ext)
endfunction




function! ku#file_project#gather_items(source_name_ext, pattern)  "{{{2
  if !empty(s:cached_items)
    return s:cached_items
  else
    return ku#file_rec#gather_items(a:source_name_ext, a:pattern)
  endif
endfunction




function! ku#file_project#acc_valid_p(source_name_ext, item, sep)  "{{{2
  if !empty(s:cached_items)
    return 0
  else
    return ku#file#acc_valid_p(a:source_name_ext, a:item, a:sep)
  endif
endfunction




function! ku#file_project#special_char_p(source_name_ext, char)  "{{{2
  if !empty(s:cached_items)
    return 0
  else
    return ku#file#special_char_p(a:source_name_ext, a:char)
  endif
endfunction




" Misc.  "{{{1
function! s:gather_items_from_git(project_path)  "{{{2
  let _ = []

  if type(a:project_path) == type([])
    let project_path = a:project_path
  else
    let project_path = [a:project_path]
  endif

  let original_cwd = getcwd()
  cd `=ku#make_path(project_path)`
  let result = system('git ls-files -vcmo')
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
    let [tag, file] = split(entry, '^\S\s\zs', !0)
    let target = project_path + [file]

    if isdirectory(ku#make_path(target))
      " It's submodule
      call extend(_, s:gather_items_from_git(target))
    else
      call add(_, {
      \   'menu': get(TAGS, tag, 'other'),
      \   'word': ku#make_path(project_path[1:] + [file]),
      \   '_ku_project_path': project_path[0],
      \   'ku__sort_priority': tag ==# '?',
      \ })
    endif
  endfor

  return _
endfunction




" __END__  "{{{1
" vim: foldmethod=marker

