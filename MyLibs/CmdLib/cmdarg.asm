; ����: ����� ��������, ����, ����-301, 2015
;
; �������⨢�� �ਬ�� �ᯮ�짮����� ������⥪� cmdarg.inc
; ���������� � ������:
;     cmdarg.com   hello  1 F   10  /x  /xyz -a
;

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


include SexyPrnt.inc
include CmdArg.inc


f_string_arg proc
		mov		dx, offset string_msg
		call	print_dx_string
		mov		dx, di				; ���� ��ப�
		call	print_dx_string
		call	CRLF
		ret
f_string_arg endp

f_integer_arg proc
		push	dx
		mov		dx, offset integer_msg
		call	print_dx_string
		pop		dx
		
		mov		ax, bx				; ���� �᫮
		call	print_int2

		call	print_open_bracket
		mov		ax, dx				; ��� �����
		call	print_int2
		call	print_space
		mov		dx, di				; ��ப���� �।�⠢�����
		call	print_dx_string
		call	print_close_bracket
		call	CRLF
		ret
f_integer_arg endp

f_short_key_arg proc
		mov		dx, offset short_key_msg
		call	print_dx_string
		mov		ah, 02h
		mov		dl, bl				; ��� ����
		int		21h
		mov		dx, offset attempt_msg
		call	print_dx_string
		ret
f_short_key_arg endp

f_long_key_arg proc
		mov		dx, offset long_key_msg
		call	print_dx_string
		mov		dx, di				; ��� ����
		call	print_dx_string
		mov		dx, offset attempt_msg
		call	print_dx_string
		ret
f_long_key_arg endp

f_error_arg proc
		cmp		bl, 0
		je		@_empty_arg

		mov		dx, offset error_msg1
		call	print_dx_string
		mov		dx, di
		call	print_dx_string
		mov		dx, offset error_msg2
		call	print_dx_string

		cmp		bl, 1
		je		@_oveflow_arg
		cmp		bl, 2
		je		@_other_arg

		mov		dx, offset error_unknown
		jmp		error_arg_exit

	 @_empty_arg:
		ret		; ��������� ⮫쪮 ⮣��, ����� �ணࠬ�� ����饭� ��� ��㬥�⮢.
				; �����猪 ����� ��� �뭥�� ������, � �� �뢮���� ᮮ�饭�� ��
				; �訡�� "00: ��� ��㬥�⮢". ���� �� ���� �� �訡�� ;)

	 @_oveflow_arg:
		mov		dx, offset error_overflow
		jmp		error_arg_exit

	 @_other_arg:
		mov		dx, offset error_other
		jmp		error_arg_exit

	 error_arg_exit:
		call	print_dx_string
		ret
f_error_arg endp



