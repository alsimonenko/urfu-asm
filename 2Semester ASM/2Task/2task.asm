; ����� ��������, ����-301, 2015
;
; �������⭠� �ணࠬ��:
; 1. ����: 'help', 'install', 'uninstall', 'kill', 'status'
; 2. ������� �� 2Fh, 21h (��।����� �����)
; 3. �⮡ࠦ��� �� ���� (�㤠 ��⠭�����, ��� ��⠭�����, � ������ ���� ���),
;    � �.�. ���� ��ࠡ��稪� ���뢠��� 21 (�.�. "���� int21h �� ..., �⠫ ...") 1432:4231
; 4. ���४⭮ ��ࠡ��뢠�� ���� ���� /program.com\s+[\/\-][hiuks]/
; 5. ��������� �� ����� (+env) �� -k ��� -u
; 6. User-friendly
;
; �� ���砬:
; help - �⮡ࠦ��� �ࠢ��
; install - ��⠭�������� १�����, ���� ����
; uninstall - 㤠��� १����� (�᫨ �� ��������, �.�. १����� �� ���設� �⥪� ���뢠���)
; kill - 㡨���� १����� (� �� ��砥)
; status - �⮡ࠦ��� ����� (��⠭�����/��� + ����)

.model tiny
.code

ORG 2Ch
	env_ptr	label word	; ��।����� ���� ��� ����㯠 � ᫮�� � PSP, ���஥ 㪠�뢠�� �� ᥣ����,
						; ᮤ�ঠ騩 ���� ����樮���� �।�
						; (�� ���筮 �᢮��������� ��� ᮧ����� ����� ������⭮� १����⭮� �ணࠬ��)
ORG 80h
	cmd_len		db	?	; ����� ��������� ��ப�
	cmd_line	db	?	; ��������� ��ப�
ORG 100h

@entry:
	jmp		@init

;-------------------- �������⭠� ���� �ணࠬ�� --------------------;
old_21h		dw		?, ?
new_21h		dw		?, ?
old_2Fh		dw		?, ?
new_2Fh		dw		?, ?


print_seg_offset proc
	; bx - ᥣ����, ����� ����室��� �ᯥ����
	;push	cs		; 0101 = 0000000100000001
	;pop		bx
	mov		cx, 4

	@k:	
		rol		bx, 4		; bx = 0001000000010000
		mov		al, bl		; al = 00010000
		and		al, 0fh
		cmp		al, 10
		sbb		al, 69h
		das
		mov		dh, 02h
		xchg	ax, dx
		int		21h
	loop	@k
	ret 2
print_seg_offset endp


catch_21h	proc	far
	jmp 	dword ptr cs:[old_21h]
catch_21h	endp

catch_2Fh	proc	far
	; �������� (ah):
	;	FA
	; �㭪樨 (al):
	;	00 - �஢�ઠ �� �⠭����
	;		FF - (᪮॥ �ᥣ�) ��⠭�����
	;	01 - ���㧪� �� �����
	;		AA - �� �� ���孨� � 楯�窥 ���뢠���
	;	02 - �ਭ㤨⥫쭠� ���㧪� �� �����
	;		

	cmp		ah, 0FAh 		; �஢�ઠ ᨣ������
	jne		pass_2Fh		; �᫨ �� ��� -> ��室

	cmp		al, 0			; �㭪�� �஢�ન �� ��⠭����
	jne		check_2Fh		; ��� -> �஢��塞 �㭪�� ���㧪�
	mov		al, 0FFh		; �� -> �ணࠬ�� ����㦥��
	iret

	check_2Fh:				; �஢�ઠ �� �㭪�� ���㧪�
		cmp		al, 01h
		je		uninstall_2Fh
		cmp		al, 02h
		je		kill_2Fh
		iret

	pass_2Fh:
		jmp dword ptr cs:[old_2Fh]

 	uninstall_2Fh:
		push	ds
		push	0
		pop		ds					; DS - ᥣ����� ���� ⠡���� ����஢ ���뢠���
		mov		ax, cs				; ��� ᥣ����� ����
		; �஢����, �� �� ���墠祭�� ���뢠��� ��-�०���� 㪠�뢠�� �� ���,
		; ���筮 �����筮 �஢���� ⮫쪮 ᥣ����� ���� (DOS �� ����㧨� �����
		; �ணࠬ�� � ��訬 ᥣ����� ���ᮬ)
		cmp		ax, word ptr ds:[21h*4+2]
		jne		unload_failed
		cmp		ax, word ptr ds:[2Fh*4+2]
		jne		unload_failed

		pop		ds
		jmp		kill_2Fh

		unload_failed:
			mov		al, 0AAh
			pop		ds
			iret

	kill_2Fh:
		push	es
			push	ds
				push	ax
					push	dx
		; ����⠭�������� ����� 21h
		mov		ax, 2521h
		mov		dx, word ptr cs:[old_21h]
		mov		ds, word ptr cs:[old_21h+2]
		int		21h
		; ����⠭�������� ����� 2Fh
		mov		ax, 252fh
		mov		dx, word ptr cs:[old_2Fh]
		mov		ds, word ptr cs:[old_2Fh+2]
		int		21h

		mov		es, cs:2Ch	; ����稬 �� PSP ���� ᮡ�⢥����� 
		mov		ah, 49h		; ���㦥��� १����� � ���㧨� ��� 
		int		21h

		push	cs			; ���㧨� ⥯��� ᠬ� �ணࠬ�� 
		pop		es			; 
		mov		ah, 49h		; 
		int		21h 		; 

					pop		dx
				pop		ax
			pop		ds
		pop		es
		iret
