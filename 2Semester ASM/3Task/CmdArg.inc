; ����: ����� ��������, ne.seleznev@gmail.com
;        ����, ����-301, 2015
;
; ������⥪� ��� ࠡ��� � ��㬥�⠬� ��������� ��ப�
; CmdArg 1.0 (�� ���ᮭ��� ��� 03.04.2015)
;
; ��� ࠡ��� �᭮���� ��楤��� ����室��� 㪠����
;     - ���� ��砫� ��ப� � ��㬥�⠬�
;     - ���� ��砫� ���� ��� ��।���� ��㬥��
;     - ���⥬� ��᫥���, �᫨ ��� ��㬥���-�᫠
;
; ������� ࠡ��� ��楤���:
;     - ��� ��㬥��
;         ��ப� (xyz abc)
;         ��᫮  (1 FA 12C 10)
;         ��ࠬ���-�㪢� (/x -x)
;         ��ࠬ���-᫮�� (/xyz --xyz)
;     - �����⥫� �� ��ࠬ���-��ப� (� $ � ����)
;     - �� �����
;     - ��樮���쭮:
;         ��� �᫥����� ⨯� ��� ���祭��
;         ��� ��ࠬ���-�㪢� - ᨬ���
;
; ��楤�� 㬥�� �⫠������� �訡�� ��ࠡ�⪨,
; ��⠭������� 䫠� CF � �����⨧���� �஡���� �� ⨯��:
;     - ��ப� ����
;     - ��९������� �᫠
;     - ��� �� �ਤ㬠�
;
; ����ᨬ���:
;     ���
;
; ����� �ਬ��� �ᯮ�짮����� cmdarg.asm � shortex.asm
; P.S. � ���� get_cmd_arg ���������� 横��, �����
;      �⮨� �������� �� rep stos/scas, �� ��� �祭�
;      �殮�� �⫠������, ���⮬� ࠡ�⠥� - �� �ண�� 

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


; ��� �� ����稫��� ��⪮ ᫮���� ��᫥ ����饭�� ��⥬� ��᫥���
str_to_int proc							; ��ॢ�� ��ப� � �᫮
	; �室:
	;     ah = ���⥬� ��᫥��� (<- [2...16])
	;     si = 㪠��⥫� �� ��砫� ��ப� (bytes)
	;     cx = ����� ��ப� (> 0)
	; �������:
	;     ax = �᫮ [0...65535]
	; �����:
	;     ax
	; �訡��:
	;     ���� CF = 1
	;     ax = 0 - �訡�� ᨬ���� ��� �����४�� ah,cx
	;          1 - ��९������� १����
		push bx
			push dx
				push si
		cmp		ah, 2
		jl		StI_incorrect
		cmp		ah, 10h
		jg		StI_incorrect
		jcxz	StI_incorrect

		xor		dx, dx
		mov		dl, ah					; ���⥬�
		xor		ax, ax					; �������
		xor		bx, bx					; �����

	StI_loop:
		xchg	ax, bx 					; (00, 00), RES
		mov		ah, dl		; �᭮����� �.�.
		mov		al, [si]				; (00,"2"), RES
		call	char_to_int				; (00, 2 ), RES
		jc		StI_incorrect
		xor		ah, ah		; �᭮����� �.�.
		
		xchg	ax, bx					; RES, (00, 2 )
		 push	dx						; mul 㡨���� dx
		mul		dx						; ax *= dx
		jo		StI_overflow
		 pop		dx
		add		ax, bx					; ax += bx
	 inc	si
	loop	StI_loop
		clc
		jmp		StI_end
	StI_incorrect:
		mov		ax, 0
		stc
		jmp		StI_end
	StI_overflow:
		 pop	dx
		mov		ax, 1
		stc
		jmp		StI_end
	StI_end:
				pop si
			pop dx
		pop bx
		ret
str_to_int endp


trim_leading_zeros proc					; ��祭�� ������ �㫥� � ��ப�
	; �室:
	;     si = 㪠��⥫� �� ��砫� ��ப� �� ����, ��� ���� ����
	;          �� ������, �.�. (len)(char_1)(char_2)...(char_len)
	; �������:
	;     si = � �� �������, �� 㦥 ��� ������ �㫥�

		push	si
		cld								; ����樨 � ��ப��� � ��אַ� ���ࠢ�����
		mov		bx,	si					; ���࠭�� 㪠��⥫� �� ���� ����� ��ப�
		xor		cx, cx
		mov		cl, [bx]				; ����稪
		jcxz	TLZ_error				; �᫨ ����� ��ப� ࠢ�� 0, �訡��
		inc		si						; 1� ᨬ���
		mov		di,	si					; di = �����⥫� �� 1� ᨬ��� ��ப�
		mov		al,	' '					; �饬 �஡��
		xor		dx,	dx					; 

		repe	scasb					; ���堫�!
		jz		TLZ_done				; �᫨ ⮫쪮 �஡���, �����
		inc		cl						; ����, �� ����� 1� ���஡����
		dec		di						;        ᨬ���
		mov		dl,	cl					; ����� ����� ��ப�
		xchg	di,	si					; si <=> di
		rep 	movsb					; ��६����� ��⠢����� ���� ��ப�
	TLZ_done:
		mov		[bx], dl				; ����� ����� ��ப�
		clc
		jmp		TLZ_exit
	TLZ_error:
	 	stc
	TLZ_exit:
		pop		si
		ret
trim_leading_zeros endp


