jumps
IDEAL
MODEL small
STACK 100h
DATASEG

; need to add advanced movement, *kirby suck, enemies spawn
; need to fix check bottom procs to check all side
; need to finish swordman
; need to fix delay
;================================
;all the pictures

;screens
arena 	db 'arena.bmp',0
main 	db 'main.bmp',0
ls 		db 'LS.bmp',0
ws 		db 'WS.bmp',0

;enemies  ;swordman
;left facing
sml1 	db 'SML1.bmp',0
sml2 	db 'SML2.bmp',0
sml3 	db 'SML3.bmp',0
sml4 	db 'SML4.bmp',0
sml5 	db 'SML5.bmp',0
sml6 	db 'SML6.bmp',0
sml7 	db 'SML7.bmp',0

;right facing
smr1 	db 'SMR1.bmp',0
smr2 	db 'SMR2.bmp',0
smr3 	db 'SMR3.bmp',0
smr4 	db 'SMR4.bmp',0
smr5 	db 'SMR5.bmp',0
smr6 	db 'SMR6.bmp',0
smr7 	db 'SMR7.bmp',0

;damaged left and right
sdl		db 'SDL.bmp',0
sdr		db 'SDR.bmp',0

;attack animation
whl 	db 'Whoosh.bmp',0
whr 	db 'WhooshR.bmp',0

;kirby

;rest
krest 	db 'KR.bmp',0
krestr 	db 'KRR.bmp',0

;left facing
kml1	db 'KML1.bmp',0 
kml2	db 'KML2.bmp',0
kml3	db 'KML3.bmp',0
kml4	db 'KML4.bmp',0
kml5	db 'KML5.bmp',0
kml6	db 'KML6.bmp',0
kml7	db 'KML7.bmp',0
kml8	db 'KML8.bmp',0

;right facing
kmr1 	db 'KMR1.bmp',0
kmr2 	db 'KMR2.bmp',0
kmr3 	db 'KMR3.bmp',0
kmr4 	db 'KMR4.bmp',0
kmr5 	db 'KMR5.bmp',0
kmr6 	db 'KMR6.bmp',0
kmr7 	db 'KMR7.bmp',0
kmr8 	db 'KMR8.bmp',0

;jump left facing
kj1 	db 'KJ1.bmp',0
kj2 	db 'KJ2.bmp',0
kj3 	db 'KJ3.bmp',0
kj4 	db 'KJ4.bmp',0
kj5 	db 'KJ5.bmp',0
kj6 	db 'KJ6.bmp',0

;jump right facing
kjr1 	db 'KJR1.bmp',0
kjr2 	db 'KJR2.bmp',0
kjr3 	db 'KJR3.bmp',0
kjr4 	db 'KJR4.bmp',0
kjr5 	db 'KJR5.bmp',0
kjr6 	db 'KJR6.bmp',0

;fly left
kfl1 	db 'KFL1.bmp',0
kfl2 	db 'KFL2.bmp',0
kfl3 	db 'KFL3.bmp',0

;fly right
kfr1 	db 'KFR1.bmp',0
kfr2 	db 'KFR2.bmp',0
kfr3 	db 'KFR3.bmp',0

; down and slide
kj7 	db 'KJ7.bmp',0 ;kirby down left
kdr 	db 'KDR.bmp',0 
ksll	db 'KSLL.bmp',0
kslr	db 'KSLR.bmp',0

; damaged left and right
kdar1 	db 'KDAR1.bmp',0
kdar2 	db 'KDAR2.bmp',0
kdal1 	db 'KDAL1.bmp',0
kdal2 	db 'KDAL1.bmp',0

continue db 0 ; 0 for no, 1 for yes

kirbylastpic 		dw 	? ; saves the last pic of kirby
smlastpic 			dw 	? ; saves the last pic of sword man

kirby_life		db 5
sm_life 		db 3
kirby_loss 		db 0 ; 1 for lost
sm_loss 		db 0 ; 1 for lost

;vars for time save
SaveTimeHundredth 	db 	?
SaveTimeSecond 		db 	?
smtimesecond 		db 	?
smtimehundredth 	db 	?
timepassed 			db 	0 ; 0 for no, 1 for yes

;save facing and direction
kirbyfacing 	db 0 ;0 for left, 1 for right
kirby_moving 	db 0 ;0 for no, 1 for yes
sm_facing 		db 0 ;0 for left, 1 for right

;save kirby's position starts from bottom right
positionsave 	dw 	0A972h
flylevel 		dw 	0

;vars for swordman's commands
smcommand 	db	0 ;the sword man next command left
smposition 	dw 	0A960h ;the sword man position	

;vars for processing the bmp files
filehandle 	dw ?
Header 		db 54 dup (0)
Palette 	db 256*4 dup (0)
ScrLine 	db 320 dup (0)
ErrorMsg 	db 'Error', 13, 10,'$'


;================================
CODESEG
;================================
proc OpenFile
	push 	bp
	mov 	bp,sp
    ; Open file

    mov 	ah, 3Dh
    xor 	al, al
    mov 	dx, [bp+4]
    int 	21h

    jc 		openerror
    mov 	[filehandle], ax
	pop 	bp
    ret 	2

openerror:
    mov 	dx, offset ErrorMsg
    mov 	ah, 9h
    int 	21h
	pop 	bp
    ret 	2
endp 		OpenFile

proc 		ReadHeader

    ; Read BMP file header, 54 bytes

    mov 	ah,3fh
    mov 	bx, [filehandle]
    mov 	cx,54
    mov 	dx,offset Header
    int 	21h
    ret
endp 		ReadHeader
proc 		ReadPalette

    ; Read BMP file color palette, 256 colors * 4 bytes (400h)

    mov 	ah,3fh
    mov 	cx,400h
    mov 	dx,offset Palette
    int 	21h
    ret
endp 		ReadPalette
proc 		CopyPal

    ; Copy the colors palette to the video memory
    ; The number of the first color should be sent to port 3C8h
    ; The palette is sent to port 3C9h

    mov 	si,offset Palette
    mov 	cx,256
    mov 	dx,3C8h
    mov 	al,0

    ; Copy starting color to port 3C8h

    out 	dx,al

    ; Copy palette itself to port 3C9h

    inc 	dx
    PalLoop:

    ; Note: Colors in a BMP file are saved as BGR values rather than RGB.

    mov 	al,[si+2] ; Get red value.
    shr 	al,2 ; Max. is 255, but video palette maximal

    ; value is 63. Therefore dividing by 4.

    out 	dx,al ; Send it.
    mov 	al,[si+1] ; Get green value.
    shr 	al,2
    out 	dx,al ; Send it.
    mov 	al,[si] ; Get blue value.
    shr 	al,2
    out 	dx,al ; Send it.
    add 	si,4 ; Point to next color.

    ; (There is a null chr. after every color.)

    loop 	PalLoop
    ret
