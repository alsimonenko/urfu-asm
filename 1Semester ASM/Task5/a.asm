.286
.287


assume cs: cseg, ds: dseg, ss:sseg 

sseg segment stack
	db 256 dup (?)
sseg ends 

dseg segment
	a dd 6.0
	b dd 0.11
	k1 dd 2.0
	k2 dd 3.0
	x dd 0.0
	
dseg ends

cseg segment

f1 proc                                      ; ������ ������� - ���������� � �������
	fld x
	fmulp st(1), st;
	ret
f1 endp

f2 proc                                    ;������ ������� -k1* �
	fld k1                 
	fmulp st(1), st
	ret
f2 endp

f3 proc	                                    ;������ 
	fld k2
	fmulp st(1), st
	fadd
	ret
f3 endp

include IntLib.inc
include SexyPrnt.inc

start:
    mov ax, dseg
	mov ds, ax
	
	Begin:     
		finit
		fld x    ; � ����
		fld a
		fcomp st(1) ; ���������� 
		fstsw ax ; ��� ��������� �����, ��� �� ���������
		sahf	 ;� ������� 
		ja pointer_f2orf3 ; x<a   � ����������
		
		call f1 ;x>=a
		jmp exit
		
		pointer_f2orf3:
			fld b
			fcomp st(1)
			fstsw ax
			sahf
			ja pointer_f3
			
			call f2 ;b<=x<a
			jmp exit
		pointer_f3:
			call f3 ; x<b
		
		exit:


		
			mov ax, 4c00h
			int 21h
cseg ends
end start