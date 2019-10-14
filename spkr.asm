model tiny
.386
.code
.startup
	mov ah,00h ;в текстовый режим, отчищаем экран
	mov al,7h 
	int 10h 
	call menu ;вызов меню
;--------------------------------------	
menu proc	;меню			
start:
	lea dx, message1
	mov ah,09h
	int 21h
re_entry:	
	mov ah,01h ;выбор действия
	int 21h 

	cmp al,"1"
	jne next1
	call task1
	jmp start
next1:
	cmp al,"2"
	jne next2
	call task2
	jmp start
next2:
	cmp al,"3"
	jne next3
	call exit
next3:
	jmp re_entry
	ret
menu endp	
;--------------------------------------	
task1 proc	;первая задача			
	call next_str
	call next_str		
	
	call input_A
	
	call next_str
	
	call out_array_A
	
	call next_str
	
	call check
	
	call next_str
	
	lea dx,message2
	mov ah,09h
	int 21h
	

	call out_buf
	
	lea dx,message4
	mov ah,09h
	int 21h
	
    mov ah,0 ;ввод с клавиатуры
    int 16h
	
	ret
task1 endp
;--------------------------------------
shift proc
	push cx
	push ax
	push si
	
	mov shift_n,cx
	mov ax,4
	sub ax,cx
	mov cx,ax
next10:	
	xor ax,ax
	dec si
	xchg al,A[si]
	add si,shift_n
	mov A[si],al
	sub si,shift_n
	loop next10
	
	pop si
	pop ax
	pop cx
	ret
shift endp
;--------------------------------------
input_A proc
	mov si,0 
enter_A:
	mov cx,4
enter_dg:
    mov ah,01h
    int 21h
	cmp al,0dh
	je next7
	sub al,30h
    mov A[si],al
    inc si
	loop enter_dg
	call next_str
	jmp next9
next7:
	call shift
next9:
	add si,cx
	cmp si,39
    jle enter_A
	
	ret
input_A endp
;--------------------------------------
digit proc
	push bx
	push si
	push cx

	xor dx,dx 

	mov ax,si
	mov bl,4
	mul bl
	mov si,ax
	;imul si,4	
	mov cx,4
	mov bx,10
	mov ax,1000
	
to_dec:
	push ax
	mov dl,A[si]
	mul dx 
	inc si
	add A_current,ax
	pop ax
	div bx
	loop to_dec
	
	pop cx
	pop si
	pop bx

	ret
digit endp
;--------------------------------------
check proc
	
	mov si,0
	call digit
	mov ax,A_current
	mov A_first,ax
	mov A_current,0
	
	mov si,9
	call digit
	mov ax,A_current
	mov A_last,ax
	mov A_current,0
	
	mov si,1
    mov cx,8
	mov bx,0
check_array:	;проверка массива по условию
	call digit
	mov ax,A_current
	cmp ax,A_first
	jg next4
	jmp pass
next4:
	cmp ax,A_last
	jl next5
	jmp pass
next5:
	mov ax,si	;заносим в массив ответ
	inc al
	cmp buf[0],0
	jne next6
	mov buf[0],al
next6:
	mov buf[1],al	
pass:
	inc si
	mov A_current,bx
	loop check_array
	ret
check endp
;--------------------------------------
out_array_A proc
	mov si,0
    mov cx,40
	mov bl,4
output_array: ;вывод массива
	mov ah,02h
	mov dl,A[si]
	add dl,30h
	int 21h	
	inc si
	
	mov ax,si
	div bl
	cmp ah,0
	jne next8
	mov ah,02h
	mov dl,' '
	int 21h
next8:
	
	loop output_array
	ret
out_array_A endp
;--------------------------------------
out_buf proc
	mov si,0
    mov cx,2
output_array2: ;вывод массива-ответа
	mov ah,02h
	mov dl,buf[si]
	add dl,30h
	int 21h	
	mov dl,' '
	int 21h	
	inc si
	loop output_array2
	ret