endp 		CopyPal

proc 		CopyBitmap

    ; BMP graphics are saved upside-down.
    ; Read the graphic line by line (200 lines in VGA format),
    ; displaying the lines from bottom to top.

    mov 	ax, 0A000h
    mov 	es, ax
    mov 	cx,200
PrintBMPLoop:

    push 	cx

    ; di = cx*320, point to the correct screen line

    mov 	di,cx
    shl 	cx,6
    shl 	di,8
    add 	di,cx

    ; Read one line

    mov 	ah,3fh
    mov 	cx,320
    mov 	dx,offset ScrLine
    int 	21h

    ; Copy one line into video memory

    cld 

    ; Clear direction flag, for movsb

    mov 	cx,320
    mov 	si,offset ScrLine
    rep 	movsb 

    ; Copy line to the screen
    ;rep movsb is same as the following code:
    ;mov es:di, ds:si
    ;inc si
    ;inc di
    ;dec cx
    ;loop until cx=0

    pop 	cx
    loop 	PrintBMPLoop
    ret
endp 		CopyBitmap

proc 		CopyBitmap2

    ; BMP graphics are saved upside-down.
    ; Read the graphic line by line (32 lines in VGA format),
    ; displaying the lines from bottom to top.
	push 	bp
	mov 	bp,sp
	
    mov 	ax,[bp+4] ;0A960h border left bottom | 0A972 border right bottom | 0A000h border left top | 0A012h border right top
    mov 	es, ax
    mov 	cx,32
PrintBMPLoop2:
    push 	cx

    ; di = cx*320, point to the correct screen line

    mov 	di,cx
    shl 	cx,6
    shl 	di,8
    add 	di,cx

    ; Read one line

    mov 	ah,3fh
    mov 	cx,32
    mov 	dx,offset ScrLine
    int 	21h

    ; Copy one line into video memory

    cld 

    ; Clear direction flag, for movsb

    mov 	cx,32
    mov 	si,offset ScrLine
    rep 	movsb 

    ; Copy line to the screen
    ;rep movsb is same as the following code:
    ;mov es:di, ds:si
    ;inc si
    ;inc di
    ;dec cx
    ;loop until cx=0

    pop 	cx
    loop 	PrintBMPLoop2
	
	pop 	bp
    ret		2
	
endp 		CopyBitmap2

; Close file. Bx = file handle
proc 		CloseFile
	push 	bp
	mov		bp,sp
	mov 	bx,[bp+4]
	mov 	ah,3Eh
	int 	21h
	pop 	bp
	ret		2
endp 		CloseFile

proc 		PrintCharecter
	; the proc gets the offset of the kirby picture to print which is saved in dx
	; the proc will print the picture at the position
	
	mov 	[kirbylastpic],dx
	;print the picture
	push 	dx		;dx have the offset of the picture 		
	call 	OpenFile
    call 	ReadHeader
    call 	ReadPalette
    call 	CopyPal
	push 	[positionsave]
    call 	CopyBitmap2
	push 	[filehandle]
	call 	CloseFile 
	
	ret
endp 		PrintCharecter

proc 		PrintCharecter2
	; the proc gets the offset of the enemy picture to print which is saved in dx
	; the proc will print the picture at the position
	
	mov 	[smlastpic],dx
	;print the picture
	push 	dx		;dx have the offset of the picture 		
	call 	OpenFile
    call 	ReadHeader
    call 	ReadPalette
    call 	CopyPal
	push 	[smposition]
    call 	CopyBitmap2
	push 	[filehandle]
	call 	CloseFile 
	
	ret
endp 		PrintCharecter2

proc 		PrintArena
	; the proc will print the arena with a delay
	; Print the arena
	call 	delay		;delays the print of the arena so the animation wont be too fast 
	push 	offset arena
    call 	OpenFile
    call 	ReadHeader
    call 	ReadPalette
    call 	CopyPal
    call 	CopyBitmap
	push 	[filehandle]
	call 	CloseFile
	
	cmp 	[timepassed],1
	jne 	con67
	call 	smfullmove
	jmp 	return16
con67:
	
	mov 	dx,[smlastpic]
	call 	PrintCharecter2

return16:	
	ret
endp 		PrintArena

proc 		PrintArena2
	; the proc will print the arena with a delay
	; Print the arena
	;call 	delay		;delays the print of the arena so the animation wont be too fast 
	
	cmp 	[kirby_moving],1
	jne 	con79
	call 	PrintArena3
	ret
con79:
	push 	offset arena
    call 	OpenFile
    call 	ReadHeader
    call 	ReadPalette
    call 	CopyPal
    call 	CopyBitmap
	push 	[filehandle]
	call 	CloseFile
	
	mov 	dx,[kirbylastpic]
	call 	PrintCharecter
	
	ret
endp 		PrintArena2

proc 		PrintArena3
	; the proc will print the arena with a delay
	; Print the arena
	;call 	delay		;delays the print of the arena so the animation wont be too fast 
	push 	offset arena
    call 	OpenFile
    call 	ReadHeader
    call 	ReadPalette
    call 	CopyPal
    call 	CopyBitmap
	push 	[filehandle]
	call 	CloseFile
	
	ret
endp 		PrintArena3

proc 		moveleft	

;the proc will move kirby left and switch through the pictures until the a key is no longer pressed
	mov 	[kirby_moving],1
printthemovleft:

	;kirby move left
	call 	PrintArena	
	call 	checkbottomleft
	cmp 	dl,1
	je 		con2
	dec 	[positionsave]
con2:
	mov 	dx,offset kml1
	call 	PrintCharecter
	
	call 	chekkeypress2
	cmp 	[continue],1h
	jne 	return1
	
	;kirby move left 2
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je 		con3
	dec 	[positionsave]
con3:
	mov		dx,offset kml2
	call 	PrintCharecter
	
	call 	chekkeypress2
	cmp 	[continue],1h
	jne 	return1


	;kirby move left 3
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je 		con4
	dec 	[positionsave]
con4:
	mov 	dx,offset kml3
	call 	PrintCharecter
	
	call 	chekkeypress2
	cmp 	[continue],1h
	jne 	return1

	;kirby move left 4
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je 		con5
	dec 	[positionsave]
con5:
	mov 	dx,offset kml4
	call 	PrintCharecter
	
	call 	chekkeypress2
	cmp 	[continue],1h
	jne 	return1
	
	;kirby move left 5
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je 		con27
	dec 	[positionsave]
con27:
	mov 	dx,offset kml5
	call 	PrintCharecter
	
	call 	chekkeypress2
	cmp 	[continue],1h
	jne 	return1
	
	;kirby move left 6
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je 		con28
	dec 	[positionsave]
