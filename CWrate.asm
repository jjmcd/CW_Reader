;	CW rate calculation
		include		p16f628.inc
		include		CWdefs.inc

		global		cw_rate,agspeed
		global		cntchar
		extern		moltip,dividi
		extern		w_num1,w_num2,w_num3,timchr1,timchr2,speed
		extern		plval

		udata
cntchar res 		1 				; received characters counter  
		code

;	Speed rate calculation routine
;	
;	is applied the formula V = (600 x chrparm)/ timchr1  
;	where chrparm is the provided number of characters
;	timchr1 is the chars packet duration in sec/10	       
;
cw_rate
	movlw	 d'10'
	movwf	 w_num2
	movlw	 chrparm
	movwf	 w_num3		; compute chrparm x 10
	call	 moltip
	movlw	 d'60'
	movwf	 w_num3		; compute chrparm x 10 x 60
	call	 moltip
	movf	 timchr1,W	
	movwf	 w_num3		; set the divisor to timchr1
	call	 dividi
	movf	 w_num2,W
	addwf	 w_num2,W	; multiply remainder x 2
	subwf	 timchr1,W	; compare timchr1 to (remainder x 2)
	btfsc	 STATUS,C	;
	goto	 cw_rate1	; if result > 0 there is no rounding
	incf	 w_num1,F	; otherwise rounding to the upper digit	 
cw_rate1
	movf	 w_num1,W
	movwf	 speed
	return

;	Speed rate update routine 
;
agspeed
	movlw	 chrparm
	subwf	 cntchar,W	; compare counter to the stated limit
	btfss	 STATUS,C	; if counter >= limit : skip
	goto	 agsped2	; if counter < limite go to end	   
	clrf	 cntchar	; clear counter
	movf     plval,F      	; verify PLVAL content
	btfsc	 STATUS,Z	; skip if <> zero
	goto	 agsped1	; otherwise bypass speed calculation
	call	 cw_rate
agsped1
	clrf	 timchr1
	clrf	 timchr2
agsped2
	incf	 cntchar,F
	return	


		end
