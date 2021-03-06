scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

py3file <sfile>:h:h/src/atcoder.py

let s:ac = ["    _       ____   _","   / \\     / ___| | |","  / _ \\   | |     | |"," / ___ \\  | |___  |_|","/_/   \\_\\  \\____| (_)",""]
let s:wa = ["__        __     _      _ ","\\ \\      / /    / \\    | |"," \\ \\ /\\ / /    / _ \\   | |","  \\ V  V /    / ___ \\  |_|","   \\_/\\_/    /_/   \\_\\ (_)",""]

function! s:cpp() abort
  execute 'w!'
  let s:a = system('g++ -std=gnu++17 -O2 ' . expand('%'))

  for s:i in range(len(s:in))
    let s:a = system('echo ' . substitute(substitute(s:in[s:i], '\n', ' ', 'g'), '\((\|)\|#\|\.\)', '\\\1', 'g') . ' | ./a.out')[:-2]

		call add(s:y_out, s:a)
		if s:a !=# s:out[s:i] && s:out[s:i] !=# ''
			call add(s:t_bool, 'WA')
			let s:bool = v:false
		else
			call add(s:t_bool, 'AC')
		endif
		let s:test_num = s:i+1
    call s:table.add_row([s:test_num, s:in[s:i], s:out[s:i], s:y_out[s:i], s:t_bool[s:i]])
    if s:i != len(s:in)-1
    call s:table.add_row(['', '', '', '', ''])
    endif
  endfor
endfunction

function! s:vimscript(num) abort
  let s:scriptfile = '~/vimscript.vim'
  let s:swapfile = '~/vimswap.vim'

  execute 'w! ' . s:swapfile

  let s:lines = getline(1, line('$'))
  " ZZの削除
  echo s:lines[len(s:lines)-1]
  if s:lines[len(s:lines)-1] ==# 'ZZ'
    call remove(s:lines, len(s:lines)-1)
  else
    for i in range(0, len(s:lines)-1)
      let s:lines[i] = substitute(s:lines[i], 'ZZ', '', 'g')
    endfor
  endif

  " scriptfileの書き換え
  execute 'normal ggdG'
  for i in range(0, len(s:lines)-1)
    if s:lines[i][0] !=# ':'
      let s:lines[i] = ':normal ' . s:lines[i]
    endif
    call append(line('$'), s:lines[i])
  endfor
  execute 'w! ' . s:scriptfile
      
  for s:i in range(len(s:in))
    execute 'normal ggdG'
    call append(line('$'), s:in[s:i])
    execute '0 d'

    execute 'so ' . s:scriptfile

    let s:lines = getline(1, line('$')-1)
    let s:ans = ''
    for i in range(len(s:lines))
      if i ==# 0
        let s:ans = s:lines[0]
      else
        let s:ans = s:ans . "\n" . s:lines[i]
      endif
    endfor

    if s:ans ==# s:out[s:i]
      call add(s:t_bool, 'AC')
    else
      call add(s:t_bool, 'WA')
      let s:bool = v:false
    endif

		call add(s:y_out, s:ans)

		call s:table.add_row([s:i+1, s:in[s:i], s:out[s:i], s:y_out[s:i], s:t_bool[s:i]])
  endfor

  execute 'normal ggdG'
  execute 'r ' . s:swapfile
  execute '0 d'
  execute 'w'
endfunction

function! atcoder#submit(...) abort
  if a:0 >= 1
    let s:contest = split(a:1, '/')[4]
    let s:diff = a:1[-1:-1]
  endif
  python3 submit(vim.eval('s:contest'), vim.eval('s:diff'), vim.eval('expand("%:p")'))
endfunction

function! atcoder#Curl(n) abort
  python3 getText(vim.eval('a:n'))
  echo a:n

  call system('touch ' . s:filepath)

  let s:i = 1
  let s:input = []
  let s:output = []
  while match(s:text, '入力例.\?' . s:i) != -1
    call add(s:input, '入力例 ' . s:i)
    call add(s:input, substitute(s:text, '.\{-}入力例.\?' . s:i . '.\{-}pre.\{-}>\(\s\|\n\|\)*\(.\{-}\)\(\s\|\n\|\)*</pre>.*', '\2', ''))
    call add(s:input, '入力例 ' . s:i)
    call add(s:output, '出力例 ' . s:i)
    call add(s:output, substitute(s:text, '.\{-}出力例.\?' . s:i . '.\{-}pre.\{-}>\(\s\|\n\|\)*\(.\{-}\)\(\s\|\n\|\)*</pre>.*', '\2', ''))
    call add(s:output, '出力例 ' . s:i)
    let s:i += 1
  endwhile

  call writefile(s:input, s:filepath, 'a')
  call writefile(s:output, s:filepath, 'a')
endfunction

function! atcoder#Getpath() abort
  let s:path = split(expand('%:p'), '/')
  let s:filepath = g:atcoder_directory . '/' . s:path[-3] . '/' . s:path[-2]
  " フォルダがなければ作る
  if !isdirectory(s:filepath)
    call mkdir(s:filepath, 'p')
  endif
  let s:filepath = g:atcoder_directory . '/' . s:path[-3] . '/' . s:path[-2] . '/' . substitute(s:path[-1], '\..*$', '', 'g')
  return s:filepath
endfunction