con28:
	mov 	dx,offset kml6
	call 	PrintCharecter
	
	call 	chekkeypress2
	cmp 	[continue],1h
	jne 	return1
	
	
	;kirby move left 7
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je 		con29
	dec 	[positionsave]
con29:
	mov 	dx,offset kml7
	call 	PrintCharecter
	
	call 	chekkeypress2
	cmp 	[continue],1h
	jne 	return1
	
	;kirby move left 8
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je 		con30
	dec 	[positionsave]
con30:
	mov 	dx,offset kml8
	call	PrintCharecter
	
	jmp 	printthemovleft

return1:
	mov 	[kirby_moving],0
	ret
endp 		moveleft

proc 		checkbottomleft
;checks if kirby's position is at the left line, if it does, then dl will be 1
;need to change name to checkleftside

	cmp 	[positionsave],0A960h
	je 		put_dl_1
	cmp 	[positionsave],0A870h
	je 		put_dl_1
	cmp 	[positionsave],0A780h
	je 		put_dl_1
	cmp 	[positionsave],0A690h
	je 		put_dl_1
	cmp 	[positionsave],0A5A0h
	je 		put_dl_1
	cmp 	[positionsave],0A4B0h
	je 		put_dl_1
	cmp 	[positionsave],0A3C0h
	je 		put_dl_1
	cmp 	[positionsave],0A2D0h
	je 		put_dl_1
	cmp 	[positionsave],0A1E0h
	je 		put_dl_1
	cmp 	[positionsave],0A0F0h
	je 		put_dl_1
	cmp 	[positionsave],0A000h
	je 		put_dl_1
	xor 	dl,dl
	jmp 	endc

put_dl_1:
	mov 	dl,1

endc:	
	ret
endp 		checkbottomleft

proc 		checkbottomleft2
;checks if sword man's position is at the left line, if it does, then dl will be 1
;need to change name to checkleftside

	cmp 	[smposition],0A960h
	je 		put_dl_1_4
	cmp 	[smposition],0A870h
	je 		put_dl_1_4

	xor 	dl,dl
	jmp 	endc4

put_dl_1_4:
	mov 	dl,1

endc4:	
	ret
endp 		checkbottomleft2

proc 		checkbottomleft3
; checks if sword man's position is at the second place from the right line
; checks if the whoosh can be printed
	
	cmp 	[smposition],0A961h
	je 		put_dl_1_5
	cmp 	[smposition],0A960h
	je 		put_dl_1_5

	xor 	dl,dl
	jmp 	endc5
	
put_dl_1_5:
	mov 	dl,1

endc5:	
	ret
endp 		checkbottomleft3

proc 		moveright

;the proc will move kirby right and switch through the pictures until the d key is no longer pressed
	mov 	[kirby_moving],1
	
printthemovright:
	
	;kirby move right
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je 		con6
	inc 	[positionsave]
con6:
	mov 	dx, offset kmr1
	call 	PrintCharecter 
	
	
	call 	chekkeypress3
	cmp 	[continue],1h
	jne 	return2

	
	;kirby move right2
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je 		con7
	inc 	[positionsave]
con7:
	mov 	dx, offset kmr2
	call 	PrintCharecter
	
	
	call 	chekkeypress3
	cmp 	[continue],1h
	jne 	return2
	
	;kirby move right3
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je 		con9
	inc 	[positionsave]
con9:
	mov 	dx, offset kmr3
	call 	PrintCharecter

	
	call 	chekkeypress3
	cmp 	[continue],1h
	jne 	return2
	
	;kirby move right4
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je 		con10
	inc 	[positionsave]
con10:
	mov 	dx, offset kmr4
	call 	PrintCharecter
	

	call 	chekkeypress3
	cmp 	[continue],1h
	jne 	return2
	
	;kirby move right5
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je 		con33
	inc 	[positionsave]
con33:
	mov 	dx, offset kmr5
	call 	PrintCharecter
	
	call 	chekkeypress3
	cmp 	[continue],1h
	jne 	return2
	
	;kirby move right6
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je 		con34
	inc 	[positionsave]
con34:
	mov 	dx, offset kmr6
	call 	PrintCharecter
	
	call 	chekkeypress3
	cmp 	[continue],1h
	jne 	return2
	
	;kirby move right7
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je 		con35
	inc 	[positionsave]
con35:
	mov 	dx, offset kmr7
	call 	PrintCharecter
	
	call 	chekkeypress3
	cmp 	[continue],1h
	jne 	return2
	
	;kirby move right8
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je 		con36
	inc 	[positionsave]
con36:
	mov 	dx, offset kmr8
	call 	PrintCharecter
	
	jmp 	printthemovright

return2:
	mov 	[kirby_moving],0
	ret
endp 		moveright

proc 		checkbottomright 
;checks if kirby's position is at the right line if it does, dl will be 1
;need to change name
	
	cmp 	[positionsave],0A972h
	je 		put_dl_1_2
	cmp  	[positionsave],0A882h
	je		put_dl_1_2
	cmp  	[positionsave],0A792h
	je		put_dl_1_2
	cmp  	[positionsave],0A6A2h
	je		put_dl_1_2
	cmp  	[positionsave],0A5B2h
	je		put_dl_1_2
	cmp  	[positionsave],0A4C2h
	je		put_dl_1_2
	cmp  	[positionsave],0A3D2h
	je		put_dl_1_2
	cmp  	[positionsave],0A2E2h
	je		put_dl_1_2
	cmp  	[positionsave],0A1F2h
	je		put_dl_1_2
	cmp  	[positionsave],0A102h
	je		put_dl_1_2
	cmp  	[positionsave],0A012h
	je		put_dl_1_2
	xor 	dl,dl
	jmp 	endc2
	
put_dl_1_2:
	mov 	dl,1

endc2:	
	ret
endp 		checkbottomright

proc 		checkbottomright2 
;checks if sword man's position is at the right line if it does, dl will be 1
;need to change name
	
	cmp 	[smposition],0A972h
	je 		put_dl_1_3
	cmp  	[smposition],0A882h
	je		put_dl_1_3

	xor 	dl,dl
	jmp 	endc3
	
put_dl_1_3:
	mov 	dl,1

endc3:	
	ret
endp 		checkbottomright2

proc 		checkbottomright3
; checks if sword man's position is at the second place from the right line
; checks if the whoosh can be printed
	
	cmp 	[smposition],0A971h
	je 		put_dl_1_6
	cmp 	[smposition],0A972h
	je 		put_dl_1_6

	xor 	dl,dl
	jmp 	endc4
	
put_dl_1_6:
	mov 	dl,1

endc6:	
	ret
endp 		checkbottomright3

proc 		kirbyjump 
;dec by F0 when going up
;the proc will make kirby jump once 
	mov 	[kirby_moving],1
