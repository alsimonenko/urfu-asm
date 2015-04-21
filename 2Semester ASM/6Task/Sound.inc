; Автор: Никита Селезнев, ne.seleznev@gmail.com
;        УрФУ, ФИИТ-301, 2015
;
; Мини-библиотека для работы со звуком
; Sound 0.0.3 (от 22.04.2015)
;
; Для работы процедур необходимо иметь скалярую переменную ticks,
; а так же установить обработчик прерывания 1C catch_1C
;
; Процедура умеет отлавливать ошибки, устанавливая флаг CF, если
;     - Указана недопустимая октава
;     - Указана недопустимая нота
;     - TODO длительность
;
; Зависимости:
;     Нет
;
; Смотри пример использования player.asm
;

ticks		dw		0
notes		dw		4186, 4435, 4698, 4978, 5276, 5588, 5920, 6272, 6664, 6880, 7458, 7902

catch_1Ch:
	add		ticks, 1
	iret

; процедура reprogram_pit
; перепрограммирует канал 0 системного таймера на новую частоту
reprogram_pit      proc    near
	; Вход:
	;     bx = делитель частоты
	cli							; запретить прерывания
		mov		al,	00110110b	; канал 0, запись младшего и старшего байт
								; режим работы 3, формат счетчика - двоичный
		out		43h,al           ; послать это в регистр команд первого таймера
		mov		al,	bl            ; младший байт делителя -
		out		40h,al           ; в регистр данных канала 0
		mov		al,	bh            ; и старший байт -
		out		40h,al           ; туда же
	sti                         ; теперь IRQO вызывается с частотой
	                            ; 1 193 180/ВХ Hz
	ret
reprogram_pit      endp


play_note proc
	; Играть ноту заданной частоты, октавы и длительности
	; 
	; Вход:
	;     ah = октава (Научная нотация:
	;                  0 субконтр, 1 контр, 2 большая, 3 малая,
	;                  4 первая, ..., 8 пятая)
	;     al = нота (0 до, 1 до диез, 2 ре, ..., 11 си)
	;     bl = длительность (1  - целая,         2  - 1/2,
	;                        3  - 1/4  с точкой, 4  - 1/4,
	;                        6  - 1/8  с точкой, 8  - 1/8,
	;                        12 - 1/16 с точкой, 16 - 1/16)
	;     cx = bpm (размер 4/4, т.е. число 1/4 нот в минуту)
	; Результат:
	;     Ошибка CF=1, при недопустимом входе
	pusha		
		push ax
		mov	al, ah
		xor ah, ah
		call print_int2
		call print_space
		pop	ax

		;cmp		ah,	8
		;jg		PN_error
		;cmp		cx,	1
		;jl		PN_error
		;jmp		PN_calculate_frequency
	;PN_error:
		;popa
		;stc
		;ret

	PN_calculate_frequency:
		push	cx
		xor		cx,	cx
		mov		cl,	ah
		sub		cx, 8			; cx = степень двойки - делителя
		neg		cx				;      частоты пятой октавы

		xor		ah,	ah
		shl		ax, 1
		mov		di, offset notes
		add		di, ax
		mov		ax, [di]		; Частота ноты в пятой октаве

		shr		ax, cl			; Переведем в нужную октаву
		call print_int2
		call print_space
		pop		cx

	PN_sound_on:
		pusha
		mov		bx, ax
		mov		ax, 34ddh
		mov		dx, 12h ; частота = 1234DDh (1191340) / параметр
		cmp		dx, bx
		jnb		PN_sound_on_fail	; jnl знаковое
		div		bx
		mov		bx, ax

		in		al, 61h
		or		al, 3
		out		61h, al

		mov		al, 10000110b
		mov		dx, 43h
		out		dx, al
		dec		dx
		mov		al, bl
		out		dx, al
		mov		al, bh
		out		dx, al
		PN_sound_on_fail:
		popa

	PN_delay:
		xor		bh,	bh
		mov		ticks, 0
		cmp		bx, 3
		je		PN_delay_long
		cmp		bx, 6
		je		PN_delay_long
		cmp		bx, 12
		je		PN_delay_long
		cmp		bx, 24
		je		PN_delay_long
		jmp		PN_delay_2_n

		PN_delay_long:		; 3 -> (3/8)n, 6 -> (3/16)n
		mov		ax, bx
		mov		bx,	3
		xor		dx,	dx
		cli
			div		bx
		sti
		shl		ax, 3		; a = 3, b = 8*(bx/3)
		xchg	ax, bx
		jmp		PN_delay_ready

		PN_delay_2_n:
		mov		ax, 1

		PN_delay_ready:
		mov		dx, 17474	; Число тиков сист.таймера для	(TODO тут делитель частоты в 4 раза)
							; целой ноты при bpm=1
			mul		dx		;	dx:ax = (ax * FREQ)
		cli
			div		bx		;	ax = (ax/bx) * FREQ
		sti
		xor		dx, dx		; ax = dx:ax / cx
		cli
			div		cx		;	ax = (ax/bx) * FREQ / cx
		sti
		call print_int2
		call CRLF
		PN_delay_loop:
			cmp		ticks, ax
			jl		PN_delay_loop
	popa
	clc
	ret
play_note endp