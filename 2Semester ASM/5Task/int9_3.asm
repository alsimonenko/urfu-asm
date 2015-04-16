; 09 handler, ࠡ�⠥�, ����⠭��������
; �� ������ �஡��� ᮮ�饭��, �� ������ �� ��室
; + < 190 bytes
; �����뢠�� � �����-������
; ���� Low-Memory Usage (449, 44A)
.286
.model tiny
.code
ORG 2Ch
	env_ptr		label word		; ��।����� ���� ��� ����㯠 � ᫮�� � PSP, ���஥
								; 㪠�뢠�� �� ᥣ����, ᮤ�ঠ騩 ���� ����樮���� �।�
								; (���筮 �᢮��������� ��� ᮧ����� ������⭮�� १�����)
ORG 100h

@entry:		jmp @start


;include SexyPrnt.inc

buffer		db		10h dup (?) 
head		dw		0
tail		dw		0
old_09h		dw		?, ?

catch_09h	proc	far
	; in  - read from port
	; out - write to port
		in		al,		60h			; ᪠�-��� ��᫥���� ����⮩ (�� 60 ����)

		cmp		al, 81h				; �᫨ �� �⦠⨥ ������ Esc
		jne		int9_continue1		; �����訬 �믮������ �ணࠬ��
		mov		ax, 2509h			; ����⠭�������� ����� 21h
		mov		dx, word ptr cs:[old_09h]
		mov		ds, word ptr cs:[old_09h+2]
		int		21h

		mov		es, env_ptr			; ����稬 �� PSP ���� ᮡ�⢥����� 
		mov		ah, 49h				; ���㦥��� १����� � ���㧨� ��� 
		int		21h

		push	cs					; ���㧨� ⥯��� ᠬ� �ணࠬ��
		pop		es					; 
		mov		ah, 49h				; 
		int		21h 				;
		jmp		int9_continue2
		
	int9_continue1:
;		mov		ax, 3     ; text mode 80x25, 16 colors, 8 pages (ah=0, al=3)
;		int		10h       ; do it!
;		mov		ax, 0500h
;		int		10h
		mov     dx, 0B800h
		mov     es, dx

		push	ax
			mov		bx, 10
			mov		cx, 3
			int9_bite_off:
				xor		dx, dx
				div		bx					; ax = ax / 10
				push	dx					; dx = ax % 10
			loop	int9_bite_off

			mov		ah, 02h
			mov		cx, 3
			xor		di, di
			int9_print_digit:
				pop		dx
				add		dl, '0'
				mov		es:[di],	dl
				mov		es:[di+1],	00Ch
				add		di, 2
			loop	int9_print_digit
		pop		ax

		cmp		al, 39h				; �᫨ �� �஡�� - �뢥��� ᮮ�饭��
		jne		int9_continue2
		
		;mov es:[00h], 0C53h
		;mov es:[02h], 0C70h
		;mov es:[04h], 0C61h
		;mov es:[06h], 0C63h
		;mov es:[08h], 0C65h
		;mov es:[0Ah], 0C21h
		
	int9_continue2:
		mov		di,		tail
		mov		buffer[di],	al
		inc		tail
		and		tail,	0Fh
		mov		ax,		tail
		cmp		head,	ax
		jne		@1
		inc		head
		and		head,	0Fh

	@1:
		in		al,		61h
		or		al,		80h
		out		61h,	al
		and		al,		07Fh
		out		61h,	al
		mov		al,		20h
		out		20h,	al			; �����⭮�� ����஫���� �㦥� ᨣ��� ....
		iret
catch_09h	endp


@start:
	; ��।���� ���祭�� ��ண� ����� INT 09h
	mov		ax, 3509h
	int		21h
	cli
		mov		[old_09h],		bx	; ���࠭�� ��� � ��६�����
		mov		[old_09h+2],	es
		mov		ax, 2509h			; ��⠭���� ���� ����� ���뢠��� INT 09h
		mov		dx, offset catch_09h
		int		21h
	sti

	ret
end		@entry