printthejump:
	;print kirby jump1
	inc 	[flylevel]
	call 	PrintArena
	sub 	[positionsave],0F0h
	mov 	dx,offset kj1
	call 	PrintCharecter
	
	call 	checkkeypress
	cmp 	[continue],0
	je 		return17
	
	;print kirby jump2
	inc 	[flylevel]
	call 	PrintArena
	sub 	[positionsave],0F0h
	mov 	dx,offset kj2
	call 	PrintCharecter
	
	call 	checkkeypress
	cmp 	[continue],0
	je 		return17
	
	;print kirby jump3
	inc 	[flylevel]
	call 	PrintArena
	sub 	[positionsave],0F0h
	mov 	dx,offset kj3
	call 	PrintCharecter
	
	call 	checkkeypress
	cmp 	[continue],0
	je 		return17
	
	;print kirby jump4
	dec 	[flylevel]
	call 	PrintArena
	add 	[positionsave],0F0h
	mov 	dx,offset kj4
	call 	PrintCharecter
	
	call 	checkkeypress
	cmp 	[continue],0
	je 		return17
	
	;print kirby jump5
	dec 	[flylevel]
	call 	PrintArena
	add 	[positionsave],0F0h
	mov 	dx,offset kj5
	call 	PrintCharecter
	
	call 	checkkeypress
	cmp 	[continue],0
	je 		return17
	
	;print kirby jump6
	dec 	[flylevel]
	call 	PrintArena
	add 	[positionsave],0F0h
	mov 	dx,offset kj6
	call 	PrintCharecter

return17:
	mov 	[kirby_moving],0
	ret
endp 		kirbyjump

proc 		kirbyjumpright 
;
;
	mov 	[kirby_moving],1
printthejumpright:
	;print kirby jump1
	inc 	[flylevel]
	call 	PrintArena
	sub 	[positionsave],0F0h
	mov 	dx,offset kjr1
	call 	PrintCharecter
	
	call 	checkkeypress
	cmp 	[continue],0
	je 		return11
	
	;print kirby jump2
	inc 	[flylevel]
	call 	PrintArena
	sub 	[positionsave],0F0h
	mov 	dx,offset kjr2
	call 	PrintCharecter
	
	call 	checkkeypress
	cmp 	[continue],0
	je 		return11
	
	;print kirby jump3
	inc 	[flylevel]
	call 	PrintArena
	sub 	[positionsave],0F0h
	mov 	dx,offset kjr3
	call 	PrintCharecter
	
	call 	checkkeypress
	cmp 	[continue],0
	je 		return11
	
	;print kirby jump4
	dec 	[flylevel]
	call 	PrintArena
	add 	[positionsave],0F0h
	mov 	dx,offset kjr4
	call 	PrintCharecter
	
	call 	checkkeypress
	cmp 	[continue],0
	je 		return11
	
	;print kirby jump5
	dec 	[flylevel]
	call 	PrintArena
	add 	[positionsave],0F0h
	mov 	dx,offset kjr5
	call 	PrintCharecter
	
	call 	checkkeypress
	cmp 	[continue],0
	je 		return11
	
	;print kirby jump6
	dec 	[flylevel]
	call 	PrintArena
	add 	[positionsave],0F0h
	mov 	dx,offset kjr6
	call 	PrintCharecter

return11:	
	mov 	[kirby_moving],0
	ret
endp 		kirbyjumpright

proc 		checkkeypress ;jump condition
;the proc will check which key is pressed during the jump
	mov 	[continue],1
	in 		al,60h
	cmp 	al,1eh ; a key
	je		a_press
	cmp 	al,20h ; d key
	je		d_press
	cmp 	al,11h ; w key
	je 		w_press
	
	jmp 	return6

a_press:
	call 	checkbottomleft
	cmp 	dl,1
	je 		return6
	dec 	[positionsave]
	jmp 	return6
d_press:
	call 	checkbottomright
	cmp 	dl,1
	je 		return6
	inc 	[positionsave]
	jmp 	return6

w_press:
	call 	flymode		
	mov		[continue],0
	
return6:
	ret
endp 		checkkeypress

proc 		chekkeypress2 ;move condition left
;the proc will check which key is pressed during the move left
	in 		al,60h
	cmp 	al,20h ; d key
	je		d_press2
	cmp 	al,39h ; space key
	je 		space_press2
	cmp 	al,1eh ; a still pressed
	je 		put_continue_1_2
	cmp 	al,1fh ; s key
	je 		s_press
	mov 	[continue],0
	jmp 	return7
d_press2:
	call 	moveright
	mov 	[continue],0
	jmp 	return7
space_press2:
	call 	kirbyjump
	mov 	[continue],0
	jmp 	return7

s_press:
	call 	kirbydownleft
	mov 	[continue],0
	jmp 	return7	

put_continue_1_2:
	mov 	[continue],1
return7:
	ret
endp 		chekkeypress2

proc 		chekkeypress3 ;move condition right
;the proc will check which key is pressed during the move right
	in 		al,60h
	cmp 	al,1eh ; a key
	je		a_press2
	cmp 	al,39h ; space key
	je 		space_press3
	cmp 	al,20h ; d still pressed
	je 	 	put_continue_1
	cmp 	al,1fh ; s key
	je  	s_press2
	mov 	[continue],0
	jmp 	return8
a_press2:
	call 	moveleft
	mov 	[continue],0
	jmp 	return8
space_press3:
	call 	kirbyjumpright
	mov 	[continue],0
	jmp 	return8
	
s_press2:
	call 	kirbydownright
	mov 	[continue],0
	jmp 	return8
	
put_continue_1:
	mov 	[continue],1
return8:
	ret
endp 		chekkeypress3

proc 		flymode
; the proc will make kirby fly as long as he is above ground
	mov 	[kirby_moving],0
Wait_for_key:
	call 	smfullmove
	in 		al,60h
	cmp 	al,11h ;w pressed
	je 		w_condition
	cmp 	al,1eh ;a pressed
	je		a_condition
	cmp 	al,20h ;d pressed
	je		d_condition
	cmp 	[flylevel],0
	je 		return9
	;if no key is pressed, kirby will fall down
	dec 	[flylevel]
	add 	[positionsave],0F0h
	call 	PrintArena
	mov 	dx,offset kfl1 ;need to do acording to facing
	call 	PrintCharecter
	
	jmp 	Wait_for_key
	
w_condition:
	cmp 	[flylevel],10
	je 		con47
	inc 	[flylevel]
	sub 	[positionsave],0F0h
con47:
	call 	PrintArena
	mov 	dx, offset kfl1
	call 	PrintCharecter
	call 	smfullmove
	
	in 		al,60h
	cmp 	al,11h ;w pressed
	je 		con45
	cmp 	al,1eh ;a pressed
	je		con54
	cmp 	al,20h ;d pressed
	je		con56
	cmp 	[flylevel],0
	je 		return9
	
	jmp 	Wait_for_key
	