@start:

	read_arg:
		mov		si, offset cmd_line
		mov		di, offset cmd_arg

		call	get_cmd_arg
		jc		@error_arg

		; �᫨ ��।��� ��㬥�� ����
		cmp		al, 0					; - ���� ��ப��
		je		@string_arg
		cmp		al, 1					; - ��᫮�
		je		@integer_arg
		cmp		al, 2					; - ���箬 -x /x
		je		@short_key_arg
		cmp		al, 3					; - ���箬--xyz /xyz
		je		@long_key_arg

		mov		bl, 255
		jmp		@error_arg

		@string_arg:
			; di - ��ப�, dx - �� �����
			call	f_string_arg
			jmp		read_next_arg

		@integer_arg:
			; bx - �᫮, di - ��ப�, dx - �� �����
			call	f_integer_arg
			jmp		read_next_arg

		@short_key_arg:
			; bl - ᨬ���, di - ��ப�, dx - �� �����
			call	f_short_key_arg
			jmp		process_key_arg

		@long_key_arg:
			; di - ��ப�, dx - �� �����
			call	f_long_key_arg
			jmp		process_key_arg

		@error_arg:
			; di - ��ப�, dx - �� �����
			call	f_error_arg
			jmp		read_next_arg


		read_next_arg:
			xor		cx, cx
			mov		cl, [cmd_len]		; cx <- ����� ����� ��������� ��ப�
			test	cx, cx				; �᫨ �� ����, ������� �� ��㬥��
	jnz		read_arg

	jmp		goodbye

	; �ਬ�� ��ࠡ�⪨ ���祩 (��㬥�� ��稭����� � / ��� -)
	process_key_arg:
		cld							; ��।����, ����� �㪢� ���� ��᫥
		mov		cl, 3				; ���祩 2, �㤥� �᪠�� ᨬ��� �
		mov		al, bl				; ��ப� keys. �᫨ cx �⠭�� 0
		lea 	di, keys 			; �����, �� ��諨 �宦�����
		repne	scasb				; �᫨ 1 - lbls[1*2] help
		shl		cx, 1				; �᫨ 2 - lbls[2*2] author
		mov		di, cx				; � �.�.
		jmp		lbls[di]

	@key_illegal_key:
		mov		dx, offset illegal_key_err
		call	print_dx_string
		jmp		read_next_arg

	@key_help:
		mov		dx, offset usage
		call	print_dx_string
		jmp		read_next_arg

	@key_author:
		mov		dx, offset author
		call	print_dx_string
		jmp		read_next_arg

	goodbye:
		
		mov		dx, offset goodbye_msg
		call	print_dx_string
		ret

; ���� � ᮮ⢥�����騥 ��⪨
keys			db		'ah'
lbls			dw		@key_illegal_key, @key_help, @key_author

; �����, ����� �뤠�� �ணࠬ�� �� ����᪥ � ���箬:
usage			db		'�ਬ�� ࠡ��� � ��㬥�⠬� ��������� ��ப� � �������',	0Dh,0Ah
				db		'������⥪� cmdarg.inc',									0Dh,0Ah,0Dh,0Ah
				db		'�ᯮ�짮�����: cmdarg.com [arg1] [arg2] ... [argn]',		0Dh,0Ah
				db		'               ��� argk - �ந������ ��㬥��, �.�.',	0Dh,0Ah
				db		'               ��ப�, �᫮, ���⪨� ��� ������ ����',	0Dh,0Ah,0Dh,0Ah
				db		0Dh,0Ah,'$'
author			db		'���� ������⥪� cmdarg � �ਬ��:',						0Dh,0Ah
				db		'       ��㤥�� 3 ���� ���� ���� ��㯯� ����-301',			0Dh,0Ah
				db		'       �������� �����.',									0Dh,0Ah
				db		'����ਭ���, 2015 ���.',									0Dh,0Ah
				db		'�������� �� ���஢�!',									0Dh,0Ah
				db		0Dh,0Ah,'$'
illegal_key_err	db		'�訡��! ������ ������ ���� �� ����᪥.'			,0Dh,0Ah,'$'

; ������, ����� �뤠�� �ணࠬ�� �� �ᯥ譮� �믮������:
string_msg		db		'��ࠬ���-��ப� '											,'$'
integer_msg		db		'��ࠬ���-�᫮ '											,'$'
short_key_msg	db		'����-�㪢� '												,'$'
long_key_msg	db		'����-᫮�� '												,'$'
error_msg1		db		'�訡�� � ��ࠬ��� "'										,'$'
error_msg2		db		'":',0Dh,0Ah,09h,09h										,'$'
error_overflow	db		'01: ��᫮ ᫨誮� ����讥, �ந��諮 ��९�������'	,0Dh,0Ah,'$'
error_other		db		'02: �� ���� ��������� �訡�� ��㬥��'			,0Dh,0Ah,'$'
error_unknown	db		'03: �������⭠� �訡�� ��㬥��'					,0Dh,0Ah,'$'
attempt_msg		db		'. ����⪠ ��ࠡ���� ����...'				,0Dh,0Ah,'$'
goodbye_msg		db		'�� ��㬥��� ��ࠡ�⠭�. Good bye!'							,'$'

cmd_arg			db		256 dup (?)

end @entry
