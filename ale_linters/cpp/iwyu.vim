" Author: Tomota Nakamura <https://github.com/tomotanakamura>
" Description: iwyu linter for cpp files

call ale#Set('cpp_iwyu_executable', 'include-what-you-use')
call ale#Set('cpp_iwyu_options', '-std=c++14 -Wall')

function! ale_linters#cpp#iwyu#GetCommand(buffer, output) abort
    let l:cflags = ale#c#GetCFlags(a:buffer, a:output)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return '%e -S -x c++ -fsyntax-only'
    \   . ' -iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h'))
    \   . ale#Pad(l:cflags)
    \   . ale#Pad(ale#Var(a:buffer, 'cpp_iwyu_options')) . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'iwyu',
\   'output_stream': 'stderr',
\   'executable': {b -> ale#Var(b, 'cpp_iwyu_executable')},
\   'command': {b -> ale#c#RunMakeCommand(b, function('ale_linters#cpp#iwyu#GetCommand'))},
\   'callback': 'ale#handlers#gcc#HandleGCCFormatWithIncludes',
\})