con45:	
	cmp 	[flylevel],10
	je 		con48
	inc 	[flylevel]
	sub 	[positionsave],0F0h
con48:
	call 	PrintArena
	mov 	dx, offset kfl2
	call 	PrintCharecter
	call 	smfullmove
	
	in 		al,60h
	cmp 	al,11h ;w pressed
	je 		con46
	cmp 	al,1eh ;a pressed
	je		con52
	cmp 	al,20h ;d pressed
	je		con58
	cmp 	[flylevel],0
	je 		return9
	
	jmp 	Wait_for_key
	
con46:	
	cmp 	[flylevel],10
	je 		con49
	inc 	[flylevel]
	sub 	[positionsave],0F0h
con49:
	call 	PrintArena
	mov 	dx, offset kfl3
	call 	PrintCharecter
	call 	smfullmove
	
	in 		al,60h
	cmp 	al,11h ;w pressed
	je 		w_condition
	cmp 	al,1eh ;a pressed
	je		a_condition
	cmp 	al,20h ;d pressed
	je		d_condition
	cmp 	[flylevel],0
	je 		return9
	
	jmp 	Wait_for_key
	
a_condition:
	
	;print kirby fly left
	call 	checkbottomleft
	cmp 	dl,1
	je 		con50
	dec 	[positionsave]
con50:
	call 	PrintArena
	mov 	dx, offset kfl1
	call 	PrintCharecter
	call 	smfullmove
	
	in 		al,60h
	cmp 	al,11h ;w pressed
	je 		con45
	cmp 	al,20h ;d pressed
	je		con56
	cmp 	al,1eh ;a pressed
	jne		Wait_for_key
	cmp 	[flylevel],0
	je 		return9

con54:	
	;print kirby fly left2
	call 	checkbottomleft
	cmp 	dl,1
	je 		con51
	dec 	[positionsave]
con51:
	dec 	[flylevel]
	add 	[positionsave],0F0h
	call 	PrintArena
	mov 	dx, offset kfl2
	call 	PrintCharecter
	call 	smfullmove
	
	in 		al,60h
	cmp 	al,11h ;w pressed
	je 		con46
	cmp 	al,20h ;d pressed
	je		con58
	cmp 	al,1eh ;a pressed
	jne		Wait_for_key
	cmp 	[flylevel],0
	je 		return9
	
con52:
	;print kirby fly left3
	call 	checkbottomleft
	cmp 	dl,1
	je 		con53
	dec 	[positionsave]
con53:
	call 	PrintArena
	mov 	dx, offset kfl3
	call 	PrintCharecter
	call 	smfullmove
	
	in 		al,60h
	cmp 	al,11h ;w pressed
	je 		w_condition
	cmp 	al,20h ;d pressed
	je		d_condition
	cmp 	al,1eh ;a pressed
	jne		Wait_for_key
	cmp 	[flylevel],0
	je 		return9
	
	jmp 	a_condition
	
d_condition:
	;print kirby fly right
	call 	checkbottomright
	cmp 	dl,1
	je 		con55
	inc 	[positionsave]
con55:	
	call 	PrintArena
	mov 	dx, offset kfr1
	call 	PrintCharecter
	call 	smfullmove
	
	in 		al,60h
	cmp 	al,11h ;w pressed
	je 		w_condition
	cmp 	al,1eh ;a pressed
	je		a_condition
	cmp 	al,20h ;d pressed
	jne		Wait_for_key
	cmp 	[flylevel],0
	je 		return9
	
con56:
	;print kirby fly right2
	call 	checkbottomright
	cmp 	dl,1
	je 		con57
	inc 	[positionsave]
con57:
	dec 	[flylevel]
	add 	[positionsave],0F0h
	call 	PrintArena
	mov 	dx, offset kfr2
	call 	PrintCharecter
	call 	smfullmove
	
	in 		al,60h
	cmp 	al,11h ;w pressed
	je 		w_condition
	cmp 	al,1eh ;a pressed
	je		a_condition
	cmp 	al,20h ;d pressed
	jne		Wait_for_key
	cmp 	[flylevel],0
	je 		return9
	
con58:
	;print kirby fly right3
	call 	checkbottomright
	cmp 	dl,1
	je 		con59
	inc 	[positionsave]
con59:
	call 	PrintArena
	mov 	dx, offset kfr3
	call 	PrintCharecter
	call 	smfullmove
	
	in 		al,60h
	cmp 	al,11h ;w pressed
	je 		w_condition
	cmp 	al,1eh ;a pressed
	je		a_condition
	cmp 	al,20h ;d pressed
	jne		Wait_for_key
	cmp 	[flylevel],0
	je 		return9
	
	jmp 	d_condition
return9:
	mov 	[kirby_moving],1
	ret
endp 		flymode


proc 		kirbydownright 
;the proc will make kirby go down until the s key is no longer pressed
	
	
	;print kirby down right
	call 	PrintArena
	mov 	dx,offset kdr
	call 	PrintCharecter
	
WaitForExit:
	call	delay
	call 	SMCommandTime
	cmp 	[timepassed],1
	jne 	con93
	call 	smfullmove
con93:
	in 		al,60h
	cmp 	al,1Fh
	je 		WaitForExit
	cmp 	al,1Eh
	je 		KirbySlideLeft
	cmp 	al,20h
	je 		KirbySlideRight
	
	jmp 	return4
	
KirbySlideRight:
	mov 	[kirby_moving],1	
	;print kirby slide right
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je  	con21
	inc 	[positionsave]
con21:
	mov 	dx,offset kslr
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,20h
	jne 	return4
	
	;print kirby slide right
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je  	con22
	inc 	[positionsave]
con22:
	mov 	dx,offset kslr
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,20h
	jne 	return4
	
	;print kirby slide right
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je  	con24
	inc 	[positionsave]
con24:
	mov 	dx,offset kslr
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,20h
	jne 	return4
	
	;print kirby slide right
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je  	con25
	inc 	[positionsave]
con25:
	mov 	dx,offset kslr
	call 	PrintCharecter
	call 	sm_damage
	
	jmp 	return4

KirbySlideLeft:
	mov 	[kirby_moving],1
	;print kirby slide left
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je  	con11
	dec 	[positionsave]
con11:
	mov 	dx,offset ksll
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,1eh
	jne 	return4
	
	;print kirby slide left
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je  	con12
	dec 	[positionsave]
con12:
	mov 	dx,offset ksll
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,1eh
	jne 	return4

	
	;print kirby slide left
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je  	con13
	dec 	[positionsave]
con13:
	mov 	dx,offset ksll
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,1eh
	jne 	return4
	
	;print kirby slide left
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je  	con14
	dec 	[positionsave]
con14:
	mov 	dx,offset ksll
	call 	PrintCharecter
	call 	sm_damage
	
return4:
	mov 	[kirby_moving],0
	ret
