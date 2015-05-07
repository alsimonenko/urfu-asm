	IDEAL
	MODEL tiny	; com-䠩�

	CONST
UP	EQU	01
DOWN	EQU	02
LEFT	EQU	03
RIGHT	EQU	04
heade	EQU	0000111010110010b	;ᨬ��� � �����
body	EQU	0000111010110000b	;ᨬ��� � �����
rabitb	EQU	0000011100101010b	;ᨬ��� * ���

	DATASEG
StrPoints	db	'��� �窨:      室�:$'
GoodBye		db	'�⮡� ����� ����� ���� ������ Y, ��室 N.'
t		dw	1	;�ᯮ����⥫쭯� ��६�����
ExFlag		db	0	;䫠�
mooving		dw	?	;室�
time		dw	?	;�६� ����প�
Points		dw	?	;�窨
a		dw	?	;�ᯮ����⥫쭠� ��६�����
piton		dw	500 dup (?)	���न���� ��⮭�

	CODESEG
	ORG 100h
Start:
	call StartingCondition	;��砫�� �᫮���
@@1:	
	mov ah,1		;�஢�ઠ �� ����⨥ ������
	int 16h			;��஡�⪠ ������
	call Press		;��ࠡ�⪠ ����⮩ ������
	cmp [ExFlag],1		
	je Exit			;�᫨ ExFlaf=1 ���� �� ��室		
	xor ah,ah
	int 1Ah
	mov cx,dx		;����砥� ⥪�饥 �६�
	sub dx,[a]		;dx=dx-a
	cmp dx,[time]		;�ࠢ������ � �६���� ����প�
	jbe @@1			;�᫨ dx>=a
	call DecDigit		;���⠥� 室� � �窨
	inc [mooving]		;㢥��稢��� ���-�� 蠣��
	call Rabit		;�⠢�� �஫���
	mov [a],cx		;� a - ����� �६�
	call UPiton		;����� ��������� ��⮭�
	jmp @@1		
Exit:	
	call StopTimer		;����뢠�� ���� ⠩���
	call More		;����訢��� � �த�������
	cmp [ExFlag],0		
	je Start		;�᫨ �த������
	call SetScreen		;������ �࠭
	mov ah,04Ch		;����� �ணࠬ��
	int 21h

;���⠥� ᨬ��� �� ax �� ⥪�騥 ����樨 ��⮭�
PROC	PutPiton
	push es
	push si		;��࠭塞 ॣ�����
	push cx
	push di
	mov cx,0B800h	;�����������
	mov es,cx
	mov cx,500	;max ����� ��⮭�
	mov di,2
	cmp al,' '	;�᫨ � ax �஡��
	je @@p1		;���室��

	mov ax,heade		;���⠥� ������ ��⮭�
	mov si,[piton+di]	;�  si ���न���� ������	
	inc di
	inc di
	mov [es:si],ax		;���⠥�
	mov ax,body		;� ax ⥫� ��⮭�
@@p1:
	mov si,[piton+di]	
	cmp si,0FFFFh		;墮�� ��⮭�
	je @@p2			;� 横�� ���⠥� ��⮭� ����
	inc di			;�� ��ࢥ��� �� 墮��
	inc di
	mov [es:si],ax
	loop @@p1
@@p2:
	pop di
	pop cx			;����⠭�������� ॣ�����
	pop si
	pop es
	ret
ENDP	PutPiton

;��頥� �࠭
PROC	SetScreen
	mov cx,0B800h
	mov es,cx
	mov cx,2000	;�ᥣ� ᨬ����� �� �࠭�
	xor si,si
@@p3:
	mov [es:si],0000011100100000b	;�� �஡�� �ண� 梥�
	add si,2
	loop @@p3	
	ret
ENDP	SetScreen

