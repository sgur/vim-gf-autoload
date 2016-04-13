"=============================================================================
" FILE: autoload/gf/autoload.vim
" AUTHOR: sgur <sgurrr+vim@gmail.com>
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
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim


function! gf#autoload#find() abort
  if &filetype isnot# 'vim'
    return 0
  endif
  let isk = &l:iskeyword
  setlocal iskeyword+=:,<,>,#
  try
    let line = getline('.')
    let start = s:find_start(line, col('.'))
    if line[start :] =~? '\%(s:\|<SNR>\|<SID>\)'
      let line = substitute(line, '<\%(SNR\|SID\)>', 's:', '')
      let path = expand('%')
    else
      for base_dir in (exists('b:autoload_gf_basedir') ? [b:autoload_gf_basedir] : [])
            \ + [getcwd()] + split(finddir('autoload', expand('%:p:h') . ';')) + [&runtimepath]
        let path = s:autoload_path(base_dir, line[start : ])
        if !empty(path)
          break
        endif
      endfor
    endif
    return empty(path) ? 0 :
          \ { 'line' : s:search_line(path, matchstr(line[start :], '\k\+'))
          \ , 'path' : path, 'col' : start}
  finally
    let &l:iskeyword = isk
  endtry
endfunction


if has('patch-7.4.279')
  function! s:globpath(path, expr) abort "{{{
    return globpath(a:path, a:expr, 1, 1)
  endfunction "}}}
else
  function! s:globpath(path, expr) abort "{{{
    return split(globpath(a:path, a:expr), '\n')
  endfunction "}}}
endif


function! s:autoload_path(base_dir, function_name) abort "{{{
  let match = matchstr(a:function_name, '\k\+\ze#')
  let fname = expand('autoload/' . substitute(match, '#', '/', 'g') . '.vim')
  let paths = s:globpath(a:base_dir, fname)
  return len(paths) > 0 ? paths[0] : ''
endfunction "}}}


function! s:find_start(line, cursor_index) abort "{{{
  for i in range(a:cursor_index, 0, -1)
    if a:line[i] !~ '\k'
      return i+1
    endif
  endfor
  return 0
endfunction "}}}


function! s:search_line(path, term) abort "{{{
  let line = match(readfile(a:path), '\s*fu\%[nction]!\?\s*' . a:term . '\>')
  if line >= 0
    return line+1
  endif
  return 0
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
