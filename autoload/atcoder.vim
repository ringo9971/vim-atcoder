scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! atcoder#Login(n, p)
	echo 'login now...'
	let login = system('curl -c '.$HOME.'/.atcoder-cookie.txt -d name='.a:n.' -d password='.a:p.' https://atcoder.jp/login?continue=https%3A%2F%2Fatcoder.jp%2Fhome')
	" let login = system('curl -c '.$HOME.'/.atcoder-cookie.txt -d name='.a:n.' -d password='.a:p.' https://arc030.contest.atcoder.jp/login?next_url=https%3A%2F%2Farc030.contest.atcoder.jp%2Fsubmissions%2Fme')
	echo 'login!'
endfunction

function! s:cpp(num) abort
  execute 'w!'
  let s:a = system('g++ -std=gnu++1y -O2 '.expand('%'))

  let s:i = 0
	while s:i < a:num-1
    let s:a = system('echo '.substitute(s:in[s:i], "\n", '', 'g').' | ./a.out')
    " 最後に改行を入れていたら消す
    let s:a = substitute(s:a, "\n$", '', '')

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
      
  let s:i = 0
	while s:i < a:num-1
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
        let s:ans = s:ans."\n".s:lines[i]
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
		let s:i += 1
	endwhile

  execute 'normal ggdG'
  execute 'r ' . s:swapfile
  execute '0 d'
  execute 'w'
endfunction

function! atcoder#AtCoder()
	if filereadable($HOME.'/.atcoder-cookie.txt' == 0) && g:atcoder_login == 1
		echo filereadable($HOME.'/.atcoder-cookie.txt')
		call atcoder#Login(g:atcoder_name, g:atcoder_pass)
	endif
  
  let s:in     = []
  let s:out    = []
  let s:y_out  = []
  let s:t_bool = []
  let s:bool = v:true
  let s:path = split(expand('%:p'), '/')
  let s:contest = s:path[-3].s:path[-2]
  let s:diff = s:path[-1][0]
  
  let s:i  = 1
  let s:ii = 1
  let s:V  = vital#atcoder#new()
  let s:T  = s:V.import('Text.Table')
	let s:table = s:T.new({
	    \   'columns': [{}, {}, {}, {}, {}], 
	    \   'header':  ['No.', 'IN', 'OUT', '結果', '判定'], 
	    \})
	let s:ac = ["    _       ____   _","   / \\     / ___| | |","  / _ \\   | |     | |"," / ___ \\  | |___  |_|","/_/   \\_\\  \\____| (_)",""]
	let s:wa = ["__        __     _      _ ","\\ \\      / /    / \\    | |"," \\ \\ /\\ / /    / _ \\   | |","  \\ V  V /    / ___ \\  |_|","   \\_/\\_/    /_/   \\_\\ (_)",""]
	
  if exists('g:atcoder_directory')
    let s:filepath = g:atcoder_directory.'/'.s:path[-3].'/'.s:path[-2]
    " フォルダがなければ作る
    if !isdirectory(s:filepath)
      call mkdir(s:filepath, 'p')
    endif
    let s:filepath = s:filepath.'/'.s:path[-1][0]
    
    " 初めてならcurl
    if !filereadable(s:filepath)
      if (s:path[-3] ==? 'abc' && s:path[-2] <# '020') || (s:path[-3] ==? 'arc' && s:path[-2] <# '035')
        if char2nr(s:diff) >= char2nr('A')
          let s:diff = nr2char(char2nr(s:diff)-16)
        else 
          let s:diff = nr2char(char2nr(s:diff)-48)
        endif
      endif

      " let s:text = system('curl -b '.$HOME.'/.atcoder-cookie.txt https://'.s:contest.'.contest.atcoder.jp/tasks/'.s:contest.'_'.s:diff)
      " echo 'https://'.s:contest.'.contest.atcoder.jp/tasks/'.s:contest.'_'.s:diff
      let s:text = system('curl -b '.$HOME.'/.atcoder-cookie.txt https://atcoder.jp/contests/'.s:contest.'/tasks/'.s:contest.'_'.s:diff)
      echo 'https://atcoder.jp/contests/'.s:contest.'/tasks/'.s:contest.'_'.s:diff
      
      call system('touch ' . s:filepath)
      let s:text = substitute(s:text, '入力例', 'nyuuryokurei',  'g')
      let s:text = substitute(s:text, '出力例', 'syuturyokurei', 'g')

      let s:i = 1
      while match(s:text, 'nyuuryokurei.\?'.nr2char(s:i+65296)) != -1
        let s:text = substitute(s:text, nr2char(s:i+65296), s:i, 'g')
        let s:i += 1
      endwhile
      call writefile([s:text], s:filepath, 'a')
    endif

    let s:text = system('cat -A ' . s:filepath)
    let s:text = substitute(s:text, '\^@', '', 'g')
    let s:text = substitute(s:text, '\^M', "\n", 'g')
    
    while match(s:text, 'nyuuryokurei.\?'.s:i) != -1
      let s:i += 1
    endwhile

    while s:ii < s:i
      let s:a = matchstr(s:text, 'nyuuryokurei.\?'.s:ii.'.\{-}syuturyokurei.\?'.s:ii)
      let s:b = matchstr(s:text, 'syuturyokurei.\?'.s:ii.'.\{-}</pre>')

      let s:a = matchstr(matchstr(s:a, 'pre.*>.\{-}</pre>'), '>.\{-}<')
      let s:b = matchstr(matchstr(s:b, 'pre.*>.\{-}</pre>'), '>.\{-}<')
      let s:b = substitute(s:b, ">\n", '>', '')
      let s:b = substitute(s:b, "\n<", '<', '')
      call add(s:out, s:b[1:-2])
      call add(s:in,  s:a[1:-2])
      let s:ii += 1
    endwhile
  else
    echo 'g:atcoder_directoryを設定して下さい'
    return
  endif

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
