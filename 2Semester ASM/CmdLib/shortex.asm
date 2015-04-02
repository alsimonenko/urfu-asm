; ����: ����� ��������, ����, ����-301, 2015
;
; ���⪨� �ਬ�� �ᯮ�짮����� ������⥪� cmdarg.inc
;     shortex.com   100
;     shortex.com  -xx
;     shortex.com  -a
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

@key_help:
	mov		dx, offset usage
	call	print_dx_string
	ret

@key_author:
	mov		dx, offset author
	call	print_dx_string
	ret


@start:
	mov		si, offset cmd_line
	mov		di, offset cmd_arg
	call	get_cmd_arg
	jc		@key_error

	; �᫨ ��।��� ��㬥�� ����
	cmp		al, 1					; - ��᫮�
	je		@integer_arg
	cmp		al, 2					; - ���箬 -x /x
	je		@short_key_arg

	@key_error:
		mov		dx, offset error_msg
		call	print_dx_string
		jmp		@key_help
		ret

	@integer_arg:
		; bx - �᫮, di - ��ப�, dx - �� �����
		mov		dx, offset int_msg1
		call	print_dx_string
		
		mov		ax, bx				; ���� �᫮
		call	print_int2_HEX
		mov		dx, offset int_msg2
		call	print_dx_string
		call	print_int2
		ret

	@short_key_arg:
		; bl - ᨬ���, di - ��ப�, dx - �� �����
		; �ਬ�� ��ࠡ�⪨ ���祩 (��㬥�� ��稭����� � / ��� -)
		cld							; ��।����, ����� �㪢� ���� ��᫥
		mov		cl, 3				; ���祩 2, �㤥� �᪠�� ᨬ��� �
		mov		al, bl				; ��ப� keys. �᫨ cx �⠭�� 0
		lea 	di, keys 			; �����, �� ��諨 �宦�����
		repne	scasb				; �᫨ 1 - lbls[1*2] help
		shl		cx, 1				; �᫨ 2 - lbls[2*2] author
		mov		di, cx				; � �.�.
		jmp		lbls[di]


keys		db		'ah'
lbls		dw		@key_error, @key_help, @key_author

usage		db		'���⪨� �ਬ�� ࠡ��� � ��㬥�⠬� ��������� ��ப�',	0Dh,0Ah
			db		'� ������� ������⥪� cmdarg.inc',							0Dh,0Ah
			db		'��ॢ�� ��⭠����筮�� �᫠ � �����筮�',	0Dh,0Ah,0Dh,0Ah
			db		'�ᯮ�짮�����: shortex.com N',								0Dh,0Ah
			db		'               ��� N - ��⭠����筮� �᫮ (A0).',		0Dh,0Ah
			db		'��ࠬ����:     -h ������, -a ����',						0Dh,0Ah,'$'
author		db		'���� ������⥪� cmdarg � �ਬ��:',						0Dh,0Ah
			db		'       ��㤥�� 3 ���� ���� ���� ��㯯� ����-301',			0Dh,0Ah
			db		'       �������� �����.',									0Dh,0Ah
			db		'����ਭ���, 2015 ���.',									0Dh,0Ah
			db		'�������� �� ���஢�!',									0Dh,0Ah,'$'
int_msg1	db		'�����筠� �ଠ �᫠ ',											'$'
int_msg2	db		': ',																'$'
error_msg	db		'�訡��! ��ࠢ��:',											0Dh,0Ah,'$'
cmd_arg		db		256 dup (?)

end @entry