catch_2Fh	endp
;----------------- ����� १����⭮� ��� �ணࠬ�� -----------------;


@init:
		jmp			initialize_entry_point
		; �ய����� ࠧ���� ��ਠ��� ��室� ��� ��⠭���� १�����,
		; ����饭�� ����� ��⮬�, �� �� ��� ��।��� �ࠢ�����
		; ������� �᫮����� ���室�, ����騥 ���⪨� ࠤ��� ����⢨�

	@illegal_key:
		mov			ah, 09h				; �������� �訡�� � ����୮� ����, � ��⮬
		mov			dx, offset illegal_key_msg
		int			21h					; �ᯮ������ ������ ����� � ������� �ࠢ��


	@lbl_help:
		mov			dx, offset usage
		jmp			exit_with_message

	
	@lbl_install:
		cmp			installed, 1
		jne 		_install
			mov		dx, offset already_msg
			jmp		exit_with_message
		_install:

		; ������� �������� �ணࠬ��
		mov		cx, len					; ����� source
		mov		si, offset new_name		; ���� source
		mov		es, env_ptr				; � ax ���� ᥣ���� ��᫥ int 48h (�.���)
		xor		di, di 					; es:[di] <- ���� destination, dx = 0
		rep		movsb					; ++di, ++si, mov

		; ��।���� ���祭�� ��ண� ����� INT 21h
		mov		ax, 3521h			
		int		21h
		cli
			mov		[old_21h],		bx	; ���࠭�� ��� � ��६�����
			mov		[old_21h+2],	es
			mov		ax, 2521h			; ��⠭���� ���� ����� ���뢠��� INT 21h
			mov		dx, offset catch_21h
			int		21h
		sti

		; ��।���� ���祭�� ��ண� ����� INT 2Fh
		mov		ax, 352Fh			
		int		21h
		cli
			mov		[old_2Fh],		bx	; ���࠭�� ��� � ��६�����
			mov		[old_2Fh+2],	es
			mov		ax, 252Fh			; ��⠭���� ���� ����� ���뢠��� INT 21h
			mov		dx, offset catch_2Fh
			int		21h
		sti

		; TODO print old offset, new offset

		mov		dx, offset @init		; � dx ���� ���� ��᫥ १����⭮� ���
		int		27h 					; �ணࠬ��, �� � ��⠢��� �� १����⭮�


	@lbl_uninstall:
		cmp			installed, 1
		je 			_uninstall
			mov		dx, offset cant_unload1_msg
			jmp		exit_with_message
		_uninstall:

		mov			ah, 0FAh			; �஢�ਬ, ����� �� ���㧨�� �� �����
		mov			al, 01h				; �᫨ ��, � ���㤠 �ணࠬ�� � ���������
		int			2Fh

		cmp 		al, 0AAh
		jne 		__uninstall
			mov		dx, offset cant_unload2_msg
			jmp		exit_with_message
		__uninstall:
		
		mov			dx, offset unloaded_msg
		jmp			exit_with_message


	@lbl_kill:
		cmp			installed, 1
		je 			_kill
			mov		dx, offset cant_unload1_msg
			jmp		exit_with_message
		_kill:

		mov			ah, 0FAh			; �맮��� �ਭ㤨⥫��� ���㧪�
		mov			al, 02h				; ��� �ணࠬ�� ⮦� ���������
		int			2Fh

		mov			dx, offset unloaded_msg
		jmp			exit_with_message


	@lbl_status:
		cmp			installed, 1
		je 			handlers_installed
			mov		dx, offset not_installed_msg
			jmp		exit_with_message
		handlers_installed:
			mov		dx, offset installed_msg
			jmp		exit_with_message


	exit_with_message:
		mov			ah, 09h				; �।��������, �� � dx ���� ��ப�,
		int			21h					; ������ �� ���⠥� �� �࠭
		ret								; � ��室�� �� �ணࠬ��

