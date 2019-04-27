; Name:             music.asm
; Assemble:         tasm.exe music.asm
; Link:             tlink.exe music.obj
; Run in DOSBox:    music.exe

a0      =   43388       ;   27.5000 hz
ais0    =   40953       ;   29.1353 hz
h0      =   38655       ;   30.8677 hz
c1      =   36485       ;   32.7032 hz
cis1    =   34437       ;   34.6479 hz
d1      =   32505       ;   36.7081 hz
dis1    =   30680       ;   38.8909 hz
e1      =   28958       ;   41.2035 hz
f1      =   27333       ;   43.6536 hz
fis1    =   25799       ;   46.2493 hz
g1      =   24351       ;   48.9995 hz
gis1    =   22984       ;   51.9130 hz
a1      =   21694       ;   55.0000 hz
ais1    =   20477       ;   58.2705 hz
h1      =   19327       ;   61.7354 hz
c2      =   18243       ;   65.4064 hz
cis2    =   17219       ;   69.2957 hz
d2      =   16252       ;   73.4162 hz
dis2    =   15340       ;   77.7817 hz
e2      =   14479       ;   82.4069 hz
f2      =   13666       ;   87.3071 hz
fis2    =   12899       ;   92.4986 hz
g2      =   12175       ;   97.9989 hz
gis2    =   11492       ;  103.8260 hz
a2      =   10847       ;  110.0000 hz
ais2    =   10238       ;  116.5410 hz
h2      =   9664        ;  123.4710 hz
c3      =   9121        ;  130.8130 hz
cis3    =   8609        ;  138.5910 hz
d3      =   8126        ;  146.8320 hz
dis3    =   7670        ;  155.5630 hz
e3      =   7240        ;  164.8140 hz
f3      =   6833        ;  174.6140 hz
fis3    =   6450        ;  184.9970 hz
g3      =   6088        ;  195.9980 hz
gis3    =   5746        ;  207.6520 hz
a3      =   5424        ;  220.0000 hz
ais3    =   5119        ;  233.0820 hz
h3      =   4832        ;  246.9420 hz
c4      =   4561        ;  261.6260 hz
cis4    =   4305        ;  277.1830 hz
d4      =   4063        ;  293.6650 hz
dis4    =   3835        ;  311.1270 hz
e4      =   3620        ;  329.6280 hz
f4      =   3417        ;  349.2280 hz
fis4    =   3225        ;  369.9940 hz
g4      =   3044        ;  391.9950 hz
gis4    =   2873        ;  415.3050 hz
a4      =   2712        ;  440.0000 hz
ais4    =   2560        ;  466.1640 hz
h4      =   2416        ;  493.8830 hz
c5      =   2280        ;  523.2510 hz
cis5    =   2152        ;  554.3650 hz
d5      =   2032        ;  587.3300 hz
dis5    =   1918        ;  622.2540 hz
e5      =   1810        ;  659.2550 hz
f5      =   1708        ;  698.4560 hz
fis5    =   1612        ;  739.9890 hz
g5      =   1522        ;  783.9910 hz
gis5    =   1437        ;  830.6090 hz
a5      =   1356        ;  880.0000 hz
ais5    =   1280        ;  932.3280 hz
h5      =   1208        ;  987.7670 hz
c6      =   1140        ; 1046.5000 hz
cis6    =   1076        ; 1108.7300 hz
d6      =   1016        ; 1174.6600 hz
dis6    =    959        ; 1244.5100 hz
e6      =    905        ; 1318.5100 hz
f6      =    854        ; 1396.9100 hz
fis6    =    806        ; 1479.9800 hz
g6      =    761        ; 1567.9800 hz
gis6    =    718        ; 1661.2200 hz
a6      =    678        ; 1760.0000 hz
ais6    =    640        ; 1864.6600 hz
h6      =    604        ; 1975.5300 hz
c7      =    570        ; 2093.0000 hz
cis7    =    538        ; 2217.4600 hz
d7      =    508        ; 2349.3200 hz
dis7    =    479        ; 2489.0200 hz
e7      =    452        ; 2637.0200 hz
f7      =    427        ; 2793.8300 hz
fis7    =    403        ; 2959.9600 hz
g7      =    380        ; 3135.9600 hz
gis7    =    359        ; 3322.4400 hz
a7      =    339        ; 3520.0000 hz
ais7    =    320        ; 3729.3100 hz
h7      =    302        ; 3951.0700 hz
c8      =    285        ; 4186.0100 hz

whole_note          = 1800
half_note_dot       = whole_note/2 + whole_note/4
half_note           = whole_note/2
quarter_note_dot    = whole_note/4 + whole_note/8
quarter_note        = whole_note/4
eighth_note         = whole_note/8
pause               = 30