function! atcoder#Get(n) abort
  let s:filepath = atcoder#Getpath()
  if filereadable(s:filepath)
    call system('rm ' . s:filepath)
  endif
  call atcoder#Curl(a:n)
  call atcoder#AtCoder()
endfunction

function! atcoder#AddTestCase() abort
  if !exists('s:filepath')
    echo '先に:AtCoderをして下さい'
    return
  endif

  let s:i = 1
  let s:text = join(readfile(s:filepath), "\n")
  while match(s:text, '入力例.\?' . s:i) != -1
    let s:i += 1
  endwhile

  let s:text = readfile(expand('%:p'))
  let s:input = []
  let s:output = []
  if count(s:text, '')
    let s:flag = v:false
    for i in s:text
      if i ==# ''
        let s:flag = v:true
      endif
      if !s:flag
        call add(s:input, i)
      else
        call add(s:output, i)
      endif
    endfor
  else
    let s:input = s:text
  endif
  let s:output = s:output[1:]

  let s:list = []
  call add(s:list, '入力例 ' . s:i)
  for i in s:input
    call add(s:list, i)
  endfor
  call add(s:list, '入力例 ' . s:i)
  if s:output != []
    call add(s:list, '出力例 ' . s:i)
    for i in s:output
      call add(s:list, i)
    endfor
    call add(s:list, '出力例 ' . s:i)
  endif
  let s:i += 1

  call writefile(s:list, s:filepath, 'a')
endfunction

function! atcoder#DeleteTestCase(num) abort
  if !exists('s:filepath')
    echo '先に:AtCoderをして下さい'
    return
  endif

  let s:text = join(readfile(s:filepath), "\n")
  if matchstr(s:text, '入力例 ' . a:num) != -1
    let s:text = substitute(s:text, '入力例 ' . a:num . '.*入力例 ' . a:num, '', '')
  endif
  if matchstr(s:text, '出力例 ' . a:num) != -1
    let s:text = substitute(s:text, '出力例 ' . a:num . '.*出力例 ' . a:num, '', '')
  endif

  let s:num = a:num
  while matchstr(s:text, '入力例 ' . string(s:num+1)) !=# ''
    let s:text = substitute(s:text, '入力例 ' . string(s:num+1), '入力例 ' . s:num, 'g')
    let s:text = substitute(s:text, '出力例 ' . string(s:num+1), '出力例 ' . s:num, 'g')
    let s:num += 1
  endwhile


  call writefile([s:text], s:filepath)
endfunction

function! atcoder#AtCoder()
	if filereadable($HOME . '/.atcoder-cookie.txt' == 0) && g:atcoder_login == 1
		echo filereadable($HOME . '/.atcoder-cookie.txt')
		" call atcoder#Login(g:atcoder_name, g:atcoder_pass)
	endif
  
  let s:in     = []
  let s:out    = []
  let s:y_out  = []
  let s:t_bool = []
  let s:bool = v:true
  let s:path = split(expand('%:p'), '/')
  let s:contest = s:path[-3] . s:path[-2]
  let s:diff = s:path[-1][0]
  
  let s:i  = 1
  let s:V  = vital#atcoder#new()
  let s:T  = s:V.import('Text.Table')
	let s:table = s:T.new({
	    \   'columns': [{}, {}, {}, {}, {}], 
	    \   'header':  ['No.', 'IN', 'OUT', '結果', '判定'], 
	    \})
	
  if exists('g:atcoder_directory')
    let s:filepath = atcoder#Getpath()
    
    " 初めてならcurl
    if !filereadable(s:filepath)
      if (s:path[-3] ==? 'abc' && s:path[-2] <# '020') || (s:path[-3] ==? 'arc' && s:path[-2] <# '035')
        if char2nr(s:diff) >= char2nr('A')
          let s:diff = nr2char(char2nr(s:diff)-16)
        else 
          let s:diff = nr2char(char2nr(s:diff)-48)
        endif
      endif
      call atcoder#Curl('https://atcoder.jp/contests/' . s:contest . '/tasks/' . s:contest . '_' . s:diff)
    endif

    let s:text = join(readfile(s:filepath), "\n")
    let s:text = substitute(s:text, '', '', 'g')

    let s:i = 1
    while match(s:text, '入力例\s' . s:i) != -1
      call add(s:in,  matchstr(s:text, '入力例\s' . s:i . '.\{-}入力例')[11+strlen(s:i):-11])
      call add(s:out, matchstr(s:text, '出力例\s' . s:i . '.\{-}出力例')[11+strlen(s:i):-11])
      let s:i += 1
    endwhile
  else
    echo 'g:atcoder_directoryを設定して下さい'
    return
  endif

  if &filetype ==# 'cpp'
    call s:cpp()
  elseif &filetype ==# 'vim'
    call s:vimscript()
  else
    echo '未対応言語です'
    return
  endif

	if s:bool == v:true
		let s:winac = popup_create(s:ac, {'border': [1, 1, 1, 1], 'borderchars': ['-', '|', '-', '|', '+', '+', '+', '+'], 'moved': 'any', 'line': 2, })
		let s:winid = popup_create(s:table.stringify(), {'line': 10, 'moved': 'any'})
	else
		let s:winwa = popup_create(s:wa, {'border': [1, 1, 1, 1], 'borderchars': ['-', '|', '-', '|', '+', '+', '+', '+'], 'moved': 'any', 'line': 2, })
		let s:winid = popup_create(s:table.stringify(), {'line': 10, 'moved': 'any'})
	endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
