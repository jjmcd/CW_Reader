;	Welcome message

		global	panel
		extern	sendlcd
		extern		w_num1,w_num2,w_num3,w_num4,w_count

		code

;	Initial text display routine 
;
panel
	movlw	 " "		; display " CW "
	movwf	 w_num1
	movlw	 "C"
	movwf	 w_num2
	movlw	 "W"
	movwf	 w_num3
	movlw	 " "
	movwf	 w_num4
	movlw	 d'4'
	movwf	 w_count
	call	 sendlcd
	movlw	 "D"		; display "Deco"
	movwf	 w_num1
	movlw	 "e"
	movwf	 w_num2
	movlw	 "c"
	movwf	 w_num3
	movlw	 "o"
	movwf	 w_num4
	movlw	 d'4'
	movwf	 w_count
	call	 sendlcd
	movlw	 "d"		; display "der "
	movwf	 w_num1
	movlw	 "e"
	movwf	 w_num2
	movlw	 "r"
	movwf	 w_num3
	movlw	 " "
	movwf	 w_num4
	movlw	 d'4'
	movwf	 w_count
	call	 sendlcd
	movlw	 " "		; display "  -> "
	movwf	 w_num1
	movlw	 " "
	movwf	 w_num2
	movlw	 0x7e
	movwf	 w_num3
	movlw	 " "
	movwf	 w_num4
	movlw	 d'4'
	movwf	 w_count
	call	 sendlcd
endpanl
	return

		end