endp 		kirbydownright

proc 		kirbydownleft	;the proc will make kirby go down until the s key is no longer pressed
	
	;print kirby down left
	call 	PrintArena
	mov 	dx,offset kj7
	call 	PrintCharecter
	
	WaitForExit2:
	call	delay
	call 	SMCommandTime
	cmp 	[timepassed],1
	jne 	con92
	call 	smfullmove
con92:
	in 		al,60h
	cmp 	al,1Fh
	je 		WaitForExit2
	cmp 	al,1eh
	je 		KirbySlideLeft2
	cmp 	al,20h
	je 		KirbySlideRight2
	
	jmp 	return5
	
KirbySlideRight2:
	mov 	[kirby_moving],1
	;print kirby slide right
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je  	con42
	inc 	[positionsave]
con42:
	mov 	dx,offset kslr
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,20h
	jne 	return5
	
	;print kirby slide right
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je  	con44
	inc 	[positionsave]
con44:
	mov 	dx,offset kslr
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,20h
	jne 	return5
	
	;print kirby slide right
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je  	con40
	inc 	[positionsave]
con40:
	mov 	dx,offset kslr
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,20h
	jne 	return5
	
	;print kirby slide right
	call 	PrintArena
	call 	checkbottomright
	cmp 	dl,1
	je  	con41
	inc 	[positionsave]
con41:
	mov 	dx,offset kslr
	call 	PrintCharecter
	call 	sm_damage
	
	jmp 	return5
	
KirbySlideLeft2:
	mov 	[kirby_moving],1
	;print kirby slide left
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je  	con16
	dec 	[positionsave]
con16:
	mov 	dx,offset ksll
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,1eh
	jne 	return5
	
	;print kirby slide left
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je  	con17
	dec 	[positionsave]
con17:
	mov 	dx,offset ksll
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,1eh
	jne 	return5
	
	;print kirby slide left
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je  	con19
	dec 	[positionsave]
con19:
	mov 	dx,offset ksll
	call 	PrintCharecter
	call 	sm_damage
	
	in 		al,60h
	cmp 	al,1eh
	jne 	return5
	
	;print kirby slide left
	call 	PrintArena
	call 	checkbottomleft
	cmp 	dl,1
	je  	con20
	dec 	[positionsave]
con20:
	mov 	dx,offset ksll
	call 	PrintCharecter
	call 	sm_damage
	
return5:
	mov 	[kirby_moving],0
	ret
endp 		kirbydownleft

proc 		swordmoveleft
	; the proc will print the sword man picture acording to the next command
	; for each command: check if the swordman is next to a wall at the moving direction, if not, do the next command, if he is, stay in place and do the next command.
	; the command will print the arena with kirby at his last position and then print the sword man as well as changing his position.
	mov 	[sm_facing],0
	call 	SMCommandTime
	cmp 	[timepassed],1
	jne 	con68
	inc 	[smcommand]
	mov 	[timepassed],0
con68:	
	cmp 	[smcommand],0
	je		command0
	cmp 	[smcommand],1
	je		command1
	cmp 	[smcommand],2
	je		command2
	cmp 	[smcommand],3
	je		command3
	cmp 	[smcommand],4
	je		command4
	cmp 	[smcommand],5
	je		command5
	cmp 	[smcommand],6
	je		command6
	
command0: ; prints the sword man's first picture to the left 
	call 	PrintArena2
	mov 	dx,offset sml1
	call 	PrintCharecter2
	jmp 	return12
	
command1: ; prints the sword man's second picture to the left 
	call 	checkbottomleft2
	cmp 	dl,1
	je 		con60
	dec 	[smposition]
con60:
	call 	PrintArena2
	mov 	dx,offset sml2
	call 	PrintCharecter2
	jmp 	return12
	
command2: ; prints the sword man's third picture to the left 
	call 	checkbottomleft2
	cmp 	dl,1
	je 		con74
	dec 	[smposition]
con74:
	call 	PrintArena2
	mov 	dx,offset sml3
	call 	PrintCharecter2
	jmp 	return12
	
command3: ; prints the sword man's forth picture to the left 
	call 	checkbottomleft2
	cmp 	dl,1
	je 		con75
	dec 	[smposition]
con75:
	call 	PrintArena2
	mov 	dx,offset sml4
	call 	PrintCharecter2
	jmp 	return12
	
command4: ; prints the sword man's fifth picture to the left 
	call 	checkbottomleft2
	cmp 	dl,1
	je 		con76
	dec 	[smposition]
con76:
	call 	PrintArena2
	mov 	dx,offset sml5
	call 	PrintCharecter2
	
	call 	checkbottomleft3 ; in this command the sword man will attack , print the whoosh
	cmp 	dl,1
	je 		con80
	sub		[smposition],2
	mov 	dx, offset whl
	call 	PrintCharecter2
	call 	check_kirby_damage
	add 	[smposition],2
con80:
	jmp 	return12

	
	
command5: ; prints the sword man's sixth picture to the left 
	call 	checkbottomright2
	cmp 	dl,1
	je 		con77
	inc 	[smposition]
con77:
	call 	PrintArena2
	mov 	dx,offset sml6
	call 	PrintCharecter2
	jmp 	return12
	
command6: ; prints the sword man's seventh picture to the left 
	call 	checkbottomright2
	cmp 	dl,1
	je 		con78
	inc 	[smposition]
con78:
	call 	PrintArena2
	mov 	dx,offset sml7
	call 	PrintCharecter2
	mov 	[smcommand],0
	jmp 	return12
	
	
return12:
	ret
endp 		swordmoveleft

proc 		swordmoveright
; see swordmoveleft
	mov 	[sm_facing],1
	call 	SMCommandTime
	cmp 	[timepassed],1
	jne 	con61
	inc 	[smcommand]
	mov 	[timepassed],0
con61:
	cmp 	[smcommand],0
	je		command0_2
	cmp 	[smcommand],1
	je		command1_2
	cmp 	[smcommand],2
	je		command2_2
	cmp 	[smcommand],3
	je		command3_2
	cmp 	[smcommand],4
	je		command4_2
	cmp 	[smcommand],5
	je		command5_2
	cmp 	[smcommand],6
	je		command6_2
	
command0_2: ;timepassed ; prints the sword man's first picture to the right 
	;cmp 	[timepassed],1
	;jne 	con62
	;mov 	[timepassed],0
	;call 	checkbottomright2
	;cmp 	dl,1
	;je 		con62
	;inc 	[smposition]
;con62:
	call 	PrintArena2
	mov 	dx,offset smr1
	call 	PrintCharecter2
	jmp 	return14
	
command1_2: ; prints the sword man's second picture to the right 
	call 	checkbottomright2
	cmp 	dl,1
	je 		con62
	inc 	[smposition]
