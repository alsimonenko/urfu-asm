; ����� ��������, ����-301, 2015
; ���� ���� ࠡ��� � ��㪮�
; ������ ��⨬���஢����� � ��饭��� ����� piano

.286
.model tiny
.code
ORG 80h
	cmd_len		label byte		; ����� ��㬥�⮢ ��������� ��ப�
	cmd_line	label byte		; ��㬥��� ��������� ��ப�
ORG 100h

@entry:		jmp		@start

buffer		db		10h dup (?) 
head		dw		0
tail		dw		0
old_09h		dw		?, ?
old_1Ch		dw		?, ?
prompt		db		'���ந�������� ��㪮� ��אַ㣮�쭮� ����� �१ PC-ᯨ���.'					,0Ah,0Dh
			db		'�ᯮ�짮�����: TODO player.com [䠩�], �ଠ� ���ண� ���ᠭ � README.TXT'	,0Ah,0Dh
			db		'+ 㢥����� ⥬�, - 㬥����� ⥬�, Escape - ��室.'							,0Ah,0Dh,'$'
l_button	dw		0

include	SexyPrnt.inc
include	ChVideo.inc

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

catch_l_button:
	mov		l_button, 1
	retf


@start:
	;mov		ah, 09h
	;lea		dx, prompt
	;int		21h
	mov		al, 4
	call	change_video_mode
	mov		al, 0
	call	change_display_page

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

	mov		ax,	00
	int		33h ; mouse interrupt
	; (if AX=FFFFh mouse is installed, if 0000 not, DX - number of mouse buttons)

	cmp ax,	0
	ja @music_box ; if AX &gt; 0 lets start!

	mov ah,4ch
	int 21h ;else just exit
	 	 
	mov ax,01 
	int 33h

	mov		ax, 0000Ch
	mov		cx, 8
	lea		dx, catch_l_button
	push	cs
	pop		es
	int		33h

@music_box:

	get_scan_code:
		;mov		ax, l_button
		;call print_int2

		cmp		l_button, 1
		je		music_box_exit

		mov		di,	tail
		mov		al,	buffer[di-1]

		cmp		al, 81h				; �᫨ �� �⦠⨥ ������ Esc
		je		music_box_exit		; �����訬 �믮������ �ணࠬ��
	smth:

		mov ax,03 ; function to get mouse position and buttons
		int 33h
		 
		mov ax, dx ; Y coord to AX
			;call print_int2
			;call print_space
		mov dx, 320
		 
		mul dx ; multiply AX by 320
		add ax,cx ; add X coord 
			push ax
			mov ax, cx
			;call print_int2
			;call CRLF
			pop ax

		; (Now currsor position is in AX, lets draw the pixel there)
		;mov di,ax
		;mov ax,0B800h
		;mov es,ax
		;mov dl,12 ; red color ;)
		;mov es:[di],dl ; and we have the pixel drawn

		;By default mouse resolution is 640x200, lets set it to 320x200 (monitor height is already set, lets just set the width)
		;mov ax, 7
		;mov cx,0 ; min pos
		;mov dx,640 ; max pos
		;int 33h

		jmp		@music_box

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
		ret

end		@entry