out_buf endp
;--------------------------------------
task2 proc	;вторая задача
	lea dx,message3
	mov ah,09h
	int 21h
	lea dx,message4
	int 21h
	mov ah,0 ;ввод с клавиатуры
    int 16h
	
	mov ax,13h; устанавливаем режим 320х240
    int 10h  
	
	mov	ax,0	;инициализаци¤ мыши
	int	33h
	mov	ax,1	; показать курсор
	int	33h
	
	mov ax,0ch ;вызов обработчика
	mov	cx,0002h ;условие вызова
	mov dx,offset handle1
	int	33h
	
    mov ah,0 ;ввод с клавиатуры
    int 16h
	
	mov ax,000Ch ;закрытие обработчка
	mov cx,0000h
	int 33h
	
	mov ax,3 ;назад в текстовый режим
	int 10h
	
	ret
task2 endp	
;--------------------------------------	
exit proc	;выход из программы			
	mov ah,4ch				
	int 21h
	ret
exit endp	
;--------------------------------------	
next_str proc	;на следующую строку
	push dx
	push ax
	
	mov dl,13
	mov ah,02h
	int 21h
	mov dl,10
	mov ah,02h
	int 21h
	
	pop ax
	pop dx
	ret
next_str endp
;--------------------------------------	
draw_vert proc	;нарисовать вертикальную линию		 	
	push ax
	mov al,0Fh; цвет линий
a1: stosb
    add di,319
    loop a1	
	pop ax
	ret
draw_vert endp
;--------------------------------------	
draw_hor proc	;нарисовать горизонтальную линию			
	push ax
	mov al,0Fh; цвет линий
    rep stosb
	pop ax
	ret
draw_hor endp		
;--------------------------------------	
handle1 proc far ;обработчик мыши
	push cx
	push dx
    push 0A000h; начало видеопам¤ти в графических режимах
    pop es
	
	cmp x1_pos,-1 ;проверка первого вызова обработчика
	jne draw
	mov y1_pos,dx
	mov x1_pos,cx
	shr x1_pos,1
	jmp end_hand
draw:	;если не первый - рисуем прямоугольник
	call rectangle
end_hand:	
	pop dx
	pop cx
	
	ret 
handle1 endp	
;--------------------------------------	
rectangle proc
	mov ax,2 ;убрать курсор пока рисуем
	int 33h
	
	shr cx,1	
	cmp cx,x1_pos	;выбор первой  точки с наименьшими координатами
	jg pas1
	xchg cx,x1_pos
pas1:
	cmp dx,y1_pos
	jg pas2
	xchg dx,y1_pos
pas2:	
	mov y2_pos,dx
	mov x2_pos,cx	
	
	shr cx,1
	mov ax,320
	mul y1_pos	;начальная точка
	add ax,x1_pos	
	
	mov di,ax	;левая сторона
    mov cx,y2_pos
	sub cx,y1_pos
	call draw_vert
		
	mov di,ax	;верхняя сторона
	mov cx,x2_pos
	sub cx,x1_pos
	call draw_hor
	
	add ax,x2_pos	;правая сторона
	sub ax,x1_pos
	mov di,ax
    mov cx,y2_pos
	sub cx,y1_pos
	call draw_vert
	sub ax,x2_pos
	add ax,x1_pos
	
	mov ax,320	; нижняя сторона
	mul y2_pos
	add ax,x1_pos
	mov di,ax
	mov cx,x2_pos
	sub cx,x1_pos
	inc cx
	call draw_hor
	
	mov x1_pos,-1 ;возврат начального значения для повторного рисования
	ret
rectangle endp
;--------------------------------------	
	ret ;конец программы

message1 db 0dh, 0ah,"Choose task",0dh, 0ah,"Press 1 to Task-1 ",0dh, 0ah,"Press 2 to Task-2 ",0dh, 0ah,"Press 3 to exit from program ",0dh, 0ah,'$',0
message2 db "Indexes of elements that fit the condition(A[1] < A[i] < A[10]): $"
message3 db 0dh, 0ah,"Select two points to build a rectangle $"
message4 db 0dh, 0ah,"Press any key",0dh, 0ah,"$",0

A db 40 dup(0)
A_first dw 0000
A_last dw 0000
A_current dw 0
buf db 0,0
shift_n dw 0


x1_pos dw -1
y1_pos dw 0
x2_pos dw 0
y2_pos dw 0

end