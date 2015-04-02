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

ORG 80h
	cmd_len		label byte		; ����� ��㬥�⮢ ��������� ��ப�
	cmd_line	label byte		; ��㬥��� ��������� ��ப�
ORG 100h

@entry:
		jmp			@start

include SexyPrnt.inc
include CmdArg.inc
include	ChVideo.inc

@illegal_key:
		mov			dx, offset illegal_key_err
		call		print_dx_string
		ret


@start:									; � ��।����� �ࠢ����� � ᠬ�� ��砫�

	; ��ࢮ� �᫮
		mov		si, offset cmd_line
		mov		ah, 10h
		call	get_cmd_arg
		jc		@illegal_key

		cmp		al, 1
		jne		@illegal_key			; �᫨ �� �� �᫮ - �訡��

		; � ��� �᫮, ��࠭�� ���
		mov		cmd_arg1, bx

		xor		cx, cx
		mov		cl, [cmd_len]			; cx <- ����� ����� ��������� ��ப�
		test	cx, cx					; �᫨ ����, �訡��, ��� �㦥� �� ���� ��㬥��
		jz		@illegal_key

	; ��஥ �᫮
		mov		si, offset cmd_line
		mov		ah, 10h
		call	get_cmd_arg
		jc		@illegal_key

		cmp		al, 1
		jne		@illegal_key			; �᫨ �� �� �᫮ - �訡��

		; � ��� �᫮, ��࠭�� ���
		mov		cmd_arg2, bx

		xor		cx, cx
		mov		cl, [cmd_len]			; cx <- ����� ����� ��������� ��ப�
		test	cx, cx					; �᫨ ����, ����� ��㬥�⮢ ����� ���,
		jz		@process_args 			; ��� ��ࠡ��뢠�� �, �� ��ᮡ�ࠫ�

		; � �᫨ ��� ����, ���� ������ ������
		mov		dx, offset press_any
		call	print_dx_string
		mov		ah, 07h
		int 	21h

	; ��ࠡ�⪠ ���� �ᥫ
	@process_args:

		; ������� �����-०�� � ��࠭���
		mov		ax, cmd_arg1
		call	change_video_mode
		jc		@illegal_key
		mov		ax, cmd_arg2
		call	change_display_page
		jc		@illegal_key

		; �������� �� �⮬
		mov		dx, offset change_video_msg
		call	print_dx_string
		mov		ax, cmd_arg1
		call	print_int2
		call	CRLF

		mov		dx, offset change_page_msg
		call	print_dx_string
		mov		ax, cmd_arg2
		call	print_int2
		call	CRLF
	
	ret

illegal_key_err	db		'�訡��! ������ ������ ���� �� ����᪥. ��. �ࠢ��',		0Dh,0Ah
				db		'����� �祡��� �ணࠬ�� ��� ᬥ�� �����-०��� � ��࠭���',	0Dh,0Ah
				db		'�� ����� �㭪権 00h,05h,0Fh ���뢠��� BIOS 10h',	0Dh,0Ah,0Dh,0Ah
				db		'�ᯮ�짮�����: video \1      \2         [\3]',					0Dh,0Ah
				db		'               video <०��> <��࠭��> [<ᨬ���>]',	0Dh,0Ah,0Dh,0Ah
				db		'��ࠬ����:',													0Dh,0Ah
				db		'  \1           ����� �����-०��� [0,1,2,3,4,5,6,7,D,E,F,10]',	0Dh,0Ah
				db		'  \2           ��࠭�� ��ᯫ�� [0 ��� ���,1-7 ��樮���쭮]',	0Dh,0Ah
				db		'  \3           �� ����稨 ���� ������ ������, ��⥬',		0Dh,0Ah
				db		'               �����頥� �࠭ � ��室��� ���ﭨ�, ��室��',0Dh,0Ah
				db		'  -h [/h]      �뢥�� �� ᮮ�饭�� � �ࠢ���',				0Dh,0Ah
				db		'  -s [/s]      �������� ���ଠ�� � ⥪�饬 �����-०���',	0Dh,0Ah
				db		0Dh,0Ah,'$'

change_video_msg db		'���� �����-०��: '										,'$'
change_page_msg	db		'����� �⮡ࠦ����� ��࠭��: '								,'$'
press_any		db		'������ ���� ������� ��� �த�������...'					,0Dh,0Ah,'$'

cmd_arg1		dw		?
cmd_arg2		dw		?

end @entry