;����塞 ����� ������ ��⮭�
PROC	ReBuild
	push bx
	push cx		;��࠭塞 �����塞� ॣ�����
	push dx		
	push si
	push es
	mov cx,500	;max ����� ��⮭�
	mov si,4
	cmp [word piton],UP	;� ����ᨬ��� �� ��ࢮ�� ᫮��
	je @@pUp		;�����⢫塞 ���室
	cmp [word piton],DOWN
	je @@pDw
	cmp [word piton],LEFT
	je @@pLf
	cmp [word piton],RIGHT
	je @@pRh
@@pUp:
	mov bx,[piton+2]
	sub [word piton+2],160	;�����
@@p5:
	cmp [piton+si],0FFFFh	;墮�� ��⮭�
	je  @@ex
	mov dx,[piton+si]	;������ ��᫥���饩 ����樨 ��ᢠ�����
	mov [piton+si],bx	;���न���� �।��饩
	mov bx,dx
	inc si
	inc si
	loop @@p5
	jmp @@ex

@@pDw:
	mov bx,[piton+2]
	add [word piton+2],160	;����
@@p6:
	cmp [piton+si],0FFFFh	;墮�� ��⮭�
	je @@ex
	mov dx,[piton+si]	;������ ᫥���饩 ����樨 ��ᢠ�������
	mov [piton+si],bx	;���न���� �।뤩饩
	mov bx,dx
	inc si
	inc si
	loop @@p6
	jmp @@ex

@@pLf:
	mov bx,[piton+2]	;�����
	sub [word piton+2],2
@@p7:
	cmp [piton+si],0FFFFh	;墮�� ��⮭�
	je @@ex
	mov dx,[piton+si]
	mov [piton+si],bx
	mov bx,dx
	inc si
	inc si
	loop @@p7
	jmp @@ex

@@pRh:
	mov bx,[piton+2]	;��ࠢ�
	add [word piton+2],2	
@@p8:
	cmp [piton+si],0FFFFh	;墮�� ��⮭�
	je @@ex
	mov dx,[piton+si]
	mov [piton+si],bx
	mov bx,dx
	inc si
	inc si
	loop @@p8

@@ex:	
	mov di,0B800h		;����������
	mov es,di
	xor di,di
	mov si,[piton+2]
	mov dx,[es:si]
	cmp dx,rabitb   	;�᫨ �� ��� ��⮭� �஫��
	jne @@e
@@p15:
	add di,2
	cmp [piton+di],0FFFFh
	jne @@p15		;��室�� 墮�� ��⮭�
	inc [Points]		;㢥��稢��� �窨

	cmp [Points],30		;�᫨ ���ࠫ� 30 �窮� - 㬥��蠥� 
	jne @@p25		;�६� ����প�
	dec [Time]
	jmp @@p30
@@p25:
	cmp [Points],70		;�᫨ ���ࠫ� 70 �窮� - 㬥��蠥�
	jne @@p30		;�६� ����প�
	dec [Time]
@@p30:

	mov bx,[piton+di-2]	;���騢��� 墮�� ��⮭� �� ���ࠢ�����
	mov dx,[piton+di-4]	;��������
	sub dx,bx
	add bx,dx
	mov [piton+di],bx
	mov [piton+di+2],0FFFFh	;墮�� ��⮭�
@@e:
	pop es
	pop si
	pop dx			;����⠭�������� ॣ�����
	pop cx		
	pop bx
	ret
ENDP	ReBuild

PROC	UPiton
	push es
	mov ax,0000011100100000b	;�� ��� �஡��	
	call PutPiton			;��ࠥ� ��⮭�
	call ReBuild			;���� ���न����
	push 0B800h			;�����������
	pop es
	mov si,[piton+2]		;� si ������ ������ ��⮭�
	inc si
	cmp [byte es:si],00001001b	;���堫 ��⮭
	jne @@p21
	mov [ExFlag],1			;�� ࠬ��
@@p21:	
	mov ax,[body]	
	call PutPiton			;���⠥� ᠬ��� ��⮭�
	pop es
	ret
ENDP	UPiton

;��ࠡ��뢠�� ������� �������
PROC 	Press
	push dx
	jz @@p9		;�᫨ ���� ���������� ����, � ��室��
	xor ah,ah	;���� ���뢠�� ��� ����⮩ ������
	int 16h
	cmp ax,011bh	;�� ������ ESC-��室
	jne @@p16
	mov [ExFlag],1	
