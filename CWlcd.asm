;	LCD routines
		include		p16f628.inc
		include		CWdefs.inc

		global		sendlcd,cmdlcd,wrtlcd,bytelcd,inilcd
		extern		delcd,del50
		extern		w_num1,w_count

		udata
bytelcd res 1 ;      0x0f


		code
;     LCD display initialization routine
;         - 1 raw 5x7
;         - 4 bit operation
;         - no cursor           
inilcd
	movlw    b'00111000'    ; 8 bits initialization
	movwf    PORTB         
	bcf      PORTB,bit_EN       ; reset enable
	call     del50
	movlw    b'00111000'    ; repeat 8 bits initialization
	movwf    PORTB         
	bcf      PORTB,bit_EN       ; reset enable
	call     del50
	movlw    b'00111000'    ; repeat 8 bits initialization
	movwf    PORTB         
	bcf      PORTB,bit_EN       ; reset enable
	call     del50
	movlw    b'00101000'    ; 4 bits initialization
	movwf    PORTB         
	bcf      PORTB,bit_EN       ; reset enable
	call     del50

	movlw    b'00100000'    ; set one 5x7 line
	movwf    bytelcd         
	call     cmdlcd         ; send command
	call     del50

	movlw    b'00000111'    ; set LCD mode 
	movwf    bytelcd	; cursor increment/display shift        
	call     cmdlcd         ; send command
	call     del50

	movlw    b'00001100'    ; display on / cursor off
	movwf    bytelcd         
	call     cmdlcd         ; send command
	call     del50

	movlw    b'00000001'    ; clear LCD / home cursor
	movwf    bytelcd         
	call     cmdlcd         ; send command
	call     del50

	movlw	 rowparm
	iorlw	 0x80		; set cursor at row end		
	movwf    bytelcd         
	call     cmdlcd         ; send command
	call     del50
endlcd
	return

;	LCD display routine 
;
;	input : 	- string to display, starting at w_num1
;			- characters number to display in w_count
;
;	output :	- send to LCD display  
;	
sendlcd
	movlw	 w_num1
	movwf    FSR		; load pointer to w_num1
sendlc1
	movf	 INDF,W	;
	movwf	 bytelcd	; move to bytelcd the character to send 
	call	 wrtlcd
	incf	 FSR,F		; position INDF at next character	
	decfsz	 w_count,F	; re-cycle until counter is zero
	goto	 sendlc1
endsend
	return

;     This routine sends a command to LCD display (4 bits at a time)
cmdlcd
	movf     bytelcd,W
	andlw    b'11110000'    ; clear right nibble
	iorlw    b'00001000'    ; set RS = 0, ENA = 1
	movwf    PORTB         ; move nibble to PORTB
	bcf      PORTB,bit_EN       ; enable goes down
	call     delcd          ; one delay
	
	swapf    bytelcd,0      ; exchange nibbles in bytelcd
	andlw    b'11110000'
	iorlw    b'00001000'  
	movwf    PORTB
	bcf      PORTB,bit_EN
	call     delcd
endcmlc
	return                

;       This routine sends a character to LCD display (4 bits at a time)
wrtlcd
	movf     bytelcd,W
	andlw    b'11110000'    ; clear right nibble
	iorlw    b'00001010'    ; set RS = 1, ENA = 1
	movwf    PORTB         ; move nibble to PORTB
	bcf      PORTB,bit_EN       ; enable goes down
	call     delcd          ; one delay
	
	swapf    bytelcd,W      ; exchange nibbles in bytelcd
	andlw    b'11110000'
	iorlw    b'00001010'  
	movwf    PORTB
	bcf      PORTB,bit_EN
	call     delcd
endwrlc
	return  

	end
