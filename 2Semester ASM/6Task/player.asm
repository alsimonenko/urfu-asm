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
old_1Ch		dw		?, ?
ticks		dw		0
notes		dw		4186, 4435, 4698, 4978, 5276, 5588, 5920, 6272, 6664, 6880, 7458, 7902
prompt		db		'���ந�������� ��㪮� ��אַ㣮�쭮� ����� �१ PC-ᯨ���.'					,0Ah,0Dh
			db		'�ᯮ�짮�����: TODO player.com [䠩�], �ଠ� ���ண� ���ᠭ � README.TXT'	,0Ah,0Dh
			db		'+ 㢥����� ⥬�, - 㬥����� ⥬�, Escape - ��室.'							,0Ah,0Dh,'$'
FileName	db		'C:\2Semes~1\6Task\123.txt',0	; 䠩� ��� �⥭��
Handle		dw		?									; Handle 䠩��
current_note	db	'$','$','$','$','$','$','$'
file_not_found_msg	db	'���� �� ������!'															,'$'
access_denied_msg	db	'�������筮 �ࠢ ��� �⥭�� 䠩��!'										,'$'

duration	db		1,      4, 4, 4, 4, 2,4,    4, 2,4,    4, 2,4,    4, 4, 4, 4, 4, 1
len			dw		$-duration

melody2		db		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
octave2		db		3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3
duration2	db		1, 4, 2, 4, 3, 4, 4, 4, 6, 4, 8, 4,12, 4,16, 4,24, 4,32
len2		dw		$-duration2 


include	SexyPrnt.inc
include	Sound.inc

catch_09h:
	push	ax
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
	pop		ax
	iret


char_to_int10 proc						; ��ॢ�� ᨬ���� � �᫮
	; �室:
	;     al = ������
	; �������:
	;     al = �᫮ [0...9]
	; �訡��:
	;     ���� CF = 1
	;     �����४�� ᨬ��� ��� �᭮����� ��⥬� ��᫥���
		cmp		al, 48
		jl		AI10_incorrect
		sub		al, 48	; '0' -> 0
		cmp		al, 10
		jge		AI10_incorrect
	AI10_success:
		clc
		ret
	AI10_incorrect:
		stc
		ret	
char_to_int10 endp

char_to_note proc						; ��ॢ�� ᨬ���� � ����
	; �室:
	;     ah = ��� [A, B, C, D, E, F, G]
	;     al = ['b', '#', ' '] (����, 'F#', 'Db', 'G ')
	; �������:
	;     al = �᫮ [0...11]
		push	bx
		mov		bl, al

		cmp		ah,	'B'
		jle		CtN_AB
		cmp		ah,	'E'
		jle		CtN_CDE
		cmp		ah,	'G'
		jle		CtN_FG

	CtN_AB:
		sub		ah, 'A'
		mov		al, ah
		xor		ah, ah
		shl		ax, 1
		add		ax, 9
		jmp		CtN_diez_bemole
	CtN_CDE:
		sub		ah, 'C'
		mov		al, ah
		xor		ah, ah
		shl		ax, 1
		jmp		CtN_diez_bemole
	CtN_FG:
		sub		ah, 'F'
		mov		al, ah
		xor		ah, ah
		shl		ax, 1
		add		ax, 5
		;jmp	CtN_diez_bemole
	CtN_diez_bemole:
		cmp		bl, 'b'
		je		CtN_bemole
		cmp		bl, '#'
		je		CtN_diez
		jmp		CtN_exit
	CtN_bemole:
		dec		ax
		jmp		CtN_exit
	Ctn_diez:
		inc		ax
		;jmp	CtN_exit
	CtN_exit:
		pop		bx
		ret	
char_to_note endp

char_to_duration proc					; ��ॢ�� ᨬ���� � �த����⥫쭮���
	; �室:
	;     ah = ���� ᨬ���
	;     al = ��ன ᨬ���
	;     bl = ��⨩ ᨬ��� ('.' ��� ' ')
	; �������:
	;     bl = �᫮ [1,2,(3),4,(6),8,(12),16,(24),32]
	push ax
	push cx
		call	char_to_int10
		jnc		CtD_double_digit

		mov		al,	ah
		call	char_to_int10
		xor		ah,	ah
		jmp		CtD_optional_dot

	CtD_double_digit:
		push	cx
		mov		cl, al
		mov		al,	ah
		call	char_to_int10

		mov		dl,	10
		mul		dl
		add		al,	cl
		pop		cx

	CtD_optional_dot:
		cmp		bl, '.'
		jne		CtD_exit

		xor		ah,	ah
		shr		ax,	1
		mov		dx,	ax
		shr		dx,	1
		add		ax,	dx
	CtD_exit:
		mov		bl,	al
		pop cx
		pop ax
		ret	
char_to_duration endp


file_errors:
	cmp		ax,	2
	je		file_not_found
	cmp		ax,	3
	je		file_not_found	; path
	cmp		ax,	4
	je		file_not_found
	cmp		ax,	5
	je		access_denied
	cmp		ax,	6
	je		file_not_found
	cmp		ax,	12
	je		access_denied

	file_not_found:
		lea		dx, file_not_found_msg
		jmp		print_and_exit
	access_denied:
		lea		dx, access_denied_msg
		;jmp	print_and_exit
	print_and_exit:
		mov		ah,	09h
		int		21h
		ret