con62:
	call 	PrintArena2
	mov 	dx,offset smr2
	call 	PrintCharecter2
	jmp 	return14
	
command2_2: ; prints the sword man's third picture to the right 
	call 	checkbottomright2
	cmp 	dl,1
	je 		con69
	inc 	[smposition]
con69:
	call 	PrintArena2
	mov 	dx,offset smr3
	call 	PrintCharecter2
	jmp 	return14
	
command3_2: ; prints the sword man's forth picture to the right 
	call 	checkbottomright2
	cmp 	dl,1
	je 		con70
	inc 	[smposition]
con70:
	call 	PrintArena2
	mov 	dx,offset smr4
	call 	PrintCharecter2
	jmp 	return14
	
command4_2: ; prints the sword man's fifth picture to the right 
	call 	checkbottomright2
	cmp 	dl,1
	je 		con71
	inc 	[smposition]
con71:
	call 	PrintArena2
	mov 	dx,offset smr5
	call 	PrintCharecter2
	
	call 	checkbottomright3 ; in this command the sword man will attack , print the whoosh right
	cmp 	dl,1
	je 		con81
	add		[smposition],2
	mov 	dx, offset whr
	call 	PrintCharecter2
	call 	check_kirby_damage
	sub 	[smposition],2
con81:
	jmp 	return14
	
command5_2: ; prints the sword man's sixth picture to the right 
	call 	checkbottomleft2
	cmp 	dl,1
	je 		con72
	dec 	[smposition]
con72:
	call 	PrintArena2
	mov 	dx,offset smr6
	call 	PrintCharecter2
	jmp 	return14
	
command6_2: ; prints the sword man's seventh picture to the right 
	call 	checkbottomleft2
	cmp 	dl,1
	je 		con73
	dec 	[smposition]
con73:
	call 	PrintArena2
	mov 	dx,offset smr7
	call 	PrintCharecter2
	mov 	[smcommand],0
	jmp 	return14
	
return14:
	ret
endp 		swordmoveright

proc 		smfullmove
	;call 	delay3
; the proc will first check if the sword man need to go right or left to get to kirby
; if right, it will call to the proc that moves him right and so to the left
	mov 	ax,[positionsave]
	mov 	bx,[smposition]
	cmp 	[flylevel],0 ;if kirby's fly level is bigger than 0, to compare the positions we must increase it by 0F0h*the fly level
	je 		con64
	mov 	cx,[flylevel]
add_ax_F0:
	add 	ax,0F0h
	loop 	add_ax_F0
con64:
	cmp 	ax,bx ;checks if kirb's position is bigger, if it is then move to the right
	;je 		return15
	jb 		command_left

command_right:
	call 	swordmoveright
	jmp 	return15

command_left:
	call 	swordmoveleft
return15:	
	ret
endp 		smfullmove

proc 		kirby_damage
	dec 	[kirby_life]
	cmp 	[kirby_life],0
	ja 		con86
	mov 	[kirby_loss],1
con86:
	cmp 	[kirbyfacing],0
	je 		kirby_damaged_left
	
kirby_damaged_right:	
	call 	checkbottomleft
	cmp 	dl,1
	je 		con82
	dec 	[positionsave]
con82:
	sub 	[positionsave],0F0h
	;print kirby damaged right 1
	call 	PrintArena
	mov 	dx, offset kdar1
	call 	PrintCharecter
	
	call 	checkbottomleft
	cmp 	dl,1
	je 		con83
	dec 	[positionsave]
con83:
	;print kirby damaged right 2
	call 	PrintArena
	mov 	dx, offset kdar2
	call 	PrintCharecter
	
	add 	[positionsave],0F0h
	ret
	
kirby_damaged_left:
	call 	checkbottomright
	cmp 	dl,1
	je 		con84
	inc 	[positionsave]
con84:
	sub 	[positionsave],0F0h
	;print kirby damaged left 1
	call 	PrintArena
	mov 	dx, offset kdal1
	call 	PrintCharecter
	
	call 	checkbottomright
	cmp 	dl,1
	je 		con85
	inc 	[positionsave]
con85:
	;print kirby damaged left 2
	call 	PrintArena
	mov 	dx, offset kdal2
	call 	PrintCharecter
	
	add 	[positionsave],0F0h
	
	ret
endp 		kirby_damage

proc 		sm_damage
	mov 	ax,[positionsave]
	mov 	bx,[smposition]
	cmp 	ax,bx
	je 		sm_damaged
	ret
	

con91:
sm_damaged:
	dec 	[sm_life]
	cmp 	[sm_life],0
	ja 		con91
	mov 	[sm_loss],1
	cmp 	[sm_facing],0
	je 		damage_left
	
damage_right:	
	call 	checkbottomleft2
	cmp 	dl,1
	je 		con89
	dec 	[smposition]
con89:
	sub 	[smposition],0F0h
	;print sword man damaged left 1
	call 	PrintArena2
	mov 	dx, offset sdr
	call 	PrintCharecter2
	
	call 	checkbottomleft2
	cmp 	dl,1
	je 		con90
	dec 	[smposition]
con90:
	;print sword man damaged left 2
	call 	PrintArena2
	mov 	dx, offset sdr
	call 	PrintCharecter2
	
	add 	[smposition],0F0h
	
	ret
	
damage_left:	
	call 	checkbottomright2
	cmp 	dl,1
	je 		con87
	inc 	[smposition]
con87:
	sub 	[smposition],0F0h
	;print sword man damaged left 1
	call 	PrintArena2
	mov 	dx, offset sdl
	call 	PrintCharecter2
	
	call 	checkbottomright2
	cmp 	dl,1
	je 		con88
	inc 	[smposition]
con88:
	;print sword man damaged left 2
	call 	PrintArena2
	mov 	dx, offset sdl
	call 	PrintCharecter2
	
	add 	[smposition],0F0h
	
	ret
endp 		sm_damage

proc 		check_kirby_damage
;checks if kirby's position is equal to the whoosh or the sword man position

	mov 	ax,[positionsave]
	mov 	bx,[smposition]
	cmp 	ax,bx
	je		kirby_damaged
	ja		check2
	inc 	ax
	cmp 	ax,bx 
	je 		kirby_damaged
	inc 	ax
	cmp 	ax,bx
	je 		kirby_damaged
	
	jmp 	return18
kirby_damaged:
	call 	kirby_damage
	jmp 	return18
	
check2:
	dec 	ax
	cmp 	ax,bx
	je 		kirby_damaged
	dec 	ax
	cmp 	ax,bx
	je 		kirby_damaged

return18:
	ret
endp 		check_kirby_damage

proc 		SMCommandTime
; the proc checks if the time passed is 20 hundredths if it did, do the next command
; at the start of the program, the vars [smtimesecond] and [smtimehundredth] need to 
; have the original time
	
	cmp 	[smtimehundredth],80 ; if the hundredths are bigger than 80 there is an other condition
	jae 	timecheck2_2
	add 	[smtimehundredth],20

