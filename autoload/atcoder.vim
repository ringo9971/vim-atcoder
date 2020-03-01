scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim


let s:in = []
let s:out = []
let s:y_out = []
let s:t_bool = []
let s:bool = v:true

function! atcoder#Login(n, p)
	echo 'login now...'
	let login = system('curl -c '.$HOME.'/.atcoder-cookie.txt -d name='.a:n.' -d password='.a:p.' https://arc030.contest.atcoder.jp/login?next_url=https%3A%2F%2Farc030.contest.atcoder.jp%2Fsubmissions%2Fme')
	echo 'login!'
endfunction

function! s:cpp(num) abort
  let s:a = system('g++ -std=gnu++1y -O2 '.expand('%'))

  let s:i = 0
	while s:i < a:num-1
    let s:a = system('echo '.substitute(s:in[s:i], '\n', '', 'g').' | ./a.out')
    " 最後に改行を入れていたら消す
    let s:a = substitute(s:a, '\n$', '', '')

		call add(s:y_out, s:a)
		if s:a != s:out[s:i]
			call add(s:t_bool, 'WA')
			let s:bool = v:false
		else
			call add(s:t_bool, 'AC')
		endif
		let s:test_num = s:i+1

		call s:table.add_row([s:test_num, s:in[s:i], s:out[s:i], s:y_out[s:i], s:t_bool[s:i]])
		let s:i += 1
	endwhile
endfunction

function! s:vimscript() abort
  let s:scriptfile = '~/vimscript.vim'
  let s:swapfile = '~/vimswap.vim'

  execute 'w! ' . s:swapfile

  let s:lines = getline(1, line('$'))
  for i in range(0, len(s:lines)-1)
    if s:lines[i][0] !=# ':'
      let s:lines[i] = ':normal ' . s:lines[i]
      call setline(i+1, s:lines[i])
    endif
  endfor
  execute 'w! ' . s:scriptfile
      
	while s:i < s:ii-1
    if &filetype ==# 'cpp'
      let s:a = system('echo '.substitute(s:in[s:i], '\n', '', 'g').' | ./a.out')
      let s:a = split(s:a, '\n')[0]
    elseif &filetype ==# 'vim'
      execute 'normal ggdG'
      call append(line('$'), s:in[0])
      execute '0 d'

      execute 'so ' . s:scriptfile
    endif


		" call add(s:y_out, s:a)
		" if s:a != s:out[s:i]
		" 	call add(s:t_bool, 'WA')
		" 	let s:bool = v:false
		" else
		" 	call add(s:t_bool, 'AC')
		" endif
		" let s:test_num = s:i+1
		" call s:table.add_row([s:test_num, s:in[s:i], s:out[s:i], s:y_out[s:i], s:t_bool[s:i]])
		let s:i += 1
	endwhile
  
endfunction

function! atcoder#AtCoder()
	if filereadable($HOME.'/.atcoder-cookie.txt' == 0) && g:atcoder_login == 1
		echo filereadable($HOME.'/.atcoder-cookie.txt')
		call atcoder#Login(g:atcoder_name, g:atcoder_pass)
	endif
  
  let s:path = split(expand('%:p'), '/')
  let s:contest = s:path[-3].s:path[-2]
	let s:text = system('curl -b '.$HOME.'/.atcoder-cookie.txt https://'.s:contest.'.contest.atcoder.jp/tasks/'.s:contest.'_'.s:path[-1][0])
  
	let s:i = 1
	let s:V = vital#atcoder#new()
	let s:T = s:V.import('Text.Table')
	let s:table = s:T.new({
	    \   'columns': [{}, {}, {}, {}, {}], 
	    \   'header':  ['No.', 'IN', 'OUT', '結果', '判定'], 
	    \})
	let s:ac = ["    _       ____   _","   / \\     / ___| | |","  / _ \\   | |     | |"," / ___ \\  | |___  |_|","/_/   \\_\\  \\____| (_)",""]
	let s:wa = ["__        __     _      _ ","\\ \\      / /    / \\    | |"," \\ \\ /\\ / /    / _ \\   | |","  \\ V  V /    / ___ \\  |_|","   \\_/\\_/    /_/   \\_\\ (_)",""]
	
	while match(s:text, '入力例.'.s:i) != -1
		let s:i += 1
	endwhile
	let s:ii = 1
	while s:ii < s:i
		let s:a = matchstr(s:text, '入力例.'.s:ii.'.*出力例.'.s:ii)
		let s:b = matchstr(s:text, '出力例.'.s:ii.'.\{-}</pre>')
		let s:a = matchstr(s:a, '<pre>.*</pre>')
    let s:b = substitute(s:b, '', '', 'g')
		call add(s:out, s:b[21:-8])
		call add(s:in,  s:a[5:-9])
		let s:ii += 1
	endwhile

  if &filetype ==# 'cpp'
    call s:cpp(s:ii)
  elseif &filetype ==# 'vim'
    call s:vimscript(s:ii)
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