initialize_entry_point:					; � ��।����� �ࠢ����� � ᠬ�� ��砫�

		mov			ah, 0FAh			; �஢�ਬ ����� ��⠭����
		mov			al, 00h 			; ��襣� ��ࠡ��稪�
		int			2Fh

		cmp			al, 0FFh
		jne			_not_installed
			mov		installed, 1
			jmp		_next1
		_not_installed:
			mov		installed, 0
		_next1:

		; ��㬥��� ��������� ��ப� TODO \s+ ��। ���箬
		cld
		cmp			byte ptr cmd_line[1], '/'
		je			found_slash_or_minus
		cmp			byte ptr cmd_line[1], '-'
		je			found_slash_or_minus
		jmp			@illegal_key

	found_slash_or_minus:				; ���㬥�� ��稭����� � / ��� - (�ࠢ��쭮)

		; ��।����, ����� ���� ���� ��᫥ / ��� -
		mov		cx, 6					; ���祩 5, �㤥� �᪠�� ᨬ��� �
		mov		al, byte ptr cmd_line[2]; ��ப� keys. �᫨ cx �⠭�� 0
		lea 	di, keys 				; �����, �� ��諨 �宦�����
		repne	scasb					; �᫨ 1 - lbls[1*2] help
		shl		cx, 1					; �᫨ 2 - lbls[2*2] install
		mov		di, cx					; � �.�.
		jmp		lbls[di]


; ���� � ᮮ⢥�����騥 ��⪨
keys				db		'skuih'
lbls				dw		@illegal_key, @lbl_help, @lbl_install, @lbl_uninstall, @lbl_kill, @lbl_status

; �������� ��६����
installed 			db		0

; �⮡ࠦ����� ��� �ணࠬ��
new_name			db		20h,00h,00h,01h,00h,'21 2F hook',00h
len					dw		$-new_name

; �����, ����� �뤠�� �ணࠬ�� � ���箬 /h:
usage				db		'����� �ணࠬ�� ��� ���墠� ���뢠��� 21h � 2Fh.',					0Dh,0Ah
					db		'/i -i ��⠭����� ��ࠡ��稪 � ᮮ���� ���� ��ண� � ������ ���뢠���',0Dh,0Ah
					db		'/u -u ���� ��ࠡ��稪,',													0Dh,0Ah
					db		'      �᫨ �� ��⠭���� � ��᫥����, ��⥬',								0Dh,0Ah
					db		'          ᮮ���� ���� ��ண� � ������ ���뢠���;',					0Dh,0Ah
					db		'      ���� �뤠�� ᮮ�饭�� �� �訡��',									0Dh,0Ah
					db		'/k -k �ਭ㤨⥫쭮 ���㧨�� ��ࠡ��稪 �� �����,',						0Dh,0Ah
					db		'      ����� ���� �����४⭮.',											0Dh,0Ah
					db		'/s -s �⮡ࠧ��� ����� ��ࠡ��稪� (��⠭����� / ���)',					0Dh,0Ah
					db		'      � �뢥�� ���� ��ண� � ������ ��ࠡ��稪��',						0Dh,0Ah
					db		'/h -h �� ᮮ�饭�� � �ࠢ���',											0Dh,0Ah
					db		0Dh,0Ah,'$'

; ������, ����� �뤠�� �ணࠬ�� �� �ᯥ譮� �믮������:
installed_msg		db		'�ணࠬ�� ��⠭������ � �����'											,0Dh,0Ah,'$'
not_installed_msg	db		'�ணࠬ�� �� �� ��⠭������ � �����'										,0Dh,0Ah,'$'
unloaded_msg		db		'�ணࠬ�� �ᯥ譮 ���㦥�� �� �����'										,0Dh,0Ah,'$'

; ������, ����� �뤠�� �ணࠬ�� �� �訡���:
illegal_key_msg		db		'�訡��: 㪠��� ������ ���� �� ����᪥. �� �ࠢ�� ����:'				,0Dh,0Ah,0Dh,0Ah,'$'
already_msg			db		'�訡��: �ணࠬ�� 㦥 ����㦥�� � ������'									,0Dh,0Ah,'$'
cant_unload1_msg	db		'�訡��: �ணࠬ�� �� �����㦥�� � �����'									,0Dh,0Ah,'$'
cant_unload2_msg	db		'�訡��: ��㣠� �ணࠬ�� ���墠⨫� ���뢠���'							,0Dh,0Ah,'$'

end @entry
