; ����� ��������, ����-301, 2015
; ���� ���� ࠡ��� � ��㪮�
; ������ ��⨬���஢����� � ��饭��� ����� piano

.286
.model tiny
.code
ORG 100h

@entry:		jmp		@start

buffer		db		10h dup (?) 
head		dw		0
tail		dw		0
old_09h		dw		?, ?
notes		dw		1047, 1109, 1175, 1245, 1319, 1397, 1480, 1568, 1661, 1720, 1867, 1976


get_notes_ax_th proc
	; ����� ������� � ����஬ ax �� notes
	; �室: ax = 0,1,2,...,11
		shl		ax, 1
		mov 	di, offset notes
		add		di, ax
		mov		ax, [di]
	ret
get_notes_ax_th endp


catch_09h:
	pusha
		in		al,	60h				; ᪠�-��� ��᫥���� ����⮩ (�� 60 ����)

		mov		di,		tail
		mov		buffer[di],	al
		inc		tail
		and		tail,	0Fh
		mov		ax,		tail
		cmp		head,	ax
		jne		@catch_09h_put
		inc		head
		and		head,	0Fh

	@catch_09h_put:
		in		al,		61h
		or		al,		80h
		out		61h,	al
		and		al,		07Fh
		out		61h,	al
		mov		al,		20h
		out		20h,	al			; �����⭮�� ����஫���� �㦥� ᨣ��� ....
	popa
	iret


@start:
	mov		ax, 3509h			; ��।���� ���祭�� ��ண� ����� INT 09h
	int		21h
	cli
	mov		[old_09h],	bx		; ���࠭�� ��� � ��६�����
	mov		[old_09h+2],es
	mov		ax, 2509h			; ��⠭���� ���� ����� ���뢠��� INT 09h
	mov		dx, offset catch_09h
	int		21h
	sti

@infinity_loop:
		xor		ah, ah
		mov		di,	tail
		mov		al,	buffer[di-1]

		cmp		al, 81h				; �᫨ �� �⦠⨥ ������ Esc
		jne		lets_play			; �����訬 �믮������ �ணࠬ��

		in		al, 61h
		and		al, not 3
		out 	61h, al

		mov		ax, 2509h			; ����⠭�������� ����� 21h
		mov		dx, word ptr cs:[old_09h]
		mov		ds, word ptr cs:[old_09h+2]
		int		21h
		ret

	lets_play:
		push ax
		
		; �� 1234567890-=
		cmp		al, 2
		jl		goto_print_or_stop
		cmp		al, 13
		jle		first_octave

		; �� qwertyuiop[]
		cmp		al, 16
		jl		goto_print_or_stop
		cmp		al, 27
		jle		small_octave
		
		; �� asdfghjkl;'
		; Enter -> big_octave
		cmp		al, 28
		jne		_not_enter_key
		mov		al, 41 ; L(38) ;(39) '(40) => Enter(41)
		_not_enter_key:
		cmp		al, 30
		jl		goto_print_or_stop
		cmp		al, 41
		jle		big_octave
		
		; �� zxcvbnm,./ shift
		; TODO ��-����� �ਤ㬠�� :)
		cmp		al, 44
		jl		goto_print_or_stop
		cmp		al, 54
		jle		conter_octave

		; �� F1F2F3F4F5F6F7F8F9F10F11F12
		cmp		al, 59
		jl		goto_print_or_stop
		cmp		al, 69
		jle		second_octave
		; F11 F12 -> second_octave
		cmp		al, 87
		je		second_octave
		cmp		al, 88
		je		second_octave
		
		goto_print_or_stop:
			jmp print_or_stop

	second_octave:
		sub		ax, 59
		call	get_notes_ax_th
		shr		ax, 1
		jmp		start_sound

	first_octave:
		sub		ax, 2
		call	get_notes_ax_th
		shr		ax, 2
		jmp		start_sound

	small_octave:
		sub		ax, 16
		call	get_notes_ax_th
		shr		ax, 3
		jmp		start_sound

	big_octave:
		sub		ax, 30
		call	get_notes_ax_th
		shr		ax, 4
		jmp		start_sound

	conter_octave:
		sub		ax, 44
		call	get_notes_ax_th
		shr		ax, 5
		jmp		start_sound

	start_sound:
		mov		bx, ax
		mov		ax, 34ddh
		mov		dx, 12h ; ���� = 1234DDh (1191340) / ��ࠬ���
		cmp		dx, bx
		jnb		print_or_stop	; jnl ��������
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

	print_or_stop:
		pop ax
		
		cmp		ax, 01h				; pressed escape
		je		stop_sound
		cmp		ax, 39h				; pressed space
		je		stop_sound
		jmp		@infinity_loop

	stop_sound:
		in		al, 61h
		and		al, not 3
		out 	61h, al
jmp	@infinity_loop

end		@entry