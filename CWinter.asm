		include		p16f628.inc
		global		tmrint
		global		timeon,timeoff,timchr1,timchr2

	udata
save_w	res 1 ;	 0x22		;W register save area 
save_s	res 1 ;	 0x23		;STATUS register save area 
timeon  res 1 ;  0x12		;ON signal duration 
timeoff res 1 ;	 0x13		;OFF signal duration
timchr1	res 1 ;	 0x14		;received characters timer1 (sec/10)    
timchr2	res 1 ;	 0x15		;received characters timer2 (sec/100)   


STARTUP	code
;       Interrupt address
	org      h'0004'
tmr	goto	 tmrint	

	code
;       interrupt subroutine (only TIMER INTERRUPT)
tmrint
	movwf 	save_w		; store W in save_w
	swapf	STATUS,W	; store STATUS in W
	movwf	save_s		; store W in save_s

	incf	timeon,F	; ON timer increment
	incf	timeoff,F	; OFF timer increment
	incf	timchr2,F	; sec/100 timer increment 
	movlw	d'10'
	subwf	timchr2,W	; verify if sec/100 timer > 9
	btfss	STATUS,C
	goto	tmrint1
	clrf	timchr2		; if an overflow occurred clear sec/100
	incf	timchr1,F		; and sec/10 timer increment 
tmrint1
	movlw	d'100'		; set initial TMR0 value to 100
	movwf	TMR0		; 155 x 64 = 9.9 mS interrupt cycle
	bcf	INTCON,T0IF	; reset interrupt bit

	swapf	save_s,W	;
	movwf	STATUS		; restore STATUS register
	swapf	save_w,F	; 
	swapf	save_w,W	; restore W register
	retfie
	end
