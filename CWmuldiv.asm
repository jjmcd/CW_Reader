;	Multiply and divide routines
		include		p16f628.inc

		global		moltip,dividi
		global		w_num1,w_num2,w_num3,w_num4,w_count

		udata
w_count	res 1 ;	 0x25		; - hex to ascii conversion
w_num1	res 1 ;	 0x26		; - multiply
w_num2	res 1 ;	 0x27		; - divide
w_num3	res 1 ;	 0x28		;
w_num4	res 1 ;	 0x29		;

	code
;	Multiply routine between two 1 byte numbers
;
;	input :
;		multiplicand in w_num2
;		multiplyer in w_num3
;
;	output :
;		product in w_num1 + w_num2	
moltip

	clrf	 w_num1		; clear first product digit
	movf	 w_num2,W	;
	movwf	 w_count	; save multiplicand in w_count
	decf	 w_num3,F	; 
moltip1		
	clrwdt                  ; watchdog clear
	movf	 w_count,W	; sum multiplicand to the result
	addwf	 w_num2,F	; of the previous sum 
	btfss	 STATUS,C	;
	goto	 moltip2	; if there is a carry increment the
	incf	 w_num1,F	; first product digit
moltip2
	decfsz	 w_num3,F	; otherwise decrement multiplyer
	goto	 moltip1	; and re-cycle until zero	
endmolt 
	return

;	Divide routine between a two bytes dividend 
;	and a 1 byte divisor 
;  	Quotient must have only a digit
;
;	input :
;		dividend in w_num1 + w_num2
;		divisor in w_num3
;
;	output :
;		quotient in w_num1
;		remainder in w_num2	
dividi
	clrf	 w_count	; initial quotient clear
dividi1				; 
	clrwdt                  ; watchdog clear 		
	incf	 w_count,F 	; increment quotient at every re-cycle	
	movf	 w_num3,W	; subtract divisor from result obtained
	subwf	 w_num2,F	; by the previous subtraction
	btfsc	 STATUS,C	; if negative carry
	goto	 dividi1	; decrement fist dividend digit
	movlw	 d'1'		; 
	subwf	 w_num1,F
	btfsc	 STATUS,C	; re-cycle until first digit 
	goto	 dividi1	; becomes negative and
	movf	 w_num3,W	; at end restore last 
	addwf	 w_num2,F	; subtraction, putting the remainder
	decf	 w_count,F	; in w_num2
	movf	 w_count,W	; then decrements quotient
	movwf	 w_num1		; and store it in w_num1
enddiv
	return

	end