timecheck_2:
	mov 	ah,2ch
	int		21h
	cmp 	[smtimehundredth],dl
	ja 		return13
	
timecheck2_2:
	sub 	[smtimehundredth],80
	inc 	[smtimesecond]
	mov 	ah,2ch
	int		21h
	cmp 	[smtimesecond],dh
	ja 		return13
	cmp 	[smtimehundredth],dl
	ja 		return13
	
	mov 	[timepassed],1 
	;cmp 	[smcommand],7
	;je 		con63
	;inc 	[smcommand]
;con63:
	call 	updatetime
	
return13:
	ret
endp 		SMCommandTime

proc 		updatetime
	mov 	ah,2ch
	int 	21h
	
	mov 	[smtimehundredth],dl
	mov 	[smtimesecond],dh
	
	ret
endp 		updatetime

proc 	delay 
; meant to delay the speed of the switching pictures by 10 hundredths

	mov 	ah,2ch
	int 	21h
	
	mov 	[SaveTimeHundredth ],dl ;saves original time
	mov 	[SaveTimeSecond],dh
	cmp 	[SaveTimeHundredth],90
	jae 	timecheck2
	add 	[SaveTimeHundredth],10
	
	timecheck:
	call 	SMCommandTime
	int 	21h
	cmp 	[SaveTimeHundredth],dl
	ja 		timecheck
	
	jmp 	timeexit
	
timecheck2:	
	sub 	[SaveTimeHundredth],90
	
t2:
	call 	SMCommandTime
	;cmp 	[timepassed],1
	;jne 	con65
	;call 	smfullmove
;con65:	
	int 	21h
	cmp 	[SaveTimeSecond],dh
	je	 	t2
	cmp 	[SaveTimeHundredth],dl
	jae		t2

timeexit:
	ret
endp	 	delay

proc 		delay2 
; delays the time before the ending screen is closed
	push 	bp
	push 	si
	push 	cx
	mov 	cx,180d
s:
	mov 	bp,0FFFFh
	mov 	si,0FFFFh

k:

	dec 	bp
	cmp 	bp,0
	jne 	k

f:

	dec 	si
	cmp 	si,0
	jne 	f	
	loop 	s
	
	pop 	cx
	pop 	si
	pop 	bp
	
	ret
endp 		delay2

proc 		print
	; the proc gets the offset of the picture
	; the proc will print the arena and then kirby
	push 	bp
	mov 	bp,sp
	; print the arena
	call 	PrintArena
	mov 	dx,[bp+4]
	; print kirby
	call 	PrintCharecter
	
	pop 	bp
	ret 	2
endp 		print

;========================================================================================================================================================
start:
	mov 	ax, @data
	mov 	ds, ax
	
	; reload the vars incase the user want to play again
	mov 	[positionsave],0A972h
	mov 	[smposition],0A960h
	mov 	[kirby_life],5
	mov 	[sm_life],3
	mov 	[sm_loss],0
	mov 	[kirby_loss],0
	
 ; Graphic mode
    mov 	ax, 13h
    int 	10h
	
;=========================================================================================================================================================
	call 	updatetime
	mov 	ax, offset smr1
	mov 	[smlastpic],ax
	
	push 	offset main
	call 	OpenFile
	call 	ReadHeader
	call 	ReadPalette
	call 	CopyPal
	call 	CopyBitmap
	push 	[filehandle]
	call 	CloseFile
WaitForEnter:	
	mov 	ah,1h
	int 	21h
	
	cmp 	al,32d 	;chek if space pressed
	je 		KiRest
	cmp 	al,27d ;check if esc pressed
	je 		exit
	
	jmp 	WaitForEnter

KiRest:	
	mov 	[kirbyfacing],0
	
	;print kirby rest
	push 	offset krest
	call 	print
	
	jmp 	WaitForData
	
KiRestright:	
	mov 	[kirbyfacing],1

	;print kirby rest right
	push 	offset krestr
	call 	print
	
WaitForData : 
	cmp 	[kirby_loss],1
	je 		kirbylost
	cmp 	[sm_loss],1
	je 		kirbywon
	in  	al, 64h   ; Read keyboard status port a
	cmp  	al, 10b   ; Data in buffer ? 
	call 	delay
	call 	SMCommandTime
	cmp 	[timepassed],1
	jne 	con
	call 	smfullmove
con:
	je 		WaitForData   ; Wait until data available 
	in  	al, 60h   ; Get keyboard data 
	cmp  	al, 1eh   ; Is it the a key ? 
	je 		printmovleft
	cmp  	al, 20h   ; Is it the d key ? 
	je 		printmovright
	cmp 	al, 1h ; is it esc key?
	je 		kirbylost
	cmp 	al,39h ;is it space key?
	je 		printjump
	cmp 	al,1Fh ; is it s key?
	je 		printdown
	jne 	WaitForData
	
	jmp 	return
printmovleft:
	call 	moveleft
	jmp 	return
	
printmovright:
	call 	moveright
	jmp 	return3
	
printjump:
	cmp 	[kirbyfacing],1
	je		r2
	call 	kirbyjump
	jmp 	return
r2:
	call 	kirbyjumpright
	jmp 	return3
	
printdown:
	cmp 	[kirbyfacing],1
	je 		r
	call 	kirbydownleft
	jmp 	return          
r:
	call 	kirbydownright
	jmp 	return3

return:
	jmp 	KiRest
return3:
	jmp 	Kirestright
	
kirbylost:
	;print win screen
	push 	offset ls
	call 	OpenFile
	call 	ReadHeader
	call 	ReadPalette
	call 	CopyPal
	call 	CopyBitmap
	push 	[filehandle]
	call 	CloseFile
	
	;call 	delay2
WaitForSpace:
	; get a key
	mov 	ah,1h 
	int 	21h
	
	cmp 	al,32d ; space pressed
	je 		start
	cmp 	al,27d ; esc pressed
	je 		exit
	
	jmp 	WaitForSpace

kirbywon:
	;print lose screen
	push 	offset ws
	call 	OpenFile
	call 	ReadHeader
	call 	ReadPalette
	call 	CopyPal
	call 	CopyBitmap
	push 	[filehandle]
	call 	CloseFile
	
	;call 	delay2
WaitForSpace2:
	; get a key
	mov 	ah,1h 
	int 	21h
	
	cmp 	al,32d ; space pressed
	je 		start
	cmp 	al,27d ; esc pressed
	je 		exit
	
	jmp 	WaitForSpace2
	
	
;======================================================================================================================================================
	
exit:
 ; Back to text mode
    mov 	ah, 0
    mov 	al, 2
    int 	10h
; Exit
	mov 	ax, 4c00h
	int 	21h
END start


