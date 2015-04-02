; ����� ��������, ����-301, 2015
;
; ������ ᨬ����� (����誠 �� 1 ��५�):
; ascii.com (\d) (\d)
; 
; ���ᮢ��� ��� ��� ⥪�⮢��� �����-०��� � ��࠭���
; ��ᨢ�� �������� ⠡���� ᨬ����� �� 業��� �࠭�
;  ____________
; |_|0_1_2_._F_|
; |0|          |
; |1|          |
; |.|  ASCIIs  |
; |F|__________|
.286
.model tiny
.code

ORG 2Ch
	env_ptr		label word		; ��।����� ���� ��� ����㯠 � ᫮�� � PSP, ���஥
								; 㪠�뢠�� �� ᥣ����, ᮤ�ঠ騩 ���� ����樮���� �।�
								; (���筮 �᢮��������� ��� ᮧ����� ������⭮�� १�����)
ORG 80h
	cmd_len		label byte		; ����� ��㬥�⮢ ��������� ��ப�
	cmd_line	label byte		; ��㬥��� ��������� ��ப�
ORG 100h

@entry:
		jmp			@start

include SexyPrnt.inc			; >= 1.3
include CmdArg.inc				; >= 0.9.5
include	ChVideo.inc


write_to_video proc
	push cx
		mov		cx, 40			; ��ਭ� ⠡���� 40
		loop1:
			mov		dl, [si]
			mov		es:[di], dl
			inc		si
			add		di, 2
		loop	loop1
	pop	cx
	ret
write_to_video endp


int_to_char proc
	; �室:      cl - �᫮
	; �������: dl - ᨬ���
		mov		dl, cl
		cmp		dl, 9
		jg		ItC_HEX
		add		dl, '0'
		ret
	ItC_HEX:
		sub		dl, 10
		add		dl, 'A'
		ret
int_to_char endp


draw_ascii_table proc			; ���ᮢ�� ASCII-⠡����
	; �室:       ���
	; �������:
	;     (���� CF = 1, �᫨ ⥪�騩 �����-०�� �� ⥪�⮢�)
		pusha

		mov		ah, 0Fh					; ����� ⥪�騩 �����-०��
		int		10h						; �室:  ���
										; ��室: al = ⥪�騩 ०�� (�. �㭪�� 00h)
										;        ah = �᫮ ⥪�⮢�� ������� �� �࠭�
										;        bh = ����� ��⨢��� ��࠭��� ��ᯫ��
		cmp		al, 7
		mov		dx, 0B000h				; ���� ᥣ���� �����-���� 7 ०���
		je		DAT_draw_ascii
		cmp		al, 3
		jle		DAT_noerror
		stc
		popa
		ret
	
	DAT_noerror:
		mov 	dx, 0B800h				; ���� ᥣ���� �����-���� 0,1,2,3 ०����

	DAT_draw_ascii:

		mov		es, dx					; ��⠭���� ᥣ���� �����-����

		; ��४��稬�� �� �㦭�� ��࠭���
		cmp		al, 1
		jle		DAT_shift_800
		shl		bh, 4					; ��� 2-3,7 (25x80) ᤢ��� �� 1000h
		jmp		DAT_shifted
		DAT_shift_800:
			shl		bh, 3				; ��� 0-1 (25x40) ᤢ��� �� 800h,
		DAT_shifted:
			xor		bl, bl

		; ��४��稬 ��࠭��� +(800h ��� 1000h)*(����� ���)
		mov		di, bx					; ��⠭���� ���� �����祭�� � (B800 ��� B000):di

		; �ய��⨬ ���� �� ��ப� (���.०���, ��࠭���, ⥪�� this_is_ascii)
		xor		ch, ch
		mov		cl, ah					; cx <- �᫮ ������� (�.�. �ਭ� ��ப� �࠭�)
		imul	cx, 6					; (�� 2 ����)*(3 ��ப�) = 6
		add		di, cx

		; ���᫨� ����� �� ⠡���� (�।�., �� �ਭ� �⭠�)
		mov		al, ah
		xor		ah, ah
		sub		ax, 40					; �� �᫠ ������� ���⥬ �ਭ� (40 <=)
		;shr		ah, 1				; � ������� �� ��� (��⥬ 㬭���� �� ���,
		;shl		ah, 1				; �.�. ��� ���� �����-���� 2 ����)

		; � ᤢ���� �� ��砫� ⠡����
		add		di, ax

		mov		si, offset line_1		; ��㤠 �⠥�
		call	write_to_video

		add		di, ax					; � ��砫� ⠡���� �� ᫥�.��ப�
		add		di, ax
		mov		si, offset line_2		; ��㤠 �⠥�
		call	write_to_video

		add		di, ax					; � ��砫� ⠡���� �� ᫥�.��ப�
		add		di, ax
		mov		si, offset line_3		; ��㤠 �⠥�
		call	write_to_video

		mov		cx, 0
		DAT_lines_loop:
			add		di, ax					; � ��砫� ⠡���� �� ᫥�.��ப�
			add		di, ax
			mov		si, offset line_2		; �����⠥� ������ ��ப� ⠡���� � �࠭�栬�
			call	write_to_video

			push	di						; � ��⮬ �㤥� ��ࠢ����
				sub		di, 40 *2			; ����� �� �ਭ� ⠡���� (40)
				add		di, 2  *2			; ��������� �� ����� ������� �१ "� "
				call	int_to_char
				mov		es:[di], dl			; ����� ������� (0...F)
				add		di, 4  *2			; ��������� �� ���� ��� �१ "n � "
				
				mov		dx, 0
				DAT_column_loop:
					mov		bx, cx
					shl		bl, 4			; bx = cx * 10h (����� ��ப�)
					add		bl, dl			;         + dx  (����� �⮫��)
					
					mov		bh, 00Ch	; ���訩 ���� (���ਡ���)(梥�) = (���)(���� 梥�)
										; P.S. (08�h �ਪ����)
					mov		es:[di], bx		; ��⠭���� �����-����
					add		di, 2 *2		; ��������� � ᫥���饬� �१ "� "

					inc		dx
					cmp		dx, 16
					jl		DAT_column_loop
			pop		di

			inc		cx
			cmp		cl, 16
			jl		DAT_lines_loop

		add		di, ax
		add		di, ax
		mov		si, offset line_last		; ��㤠 �⠥�
		call	write_to_video

		clc
		popa
		ret
