"=============================================================================
" FILE: autoload/gf/function.vim
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


function! gf#function#find()
  let line = getline('.')
  let start = s:find_start(line, col('.'))
  let match = matchstr(line[start :], '\k\+\ze#')
  let fname = expand(
        \ 'autoload/'
        \ . substitute(match, '#', '/', 'g')
        \ . '.vim')
  let path = globpath(&rtp, fname)
  return !empty(path) ? {
        \ 'path' : path,
        \ 'line' : s:search_line(path, matchstr(line[start :], '\k\+')),
        \ 'col'  : start,
        \ }
        \ : 0
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
  let line = match(readfile(a:path), '\%(fu\|function\)!\?\s*'.a:term)
  if line >= 0
    return line+1
  endif
  return 0
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
