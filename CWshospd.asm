;	Display CW speed
		include		p16f628.inc
		include		CWdefs.inc

		global		displ
		extern		wrtlcd,sendlcd,convert
		extern		bytelcd
		extern		w_num1,w_num2,w_num3,w_num4,w_count
		extern		speed

		code
;	Speed rate display routine  
;
;	input : 	- speed in chars / minute 
;
;	output :	- display on LCD module  
;	
displ
	movlw	 " "		
	movwf	 bytelcd
	movlw	 0x0e		; string length for display
	sublw	 rowparm	; NN - string length
	movwf	 w_count	; set heading filler to spaces
displ0
	call	 wrtlcd
	decfsz	 w_count,F
	goto	 displ0
	movf	 speed,W	; display "nnn"
	movwf	 w_num4
	call	 convert
	movf	 w_num1,W
	andlw	 h'0f'
	btfss	 STATUS,Z	; if first digit zero set " "
	goto	 displ1	 
	movlw	 " "
	movwf	 w_num1
displ1
	movlw	 d'3'
	movwf	 w_count 
	call	 sendlcd

	movlw	 " "		; display " cha"
	movwf	 w_num1
	movlw	 "c"
	movwf	 w_num2
	movlw	 "h"
	movwf	 w_num3
	movlw	 "a"
	movwf	 w_num4
	movlw	 d'4'
	movwf	 w_count 
	call	 sendlcd
	
	movlw	 "r"		; display "r/mi"
	movwf	 w_num1
	movlw	 "/"
	movwf	 w_num2
	movlw	 "m"
	movwf	 w_num3
	movlw	 "i"
	movwf	 w_num4
	movlw	 d'4'
	movwf	 w_count 
	call	 sendlcd

	movlw	 "n"		; display "n  "
	movwf	 w_num1
	movlw	 " "
	movwf	 w_num2
	movlw	 " "
	movwf	 w_num3
	movlw	 d'3'
	movwf	 w_count 
	call	 sendlcd
	return

		end
