model tiny
.code
org 100h

start:
    mov ah,02h
    xor dl,dl
    mov cx,16

loop1:
    push cx
    mov cx, 16
loop2:

    int 21h
    inc dl
    loop loop2
    


    mov dh,dl         
    mov dl,13         
    int 21h           
    mov dl,10
    int 21h          
    mov dl,dh        

    pop cx
    loop loop1

    mov ax,4C00h
    int 21h 
end start