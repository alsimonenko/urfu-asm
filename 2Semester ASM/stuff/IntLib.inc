; Автор: Никита Селезнев, ne.seleznev@gmail.com
;        УрФУ, ФИИТ-301, 2015
;
; Наброски для чтения целых чисел. Делал в первом семетре,
; поэтому код очень плохой :) Нужды не возникает, вот и
; не исправляю
;
; Зависимости:
;     Вроде нет
;

read_int2 proc
	push 	bx
	push 	cx
	push 	dx

	local 	temp:word ; локальная переменная
	xor 	ax, ax    ; ax = 0 для символов
	xor 	bx, bx    ; bx = 0 для знака
	int 	16h       ; getch
	xor 	ah, ah
	cmp 	al, 45    ; char '-'
	je 	negative
	jmp 	positive
 positive:
	sub 	ax, 48
	mov 	temp, ax
	jmp 	big_int
 negative:
	mov 	bx, 1
	mov 	temp, 0
	jmp 	big_int
 end_loop:
	cmp 	bx, 1
	je 	negative_1
	mov 	ax, temp
	jmp 	end_all
 negative_1:
	mov 	ax, temp
	neg 	ax
	jmp 	end_all
 big_int:
	mov 	ax, 0
	int 	16h     ; getch
	xor 	ah, ah
	;mov dx, ax
	;int 21h
	sub 	ax, 48
	mov 	cx, 9
	cmp 	ax, cx
	jg 	end_loop
	mov 	cx, 0
	cmp 	ax, cx
	jl 	end_loop

	mov 	cx, temp
	imul 	cx, 10
	add 	cx, ax
	mov 	temp, cx
	;   mov cx, ax
	;   mov ax, temp
	;   mov bx, 10
	;   imul bx
	;   add ax, cx
	;   mov temp, ax
	mov 	ax, temp
	jmp 	big_int
 end_all:
 	pop 	dx
 	pop 	cx
 	pop 	bx
 	ret
read_int2 endp

; read_int2_array proc

;         call print_open_bracket
;         xor  si, si          ; Обнуляем счетчик
;         reading_cycle:  
;             call read_int2
;             mov  array[si], ax
;             add  si, 2
;             call print_int2
;             call print_comma
;             call print_space
;             mov  ax, len
;             shl  ax, 1
;             cmp  si, ax
;             jl   reading_cycle
;         call print_backspace
;         call print_backspace
;         call print_close_bracket
;         call CRLF

;         ret
; 	; push 	bp
; 	; push 	ax
; 	; push 	bx
; 	; ; total 6

; 	; mov 	bp, sp
; 	; mov 	si, [bp+10]   ; array
; 	; mov 	bx, [bp+8]    ; len
; 	; shl 	bx, 1         ; *size(int) = 2
; 	; add 	bx, si        ; +first addr

; 	; 	mov ax,si
; 	; 	call print_int2
; 	; 	call print_space
; 	; 	mov ax,bx
; 	; 	call print_int2
; 	; 	call print_space
; 	; cmp     si, bx
; 	; je      RA_array_is_empty

; 	; call 	print_open_bracket
;  ; RA_read_loop:

; 	; 	mov ax,si
; 	; 	call print_int2
; 	; 	call print_space
; 	; 	mov ax,bx
; 	; 	call print_int2
; 	; 	call print_space
; 	; call 	read_int2
; 	; mov 	si, ax
; 	; call 	print_int2
; 	; call 	print_comma
; 	; call 	print_space

; 	; add     si, 2
; 	; cmp     si, bx
; 	; je      RA_print_end
; 	; jmp     RA_read_loop

;  ; RA_print_end:
;  ; 	call 	print_backspace
;  ; 	call 	print_backspace
; 	; call 	print_close_bracket
; 	; call 	CRLF
; 	; jmp 	RA_end

;  ; RA_array_is_empty:
;  ; 	call 	print_open_bracket
; 	; call 	print_close_bracket
; 	; call 	CRLF
; 	; jmp 	RA_end

;  ; RA_end:
; 	; pop 	bx
; 	; pop 	ax
; 	; pop 	bp
; 	; ret
; read_int2_array endp 
