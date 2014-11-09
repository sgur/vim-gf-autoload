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


function! gf#autoload#find()
  let isk = &iskeyword
  set iskeyword +=:,<,>,#
  try
    let line = getline('.')
    let start = s:find_start(line, col('.'))
    if line[start :] =~? '\%(s:\|<SNR>\|<SID>\)'
      let line = substitute(line, '<\%(SNR\|SID\)>', 's:', '')
      let path = expand('%')
    else
      let path = s:autoload_path(line[start : ])
    endif
    return empty(path) ? 0 :
          \ { 'line' : s:search_line(path, matchstr(line[start :], '\k\+'))
          \ , 'path' : path, 'col' : start}
  finally
    let &iskeyword = isk
  endtry
endfunction


function! s:autoload_path(function_name)
  let match = matchstr(a:function_name, '\k\+\ze#')
  let fname = expand('autoload/' . substitute(match, '#', '/', 'g') . '.vim')
  let paths = split(globpath(&runtimepath, fname), '\r\n\|\n\|\r')
  return len(paths) > 0 ? paths[0] : ''
endfunction


function! s:find_start(line, cursor_index)
  for i in range(a:cursor_index, 0, -1)
    if a:line[i] !~ '\k'
      return i+1
    endif
  endfor
  return 0
endfunction


function! s:search_line(path, term)
  let line = match(readfile(a:path), '\s*fu\%[nction]!\?\s*'.a:term)
  if line >= 0
    return line+1
  endif
  return 0
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