draw_ascii_table endp

@lbl_status:
		mov			dx, offset status_msg
		call		print_dx_string

		mov			ah, 0Fh				; ����� ⥪�騩 �����-०��
		int			10h					; �室:  ���
										; ��室: al = ⥪�騩 ०�� (�. �㭪�� 00h)
										;        ah = �᫮ ⥪�⮢�� ������� �� �࠭�
										;        bh = ����� ��⨢��� ��࠭��� ��ᯫ��
		mov			cx, ax
		mov			dx, offset current_mode
		call		print_dx_string
		xor			ah, ah				; ax = al
		call		print_int2
		call		CRLF

		mov			dx, offset current_lines
		call		print_dx_string
		mov			al, ch				; ax = ah
		call		print_int2
		call		CRLF

		mov			dx, offset current_page
		call		print_dx_string
		mov			al, bh				; ax = bh
		call		print_int2
		call		CRLF

		ret

@illegal_key:
		mov			dx, offset illegal_key_err
		call		print_dx_string

@lbl_help:
		mov			dx, offset usage
		call		print_dx_string
		ret


@start:							; � ��।����� �ࠢ����� � ᠬ�� ��砫�

	; �᫨ ��� ��㬥�⮢ - ��㥬 (�᫨ ��������) ��� ⥪�饣� �����-०���
		cmp		[cmd_len], 0
		jz		@no_args

	; ���� ��㬥�� - �����-०��
		mov		si, offset cmd_line
		mov		ah, 10h
		call	get_cmd_arg
		jc		@illegal_key

		cmp		al, 2					; �᫨ ��㬥�� ���� ���箬 -x /x
		je		found_slash_or_minus
		cmp		al, 1					; �᫨ ��㬥�� ���� �� �᫮�
		jne		@illegal_key			; - �訡��
		mov		arg1, bx				; �᫨ ��㬥�� ���� �᫮�, ��࠭��

	; ��ன ��㬥�� - �⮡ࠦ����� ��࠭��
		mov		si, offset cmd_line
		mov		ah, 10h
		call	get_cmd_arg
		jc		@illegal_key

		cmp		al, 1					; �᫨ ��㬥�� ���� �� �᫮�
		jne		@illegal_key			; - �訡��
		mov		arg2, bx				; �᫨ ��㬥�� ���� �᫮�, ��࠭��

		jmp		@process_args

	@no_args:
		mov		ah, 0Fh					; ����� ⥪�騩 �����-०��
		int		10h						; �室:  ���
										; ��室: al = ⥪�騩 ०�� (�. �㭪�� 00h)
		xor		ah, ah					;        ah = �᫮ ⥪�⮢�� ������� �� �࠭�
		mov		arg1, ax				;        bh = ����� ��⨢��� ��࠭��� ��ᯫ��
		mov		al, bh
		mov		arg2, ax

	@process_args:
		; ������� �����-०�� � ��࠭���
		mov		ax, arg1
		call	change_video_mode
		jc		@illegal_key
		mov		ax, arg2
		call	change_display_page
		jc		@illegal_key

		; �������� �� �⮬
		mov		dx, offset change_video_msg
		call	print_dx_string
		mov		ax, arg1
		call	print_int2
		call	CRLF

		mov		dx, offset change_page_msg
		call	print_dx_string
		mov		ax, arg2
		call	print_int2
		call	CRLF
		
		; ����㥬 ��ᨢ�� ASCII-⠡���� �� 業��� �࠭�
		mov		dx, offset this_is_ascii
		call	print_dx_string

		call	draw_ascii_table
		jc		illegal_video_mode

		mov		cx, 19
		clear_lines_for_table:
		call	CRLF
		loop	clear_lines_for_table

		ret

	illegal_video_mode:
		mov		dx, offset illegal_video_mode_err
		call	print_dx_string
		ret

	found_slash_or_minus:				; ���㬥�� ��稭����� � / ��� -
		cld								; ��।����, ����� �㪢� ���� ��᫥
		mov		cl, 3					; ���祩 2, �㤥� �᪠�� ᨬ��� �
		mov		al, bl					; ��ப� keys. �᫨ cx �⠭�� 0
		lea 	di, keys 				; �����, �� ��諨 �宦�����
		repne	scasb					; �᫨ 1 - lbls[1*2] help
		shl		cx, 1					; �᫨ 2 - lbls[2*2] status
		mov		di, cx					; � �.�.
		jmp		lbls[di]


