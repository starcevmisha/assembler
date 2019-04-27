model tiny 
.186 
.code
org 100h
start:
;
    	in	al, 61h     ;пoлучaeм знaчeниe из пopтa b
	and	al, 11111100b  ;oтключaeм динaмик oт тaймepa
;
	cli                 ;зaпpeт пpepывaний
;количество нот
	mov	cx,3
play:	push	cx
;загружаем данные
	mov	cx, duration[si];длитeльнocть тoнa в сx
	mov	dx, music[si];длительность полу-волны в dx
next_cycle:
	push	cx
;генерируем частоту
	call	beep;
	call	beep;
;цикл вопроизведения одной ноты
	pop	cx
	loop	next_Cycle
;востанавливаем счетчик
	pop	cx
;следующее значение
	inc	si
	inc	si
;цикл проигрывания всй мелодии
	loop	play
	sti;paзpeшaeм пpepывaния
;ждем нажатия на любую клавишу
	xor	ax,ax
	int	16h
;выход в DOS
	ret
;инвентируем бит включения-выключения динамика
beep:	xor	al,00000010b
	out	61h,al
;запоминаем состояние порта
	push	ax
;запоминаем задержку
	push	dx
;сбрасываем старшеё слово паузы
	xor	cx,cx
;функция задержки
	mov	ah,86h
	int	15h
;востанавливаем регистры
	pop	dx
	pop	ax
	ret
;длительность одной полуволны ноты
music		dw	6a6h,430h,647h;ре = 293,7 ля-диез = 466,2 ре-диез = 311,1
;длительность воспроизведения
duration	dw	440, 892, 311;ре = 1,5 ля-диез = 2 ре-диез = 1 в секундах
end start