@@p16:
	mov dx,[piton]
	mov [word piton],UP
	cmp ax,4800h		;������ �����
	je @@p9	
	mov [word piton],DOWN
	cmp ax,5000h		;������ ����
	je @@p9	
	mov [word piton],LEFT	
	cmp ax,4B00h		;������ �����
	je @@p9	
	mov [word piton],RIGHT	
	cmp ax,4D00h		;������ ��ࠢ�
	je @@p9	
	mov [piton],dx
@@p9:
	pop dx
	ret
ENDP 	Press

;��楤�� �������� ��砩��� �᫮ �१ ⠩���
PROC	GetRandom
	push es
	push si			;��࠭塞 ॣ�����
	push bx
	mov ax,0B800h
	mov es,ax		;�����������
@@p21:
	mov al,10000110b	;�ࠢ���饥 ᫮��
	out 43h,al
	in al,42h
	mov ah,al
	in al,42h
	xchg al,ah		;� ax ��砩��� �᫮ �� 1 �� 1600
	shl ax,1		;� ax ���歮� �᫮ �� 3200- ��
	mov si,ax		;���न��� �஫���
	inc si
	mov bl,00001010b	;���ਡ�� ᠬ��� ��⮭�
	cmp [byte es:si],bl
	je @@p21
	mov bl,00001001b	;���ਡ�� ࠬ��
	cmp [byte es:si],bl
	je @@p21

	pop bx			
	pop si			;����⠭�������� ॣ�����
	pop es
	ret
ENDP	GetRandom

;��楤�� ���⠥� �஫���
PROC	Rabit
	push ax
	push si		;��࠭塞 ॣ�����
	push es
	inc [t]
	mov si,25
	sub si,[Time]
	cmp [t],si
	jne @@p10	;�᫨ ��諮 ����� 祬 24-Time 室�� - ��室��
	call GetRandom	;����砥� ���न���� �஫���
	mov si,ax
	mov ax,0B800h
	mov es,ax
	mov ax,rabitb
	mov [es:si],ax	;���⠥� �஫���
	mov [t],1
@@p10:
	pop es
	pop si		;����⠭�������� ॣ�����
	pop ax
	ret
ENDP	Rabit

;��楤�� ���� ࠬ�� � ���⠥� ����� ��ப�
PROC	Place
	push es
	mov ax,0B800h
	mov es,ax
	mov al,'�'
	mov ah,00001001b	;ᨭ�� 梥�
	mov [es:0000],ax	;���⠥� 㣮���	
	mov al,'�'
	mov [es:3200],ax
	mov al,'�'
	mov [es:158],ax
	mov al,'�'
	mov [es:3358],ax
	mov cx,78
	mov si,2
	mov al,'�'
@@p19:
	mov [es:si],ax		;���⠥� ��ਧ��⠫�� �����
	mov [es:si+3200],ax
	inc si		
	inc si
	loop @@p19
	mov cx,19
	mov al,'�'
	mov si,160
@@p20:
	mov [es:si],ax
	mov [es:si+158],ax	;���⠥� ���⨪���� �����
	add si,160		
	loop @@p20
	xor si,si
	xor di,di
@@p22:	mov al,[StrPoints+si]
	cmp al,'$'
	je @@pe	
	mov [es:3420+di],ax	;���⠥� ���� �� ����⨬ ᨬ��� $
	inc di
	inc di
	inc si
	jmp @@p22
@@pe:
	pop es
	ret
ENDP	Place

; ��楤�� �뢮��� ���祭�� dx �� �࠭ � �����筮� ����
PROC	DecDigit
        push ax
	push bx
        push cx    	; ��࠭���� �ᯮ��㥬�� � ��楤��
        push dx    	; ॣ���஢ � �⥪�
        push si
	push es
	push di
	mov dx,[Points]
	xor bx,bx
