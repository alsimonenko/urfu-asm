; ����� ��������, ����-301, 2015
;
; �ਬ�� �ᯮ�짮����� ChVideo.inc
; program.com (\d) (\d)
;     \1 = video_mode
;     \2 = display_page
; �ணࠬ�� ��⠭�������� �����०�� � ��࠭��� ᮣ��᭮ ��ࠬ��ࠬ.
; �ᯮ�짮���� �㭪樨 00h, 05h, 0Fh int 10h, ࠧ����� ᠬ����⥫쭮.
; 
; P.S. �����쭮 ���୮� �⥭�� ��㬥�⮢, �� ���頩� ��������.
;      ������� ��� ���������� �� ����ᨬ��⥩. �㦭� ⮫쪮 ChVideo.inc

.286
.model tiny
.code

ORG 80h
	cmd_len		label byte				; ����� ��㬥�⮢ ��������� ��ப�
	cmd_line	label byte				; ��㬥��� ��������� ��ப�
ORG 100h

@entry:
		jmp			@start

include ChVideo.inc

; �ᯮ����⥫��
print_int2 proc							; ����� ���塠�⭮�� �᫠ � �����筮� ����
	; 
		pusha						; �室:
		test		ax, ax			;     ax = �᫮
		jns			PI2_positive

		mov			cx, ax
		mov			ah, 02h
		mov			dl, '-'
		int			21h
		mov			ax, cx
		neg			ax
	PI2_positive:
		xor			cx, cx
		mov			bx, 10
	PI2_bite_off:
		xor			dx, dx
		div			bx				; ax = ax / 10
		push		dx				; dx = ax % 10
		inc			cx
		test		ax, ax
		jnz			PI2_bite_off

		mov			ah, 02h

	PI2_print_digit:
		pop			dx
		add			dl, '0'
		int			21h
	loop		PI2_print_digit

		popa
		ret
print_int2 endp

print_dx_string proc					; ����� ��ப�
		push ax						; �室:
		mov			ah, 09h			;      dx = ���� ��ப�
		int			21h
		pop ax
		ret
print_dx_string endp

CRLF proc
		pusha

		mov			dx, 13
		mov			ax, 0200h
		int			21h
		mov			dx, 10
		mov			ax, 0200h
		int			21h

		popa
		ret
CRLF endp

char_to_int proc						; ��ॢ�� ᨬ���� � �᫮
	; �室:
	;     ah = ���⥬� ��᫥��� (<- [2...16])
	;     al = ������
	; �������:
	;     al = �᫮ [0...ah-1]
	; �����:
	;     ax
	; �訡��:
	;     ���� CF = 1
	;     �����४�� ᨬ��� ��� �᭮����� ��⥬� ��᫥���
		cmp		ah, 2
		jl		AI_incorrect
		cmp		ah, 16
		jg		AI_incorrect

		cmp		al, 48
		jl	AI_incorrect
		sub		al, 48	; '0' -> 0
		cmp		al, 10
		jl	AI_under10
		cmp		al, 17 	; 'A' -> 17
		jl	AI_incorrect
		cmp		al, 22	; 'F' -> 22
		jg	AI_incorrect
		sub		al, 7

	AI_under10:
		cmp		al, ah
		jge		AI_incorrect

	AI_success:
		clc
		ret
	AI_incorrect:
		stc
		ret	
char_to_int endp


parse_first_arg:
	; cmd_line ������ ���� (" xx y" ��� " x y") �, ��������, ( + " z...")
	; �᫨ cmd_len < 4, goto @illegal_key
		cmp		cmd_len, 4
		jl		@illegal_key

		xor		cx, cx

	; �᫨ cmd_line[2] == 1, [3] == 0, � cmd_arg1=10h
		cmp		cmd_line[3], '0'
		jne		_char2_not_zero
		cmp		cmd_line[2], '1'
		jne		@illegal_key
		mov		cmd_arg1, 10h
		inc		cx						; �᫨ ���� ��㬥�� ������,
		jmp		parse_second_arg				; cx = 1

	; �᫨ cmd_line[3] == " "
	_char2_not_zero:
		cmp		cmd_line[3], ' '
		jne		@illegal_key
		
	; � cmd_line[1] - �᫮
		mov		ah, 16
		mov		al, cmd_line[2]
		call	char_to_int
		jc		@illegal_key
		
		xor		ah, ah
		mov		cmd_arg1, ax
	jmp	__1


parse_second_arg:
	; �᫨ cmd_line[4] (��� [5], �᫨ ��ࢮ� �뫮 10h) - �᫮
		mov		ah, 16
				mov		di,	cx
				add		di, 4
		mov		al,	cmd_line[di]
		call	char_to_int
		jc		@illegal_key

		xor		ah, ah
		mov		cmd_arg2, ax

	jmp @process_args


@illegal_key:
		mov			dx, offset illegal_key_err
		call		print_dx_string
		ret


@start:									; � ��।����� �ࠢ����� � ᠬ�� ��砫�

		jmp parse_first_arg
	__1:
		jmp	parse_second_arg

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
				db		'�ᯮ�짮�����: video \1      \2         ',						0Dh,0Ah
				db		'               video <०��> <��࠭��> ',				0Dh,0Ah,0Dh,0Ah
				db		'��ࠬ����:',													0Dh,0Ah
				db		'  \1           ����� �����-०��� [0,1,2,3,4,5,6,7,D,E,F,10]',	0Dh,0Ah
				db		'  \2           ��࠭�� ��ᯫ�� [0 ��� ���,1-7 ��樮���쭮]', 0Dh,0Ah
				db		0Dh,0Ah,'$'

change_video_msg db		'���� �����-०��: '										,'$'
change_page_msg	db		'����� �⮡ࠦ����� ��࠭��: '								,'$'
press_any		db		'������ ���� ������� ��� �த�������...'					,0Dh,0Ah,'$'

cmd_arg1		dw		?
cmd_arg2		dw		?

end @entry
