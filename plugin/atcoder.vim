scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_vim_atcoder')
  finish
endif
let g:loaded_vim_atcoder = 1

command! AtCoder call atcoder#AtCoder()
command! AtCoderAddTestCase call atcoder#AddTestCase()
command! -nargs=1 AtCoderCurl call atcoder#Get(<f-args>)
command! -nargs=1 AtCoderDeleteTestCase call atcoder#DeleteTestCase(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