; ���� � ᮮ⢥�����騥 ��⪨
keys			db		'sh'
lbls			dw		@illegal_key,	@lbl_help,		@lbl_status

; �����, ����� �뤠�� �ணࠬ�� � ���箬 /h:
usage			db		'�祡��� �ணࠬ�� ��� ���ᮢ�� ⠡��� ASCII-ᨬ����� �� ���',	0Dh,0Ah
				db		'⥪�⮢�� �����-०���� � �����⨬�� ��࠭��� �� 業��� �࠭�.',0Dh,0Ah,0Dh,0Ah
				db		'�ᯮ�짮�����: ascii [��� ��㬥�⮢    ] - � ⥪�饬 ०���',		0Dh,0Ah	
				db		'               ascii [\1      \2        ] - ᬥ���� � ���ᮢ���',	0Dh,0Ah,0Dh,0Ah
				db		'��ࠬ����:',														0Dh,0Ah
				db		'  \1           ����� ⥪�⮢��� �����-०���   [0,1,  2,3,  7]',	0Dh,0Ah
				db		'  \2           ��࠭�� ��ᯫ�� ᮮ⢥��⢥��� [0-7,  0-3,  0]',	0Dh,0Ah
				db		'  -h [/h]      �뢥�� �� ᮮ�饭�� � �ࠢ���',					0Dh,0Ah
				db		'  -s [/s]      �������� ���ଠ�� � ⥪�饬 �����-०���',		0Dh,0Ah
				db		0Dh,0Ah,'$'

; ������, ����� �뤠�� �ணࠬ�� �� �ᯥ譮� �믮������:
status_msg		db		'����� �����-०���'										,0Dh,0Ah,'$'
current_mode	db		'    ����騩 ०��:                           '						,'$'
current_lines	db		'    ��᫮ ⥪�⮢�� ������� �� �࠭�:       '						,'$'
current_page	db		'    ����騩 ����� ��⨢��� ��࠭��� ��ᯫ��: '						,'$'
change_video_msg	db	'����騩 �����-०�� '												,'$'
change_page_msg	db		'������ �⮡ࠦ����� ��࠭�� '									,'$'
this_is_ascii	db		'������ ASCII-ᨬ�����:'									,0Dh,0Ah,'$'
press_any		db		'������ ���� ������� ��� �த�������...'					,0Dh,0Ah,'$'

; ������, ����� �뤠�� �ணࠬ�� �� �訡���:
illegal_key_err	db		'�訡��! ������ ������ ���� �� ����᪥.'			,0Dh,0Ah,0Dh,0Ah,'$'
illegal_video_mode_err db 'Error! ASCII-chart available only for text video-modes',	 0Dh,0Ah,'$'

arg1			dw		?
arg2			dw		?

line_1			db		"�������������������������������������ͻ "
line_2			db		"� \ � 0 1 2 3 4 5 6 7 8 9 A B C D E F � "
line_3			db		"�������������������������������������͹ "
line_last		db		"�������������������������������������ͼ "

end @entry
