;	Initialize I/O
		include		p16f628.inc
		include		CWdefs.inc

		global	Initialize
		extern	timeon,timeoff,timchr1,timchr2
		extern  ctrsegn,swinput,tmed_on,tmed_of,tmax_of
		extern	tmin1_on,tmin1_of,tmin2_on,tmin2_of,tmin3_on,tmin3_of
		extern	plval,pldata,speed,cntchar

	code
Initialize
; turn off comparators
	movlw		H'07'		; Turn off comparators
	movwf		CMCON		; so they can be I/O

;	set initial value to I/O pins, timer and control registers
	clrf	 PORTA		; clear data registers
	clrf	 PORTB
    errorlevel	-302
	bsf	 STATUS,RP0	; memory bank1 set to address special registers

	movlw	 0xff		; all PORTA pins as input
	movwf	 TRISA
	movlw	 0x00		; all PORTB pins as output
	movwf	 TRISB

	bsf	 OPTION_REG,PS0
	bcf	 OPTION_REG,PS1	; set prescaler ratio to 64
	bsf	 OPTION_REG,PS2	
	bcf	 OPTION_REG,PSA	; assign prescaler to timer
	bcf	 OPTION_REG,T0CS	; assign counter to internal clock

	bcf	 STATUS,RP0	; memory bank0 reset to address data RAM
    errorlevel	+302
	movlw	 d'100'
	movwf	 TMR0		; set TMR0 initial value to 100
	bsf	 INTCON,T0IE	; timer interrupt enable
	bsf	 INTCON,GIE	; global interrupt enable
 
	clrf     ctrsegn	; clear received signs counter
	clrf	 swinput	; clear input state indicators
	bsf	 swinput,swoff	; set default OFF state
	movlw	 h'0f'		; set HIGH and LOW mean time to 150 mS 
	movwf	 tmed_on	;  
	movwf	 tmed_of
	movlw	 h'26'		; set max LOW time to 380 ms 
	movwf	 tmax_of	;
	movlw	 h'ff'		; set min ON and OFF times to high-value
	movwf	 tmin1_on	; 
	movwf	 tmin2_on	;
	movwf	 tmin3_on
	movwf	 tmin1_of
	movwf	 tmin2_of
	movwf	 tmin3_of

	clrf	 timeon		; clear ON and OFF timers 
	clrf	 timeoff
	clrf	 timchr1	; clear received characters timers 
	clrf	 timchr2

	clrf	 plval		; clear PLVAL and PLDATA
	clrf	 pldata
	clrf	 speed
	movlw	 chrparm	; set to CHRPARM the characters counter  
	movwf	 cntchar	; to force count start
	return

	end