get_cmd_arg proc						; �����頥� ���� ����⥭��
	;                                     ��ࠬ��� ��������� ��ப�.
	; �室:
	;     si = 㪠��⥫� �� ��砫� ��ப� �� ����, ��� ���� ����
	;          �� ������, �.�. (len)(char_1)(char_2)...(char_len)
	;     ah = ��⥬� ��᫥��� ��� ��㬥�⮢-�ᥫ,
	;          0, �᫨ ��� �ਭ㤨⥫쭮 ����� �᫠ ��ப���
	; �������:
	;     al = ��� ��㬥��
	;         0 - ��ப� (xyz abc)
	;         1 - ��᫮  (1 FA 12C 10)
	;         2 - ��ࠬ���-�㪢� (/x -x)
	;         3 - ��ࠬ���-᫮�� (/xyz --xyz)
	;     di = 㪠��⥫� �� ��ࠬ���-��ப� (� $ � ����)
	;     dx = �� �����
	;     bx = [ 1 ⨯ - ��᫮,
	;            2 ⨯ - ������(bl) ]
	; �訡��:
	;     ���� CF = 1
	;     bl = 0 - ��ப� ����
	;          1 - ��९������� �᫠
	;          2 - ��� �� �ਤ㬠�
	;          3 - ��祥 3/\�, ����
	; ________________________________________________________________ ;

	; ����᭥��� � ���������:
	;                                               ;S|����ﭨ� �⥪�
	;                                   ; ���� �������਩
	;                       ; ����᭥��� ᮤ�ঠ��� ॣ���஢

		call	trim_leading_zeros
		jc 		GCA_empty

		push	si									;S|-trim-
		xor		cx, cx
		mov		cl, [si]				; cx = ����� ��ப�
		jcxz	GCA_empty

		; ������ ��㬥��, �.�. �� ᨬ���� �� ᫥���饣� �஡���
		inc		si						; si = ���� ��ப�
		mov		al, ' '					; al = �᪮�� ᨬ���
	GCA_get_arg:
		cmp		al, [si]				; ���� ��ࢮ�� �஡���
		je		GCA_get_arg_exit
		inc		si
	loop GCA_get_arg
	GCA_get_arg_exit:

		pop		si			; "(n)I II ..."			;S|-
		push	si									;S|-trim-
		push	cx			;���࠭�� len(" II ...)";S|-trim-len2-

		xor		dx, dx					; ���᫨� � dx ������⢮
		mov		dl, [si]				; 㦥 ���⠭��� ᨬ�����
		sub		dl, cl												;� �����

		inc		si
		mov		cx, dx					; cx = ����� ���⠭��� ��ப�
		
		cld
		 push	di									;S|-trim-len2-dest
		rep		movsb					; ���࠭�� �� ����� di ��㬥��
		 pop	di									;S|-trim-len2-

		pop		cx									;S|-trim-
		pop		bx			; "(n)I II ..."			;S|-
		push	di									;S|-"I"-
		mov		di, bx		; "(n)I II ..."

		mov		[di], cl	; ��ࠢ�塞 0-�� ���� �� ����� �����
		inc		di

		cld
		rep		movsb	 	; ��।������ " II ..." � ��砫�


		pop		di									;S|-			;� �����
		mov		al, '$'
		add		di, dx
		mov		[di], al				; �����訬 ��ப� '$'
		sub		di, dx

		; �஢�ઠ �� �᫮
		test	ah, ah					; (� ���ᨨ 1.0) �᫨ ah = 0, ������㥬 �᫠
		jz		GCA_ignore_integer

		;mov		ah, 10h				; ���⥬� ��᫥��� (� ���ᨨ 0.9.3 � ��㬥���)
		mov		si, di		; "I"		; �����⥫� �� ��砫� ��ப�
		mov		cx, dx					; ����� "I"
		call	str_to_int
		jnc		GCA_integer
		cmp		ax, 1					; �� CF=1, ax=1
		je		GCA_overflow			; ����� ��९�������
		dec		si

	GCA_ignore_integer:
		; �஢�ઠ �� �맮� � ���箬
		mov		al, [si + 1]
		cmp		al, '/'
		je		GCA_slash_or_minus
		cmp		al, '-'
		je		GCA_slash_or_minus

		; ��祣� �� ����諮, ����� ���� ��ப�
		xor		al, al
		jmp		GCA_exit

	GCA_integer:
		mov		bx, ax 	; bx = int arg
		mov		al, 1
		jmp		GCA_exit
		
	GCA_slash_or_minus:
		; ��१��� / ��� -, 㬥����� �����
		inc		di
		dec		dx
		cmp		dx, 1
		jg		GCA_long_key

		mov		bl, [si + 2]			; ������
		mov 	al, 2
		jmp		GCA_exit

	GCA_long_key:
		; ������ linux-style --xyz � -xyz
		; (�᫨ si[1..2] == '--', � ��।������ di ��ࠢ�, dx=dx-1)
		mov		al, '-'
		cmp		[si+1], al
		jne		GCA_long_key_ok
		cmp		[si+2], al
		jne		GCA_long_key_ok
		inc		di
		dec		dx

		GCA_long_key_ok:
		mov 	al, 3
		jmp		GCA_exit

	GCA_empty:
		mov		al, '$'					; �����訬 ��ப� $, � 㪠���
		mov		[di], al				; �㫥��� �����, �⮡�
		xor		dx, dx					; �� �뫮 �஡��� � �뢮���
		xor		bl, bl
		stc

	GCA_overflow:
		mov		bl, 1
		stc

	GCA_exit:
		ret
get_cmd_arg endp