@start:
	mov		ah, 09h
	lea		dx, prompt
	int		21h

	; ����⥫� ����� (�⠭���⭮ FFFFh - 18.2 ࠧ� � ᥪ㭤�)
	mov		bx,	4000h
	call	reprogram_pit

	open_file:
		mov		ax, 3D00h
		lea		dx, FileName
		int		21h
		jnc		set_pointer_to_file

		file_errors_trace1:
			jmp	file_errors
	; ��⠭�������� 㪠��⥫� � ��砫� 䠩��
	set_pointer_to_file:
		mov		Handle, ax
		mov		bx, ax
		mov		ax, 4200h	; ��⠭���� 㪠��⥫� ��
		xor		cx, cx		; ������ 0*64K + 0
		xor		dx, dx
		int		21h
		jc		file_not_found

	; ��⠭���� ��ࠡ��稪 INT 09h � ��࠭�� ����
	mov		ax, 3509h
	int		21h
	mov		[old_09h],	bx
	mov		[old_09h+2],es
	mov		ax, 2509h
	mov		dx, offset catch_09h
	cli
		int		21h
	sti
	; ��⠭���� ��ࠡ��稪 INT 1�h � ��࠭�� ����
	mov		ax, 351Ch
	int		21h
	mov		[old_1Ch],	bx
	mov		[old_1Ch+2],es
	mov		ax, 251Ch
	mov		dx, offset catch_1Ch
	cli
		int		21h
	sti

	mov		ah, 3Fh				; ��⠥�
	mov		bx, Handle			;   �� 䠩��
	mov		cx, 6				;     6 ����
	lea		dx, current_note	;       � ���� current_note
	int		21h
	jnc		parse_bpm

	file_errors_trace2:
		jmp		file_errors_trace1

	parse_bpm:
		; TODO optimize
		xor		cx,	cx				; cx = bpm =
		mov		dl,	10

		mov		al,	current_note[0]
		call	char_to_int10
		mul		dl
		mul		dl
		add		cx,	ax				;            [0]*100

		mov		al,	current_note[1]
		call	char_to_int10
		mul		dl
		add		cx,	ax				;              + [1]*10

		mov		al,	current_note[2]
		call	char_to_int10
		add		cx,	ax				;                + [2]

@music_box:

	get_scan_code:
		mov		di,	tail
		mov		al,	buffer[di-1]

		cmp		al, 81h				; �᫨ �� �⦠⨥ ������ Esc
		je		music_box_exit		; �����訬 �믮������ �ணࠬ��
		cmp		al, 0Dh				; �᫨ �� ����⨥ ������ +,
		je		music_box_increase	;     㢥��稬 ⥬�
		cmp		al, 0Ch				; �᫨ �� �⦠⨥ ������ -,
		je		music_box_decrease	;     㬥��訬 ⥬�

	lets_play:
		push	cx
			mov		ah,	3Fh				; ��⠥�
			mov		bx,	Handle			;   �� 䠩��
			mov		cx,	6				;     6 ����
			lea		dx,	current_note	;       � ���� current_note
			int		21h
		pop	cx
		jc		file_errors_trace2

		test	ax,	ax
		jz		music_box_exit

								lea dx, current_note
								call print_dx_string

								call print_open_bracket
								call print_int2
								call print_close_bracket
								call CRLF

		mov		al,	current_note[0]
		call	char_to_int10
		mov		dh, al

		mov		ah, current_note[1]
		mov		al, current_note[2]
		call	char_to_note
		mov		dl, al

		mov		ah,	current_note[3]
		mov		al,	current_note[4]
		mov		bl,	current_note[5]
		call	char_to_duration		; bl = �த����⥫쭮��� (���)
		mov		ah,	dh					; ah = ��⠢�
		mov		al,	dl					; al = ���
		call	play_note

		jmp		@music_box
	
	music_box_increase:				; �����稬 ⥬� �� 6,25%
		mov		ax,	cx
		shr		ax, 4
		add		cx,	ax
		jmp		lets_play

	music_box_decrease:				; �����訬 ⥬� �� 6,25%
		mov		ax,	cx
		shr		ax, 4
		sub		cx,	ax
		jmp		lets_play

	music_box_exit:
		; �몫�稬 �������
		in		al, 61h
		and		al, not 3
		out 	61h, al
		; ����⠭�������� ����� 09h
		mov		ax, 2509h
		mov		dx, word ptr cs:[old_09h]
		mov		ds, word ptr cs:[old_09h+2]
		cli
			int		21h
		sti
		; ����⠭�������� ����� 1Ch
		mov		ax, 251Ch
		mov		dx, word ptr cs:[old_1Ch]
		mov		ds, word ptr cs:[old_1Ch+2]
		cli
			int		21h
		sti
		; ���஥� 䠩�
		mov		ah, 3Eh
		mov		bx, Handle
		int		21h
		ret

end		@entry