model tiny

.code
org 100h
start:
    mov ah, 05h
	mov al, 2
	int 10h

    mov ax,4C00h
    int 21h
end start