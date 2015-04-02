; ����� ��������, ����-301, 2015
;
; �����-०��� (����誠 �� 18 ����):
; program.com (\d) (\d) (\-)?/
; \1 = video_mode
; \2 = display_page
; �ணࠬ�� ��⠭�������� �����०�� � ��࠭��� ᮣ��᭮ ��ࠬ��ࠬ, �� ����稨 \3 ����,
; ���� ���짮��⥫� ������ �������, ��⥬ �����頥� �࠭ � ��室��� ���ﭨ� � ��室��.
; �᫨ \3 ���������, � ��⠭�������� \1, \2 � ��室��.
; �ᯮ�짮���� �㭪樨 00h, 05h, 0Fh int 10h, ࠧ����� ᠬ����⥫쭮.

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


@start:									; � ��।����� �ࠢ����� � ᠬ�� ��砫�

	; �⥭�� ��㬥�⮢ ��������� ��ப�
	read_arg:
		mov		si, offset cmd_line
		mov		ah, 10h
		call	get_cmd_arg
		jc		@illegal_key

		cmp		cmd_arg_number, 4		; �᫨ ���� ��⨩ ��㬥��
		je		@process_args_delay


		cmp		cmd_arg_number, 0		; ���� ��㬥�� ����� ���� ���箬
		jg		allow_only_integer		; ��⠫�� - ���

		cmp		al, 2					; �᫨ ��㬥�� ���� ���箬 -x /x
		je		found_slash_or_minus

	 allow_only_integer:
		cmp		al, 1					; �� �᫮�
		jne		@illegal_key

		; � ��� �᫮, ��࠭�� ���
		mov		si, offset args
		mov		cx, cmd_arg_number
		add		si, cx
		mov		[si], bx

		add		cmd_arg_number, 2
		xor		cx, cx
		mov		cl, [cmd_len]			; cx <- ����� ����� ��������� ��ப�
		test	cx, cx					; �᫨ �� ����, ������� �� ��㬥��
	jnz		read_arg
	
	jmp		@process_args

	@process_args_delay:
		mov		dx, offset press_any
		call print_dx_string
		mov		ah, 07h
		int 	21h

	@process_args:

		; ������� �����-०�� � ��࠭���
		mov		ax, args[0]
		call	change_video_mode
		jc		@illegal_key
		mov		ax, args[2]
		call	change_display_page
		jc		@illegal_key

		; �������� �� �⮬
		mov		dx, offset change_video_msg
		call	print_dx_string
		mov		ax, args[0]
		call	print_int2
		call	CRLF

		mov		dx, offset change_page_msg
		call	print_dx_string
		mov		ax, args[2]
		call	print_int2
		call	CRLF
	
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
usage			db		'����� �祡��� �ணࠬ�� ��� ᬥ�� �����-०��� � ��࠭���',	0Dh,0Ah
				db		'�� ����� �㭪権 00h,05h,0Fh ���뢠��� BIOS 10h',	0Dh,0Ah,0Dh,0Ah
				db		'�ᯮ�짮�����: video \1      \2         [\3]',					0Dh,0Ah
				db		'               video <०��> <��࠭��> [<ᨬ���>]',	0Dh,0Ah,0Dh,0Ah
				db		'��ࠬ����:',													0Dh,0Ah
				db		'  \1           ����� �����-०��� [0,1,2,3,4,5,6,7,D,E,F,10]',	0Dh,0Ah
				db		'  \2           ��࠭�� ��ᯫ��',								0Dh,0Ah
				db		'  \3           �� ����稨 ���� ������ ������, ��⥬',		0Dh,0Ah
				db		'               �����頥� �࠭ � ��室��� ���ﭨ�, ��室��',0Dh,0Ah
				db		'  -h [/h]      �뢥�� �� ᮮ�饭�� � �ࠢ���',				0Dh,0Ah
				db		'  -s [/s]      �������� ���ଠ�� � ⥪�饬 �����-०���',	0Dh,0Ah
				db		0Dh,0Ah,'$'

; ������, ����� �뤠�� �ணࠬ�� �� �ᯥ譮� �믮������:
status_msg		db		'����� �����-०���'										,0Dh,0Ah,'$'
current_mode	db		'    ����騩 ०��:                           '						,'$'
current_lines	db		'    ��᫮ ⥪�⮢�� ������� �� �࠭�:       '						,'$'
current_page	db		'    ����騩 ����� ��⨢��� ��࠭��� ��ᯫ��: '						,'$'
change_video_msg db		'��������� �����-०��� �� '										,'$'
change_page_msg	db		'��������� �⮡ࠦ����� ��࠭��� �� '								,'$'
press_any		db		'������ ���� ������� ��� �த�������...'					,0Dh,0Ah,'$'

; ������, ����� �뤠�� �ணࠬ�� �� �訡���:
illegal_key_err	db		'�訡��! ������ ������ ���� �� ����᪥.'			,0Dh,0Ah,0Dh,0Ah,'$'

cmd_arg_number	dw		0
args			dw		?, ?

end @entry