Sta:	
	xor di,di
	mov cx,0B800h	;�����������
	mov es,cx
        mov ax,dx
        mov si,10 	; ����� �� 10
        mov cx,0   	; ��� �ᥫ ����饭��� � �⥪
@nz:
        mov dx,0
        div si		; ��⭮� � ax, ���⮪ � dx
        push dx    	; �������� 1 ���� � �⥪
        inc cx
        cmp ax,0   	; �ࠢ����� ax � 0
        jne @nz
	cmp bx,1	
	je @m2
@m1:

        pop dx     	;����� ���� � ���⭮� ���浪�
        add dl,'0'
	mov dh,00001010b	;������ 梥�
        mov [es:3442+di],dx
	inc di
	inc di
        loop @m1
	mov dx,[mooving]	
	mov bx,1
	jmp Sta		;�����頥��� � ��砫� ��楤��� � 
			;���⠥� 室�
@m2:

        pop dx     	;����� ���� � ���⭮� ���浪�
        add dl,'0'
	mov dh,00001010b	;������ 梥�
        mov [es:3464+di],dx
	add di,2
        loop @m2

	pop di
	pop es
        pop si
        pop dx
        pop cx     	;����⠭�������� ॣ����� �� �⥪�
	pop bx
        pop ax
        ret
ENDP	DecDigit


;��楤�� ������ ����� �� �த������� ����
PROC	More
	push es
	mov si,0B800h		;�����������
	mov es,si
	mov si,0FFFFh
	mov ah,00001010b	;������ 梥�
@@p32:	inc si
	mov al,[byte GoodBye+si];� al �㪢� �� ��ப�
	shl si,1		;si=si*2		
	mov [es:3580+si],ax	;���⠥�
	shr si,1		;si=si/2
	cmp al,'.' 		;���⠥�, ���� �� ����⨬ ���
	jne @@p32
@@no:	mov ah,01		;���� ������ ������
	int 21h
	cmp al,'Y'			
	jne @@p31
	mov [ExFlag],0		;�᫨ �த������
	jmp @@p33
@@p31:
	cmp al,'N'
	jne @@no		;�᫨ �� Y � �� N ����� �� ࠧ
@@p33:	
	pop es
	ret
ENDP	More

;�ணࠬ���㥬 ⠩���
PROC	SetTimer
	in al,61h		;���뢠�� ������ ��� ������ 2
	or al, 00000001b	
	out 61h,al
	mov al,10110110b	;�ࠢ���騩 ����
	out 43h,al		;�����-2 ����-2 ०��-3 � ����筮� ����  
	mov ax,1600		;max ��������� ��砩��� �᫮
	out 42h,al		
	mov al,ah
	out 42h,al
	ret
ENDP	SetTimer	

PROC	StopTimer
	in al,61h	;����뢠�� ������ ��� ������ 2
	and al,11111110b
	out 61h,al
	ret
ENDP	StopTimer

;��楤�� ��⠭�������� ��砫�� ��⠭���� ����
PROC	StartingCondition
	mov ah,02h		;����� �����
	mov dh,25
	int 10h
�	mov [time],2		;��砫쭠� ����প�
	mov [Points],0		;� ��砫� - 0 �窮�
	mov [mooving],0		;0 室��
	call SetTimer		;��� ����祭�� ��砩��� �ᥫ
	xor ah,ah		;������� ⥪�饥 �६�
	int 1Ah		
	mov [a],dx		;��࠭��� � a 
	call SetScreen		;���⪠ �࠭�
	call Place		;���ᮢ��� ࠬ��		
	call DecDigit		;�뢥�� �窨
	mov [piton],DOWN	;᭠砫� ��⮭ ������ ��ࠢ�
	mov dx,170		;��砫쭠� ������ ��⮭�	
	mov [piton+2],dx
	mov dx,172
	mov [piton+4],dx
	mov [piton+6],0FFFFh	;�� 墮�� ��⮭�
	mov ax,[body]	
	call PutPiton		;���⠥� ��⮭� �� �࠭	
	ret
ENDP	StartingCondition
	END Start