LOCALS
.MODEL tiny
.STACK

.DATA
div1 dd 14318180
div2 dd 786432000

AuldLangSyne dw 0,eighth_note
    dw g3,quarter_note
    dw c4,quarter_note_dot,h3,eighth_note,c4,quarter_note,e4,quarter_note
    dw d4,quarter_note_dot,c4,eighth_note,d4,quarter_note,e4,eighth_note,d4,eighth_note
    dw c4,quarter_note,0,pause,c4,quarter_note,e4,quarter_note,g4,quarter_note
    dw a4,half_note_dot,0,pause,a4,quarter_note
    dw g4,quarter_note_dot,e4,eighth_note,0,pause,e4,quarter_note,c4,quarter_note
    dw d4,quarter_note_dot,c4,eighth_note,d4,quarter_note,e4,eighth_note,d4,eighth_note
    dw c4,quarter_note_dot,a3,eighth_note,0,pause,a3,quarter_note,g3,quarter_note
    dw c4,half_note_dot,0,quarter_note,a4,quarter_note
    dw g4,quarter_note_dot,e4,eighth_note,0,pause,e4,quarter_note,c4,quarter_note
    dw d4,quarter_note_dot,c4,eighth_note,d4,quarter_note,a4,quarter_note
    dw g4,quarter_note_dot,e4,eighth_note,0,pause,e4,quarter_note,g4,quarter_note
    dw a4,half_note_dot,0,pause,a4,quarter_note
    dw g4,quarter_note_dot,e4,eighth_note,0,pause,e4,quarter_note,c4,quarter_note
    dw d4,quarter_note_dot,c4,eighth_note,d4,quarter_note,e4,eighth_note,d4,eighth_note
    dw c4,quarter_note_dot,a3,eighth_note,0,pause,a3,quarter_note,g3,quarter_note
    dw c4,half_note_dot
    dw 0,0

Welcome db "[p] Pause (any key for resuming) [r] Restart  [x] Exit $"

.CODE
.486

delay PROC NEAR ms:word     ; ARG on stack: delay in ms (granularity ~55 ms)
    push bp
    mov bp, sp
    sub sp, 4

    xor ax, ax
    mov es, ax
    mov edx, es:[046Ch]

    ; Ticks/sec: 14318180 / 12 / 65536 = 18.206785178403397675542331069912 -> 54.9254 mS

    fild word ptr ms
    fimul dword ptr div1
    fidiv dword ptr div2
    fistp dword ptr [bp-4]

    add edx, [bp-4]

    @@L1:
    mov eax, es:[046Ch]
    cmp eax, edx
    jb @@L1

    leave
    ret 2
delay ENDP

play PROC NEAR              ; ARG si: pointer to freq/duration pairs, end with 0/0
    mov di, si              ; Preserve it for the check_key routine

    @@L1:
    cmp word ptr [si], 0    ; No tone?
    je @@J1                 ; Yes: skip the sound blocks, just delay

    ; Set up frequency
    cli                     ; Don't disturb the setting sequence
    mov al, 0B6h
    out 43h, al
    mov ax, [si]
    out 42h, al
    mov al, ah
    out 42h, al
    sti

    in al, 61h              ; Speaker on
    or al, 03h
    out 61h, al

    @@J1:
    push word ptr [si+2]    ; Hold the tone for a certain while
    call delay

    in al, 61h              ; Speaker off
    and al, 0FCh
    out 61h, al

    add si, 4
    call check_key          ; DI: pointer for restart
    cmp word ptr [si+2], 0
    jne @@L1

    ret
play ENDP

check_key PROC              ; ARG di: pointer for restart
    mov ah, 1               ; Check keyboard
    int 16h
    jz @@done               ; No key -> return
    mov ah, 0               ; Get key
    int 16h

    @@K0:                   ; Pause
    cmp al, 'p'
    jne @@K1
    call @@pause
    @@K1:
    cmp al, 'P'
    jne @@K2
    @@pause:
    mov ah, 0
    int 16h
    push eighth_note
    call delay
    jmp @@K0

    @@K2:                   ; Exit
    cmp al, 'x'
    je @@exit
    cmp al, 'X'
    jne @@K3
    @@exit:
    mov ax, 4C00h
    int 21h

    @@K3:                   ; Restart
    cmp al, 'r'
    je @@restart
    cmp al, 'R'
    jne @@K4
    @@restart:
    mov si, di

    @@K4:                   ; Placeholder for further key checks
    @@done:
    ret
check_key ENDP

main PROC
    mov ax, @data
    mov ds, ax

    mov ah, 9
    lea dx, Welcome
    int 21h

    lea si, AuldLangSyne
    call play

    mov ax, 4C00h
    int 21h
main ENDP

END main