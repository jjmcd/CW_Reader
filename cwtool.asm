;**************************************************************
;                    CW decoding program                      *
;                for PIC16F84 microprocessor                  *
;            dual mode version - 16 chars display             *
;**************************************************************
;       displays on LCD the last N characters received        *
;       with automatic left shift of the text                 *
;       A "service" push button (P1) displays                 *    
;       the CW rate in characters / minute                    *
;                                                             *
;	I/O pins configuration :                              *
;                                                             *
;	RB0 : Enable  (RB3)                                   *                           
;	RB1 : RS                                              *
;       RB2 : n/c                                             *
;       RB3 : n/c                                             *  
;       RB4 : LCD (B4) LSB                                    *
;       RB5 : LCD (B5)                                        *
;       RB6 : LCD (B6)                                        *
;       RB7 : LCD (B7) MSB                                    *  
;                                                             *
;  	RA0 : input CW      (RA4)                             *
;       RA1 : P0                                              *  
;       RA2 : n/c                                             *  
;       RA3 : n/c                                             *  
;       RA4 : n/c                                             *  
;                                                             * 
;**************************************************************
;	processor pic16f84                                    *
;	no code protection                                    * 
;	power up timer disabled                               *
;	WDT enabled                                           *
;	XT oscillator                                         *         	
;**************************************************************
	list	 p=16f628
	include	p16f628.inc
	__config	_XT_OSC & _WDT_OFF & _BODEN_OFF & _LVP_OFF & _PWRTE_ON

;       memory fixed locations

; port_a bits
bit_P0	equ	1
bit_P1	equ	2
bit_CW	equ	4
; port_b bits
bit_EN	equ	3
bit_RS	equ	1

;       program variables definitions 
		cblock	0x20
	rit1    ;      0x0c   
	rit2    ;      0x0d
	cntchar ;      0x0e		;received characters counter  
	bytelcd ;      0x0f
	pldata  ;      0x10		;received dit/dash map (max 8)
	plval   ;	 0x11		;significant dit/dash map (max 8)
	timeon  ;      0x12		;ON signal duration 
	timeoff ;	 0x13		;OFF signal duration
	timchr1	;	 0x14		;received characters timer1 (sec/10)    
	timchr2	;	 0x15		;received characters timer2 (sec/100)   

	tmin1_on ;     0x16		;ON signal lowest duration
	tmin2_on ;     0x17
	tmin3_on ;     0x18 
	tmin1_of ;	 0x19		;OFF signal lowest duration
	tmin2_of ;	 0x1a
	tmin3_of ;	 0x1b

	tmed_on ;	 0x1c		;ON signal mean duration
	tmed_of ;	 0x1d		;OFF signal mean duration
	tmax_of ;	 0x1e		;interwords pause mean duration
	speed	;	 0x1f

	swinput ;	 0x20		;input ON/OFF state indicator
	ctrsegn ;	 0x21		;received signs counter 

	save_w	;	 0x22		;W register save area 
	save_s	;	 0x23		;STATUS register save area 

	w_conv	;	 0x24		;subroutines work areas  
	w_count	;	 0x25		; - hex to ascii conversion
	w_num1	;	 0x26		; - multiply
	w_num2	;	 0x27		; - divide
	w_num3	;	 0x28		;
	w_num4	;	 0x29		;
	endc


;       program constants definitions  
swon	equ	 0x00
swoff	equ	 0x01	

; 	program settable parameters 
chrparm equ	 0x08		; chars number for speed calculation
rowparm equ	 0x28		; chars number on the LCD raw
sgparm  equ	 0x0f		; dit/dashes number for param. refresh	
 	 

;       Reset address
	goto	 main00

;       Interrupt address
	org      h'0004'
	goto	 tmrint	

;     subroutine searching the character with W offset in the 1 sign tab_char
tab_a
	
	addwf    PCL,1 		; increments jump address
	dt       b'00000000'	; only a dit
	dt       "E"
	dt       b'00000001'  	; only a dash 
	dt       "T"
	dt       b'11111111'  	; filler
	dt       " "
endtb_a

;     subroutine searching the character with W offset in the 2 signs tab_char
tab_b
	
	addwf    PCL,1 		; increments jump address
	dt       b'00000000'	; ..
	dt       "I"
	dt       b'00000010'  	; .-
	dt       "A"
	dt       b'00000001'  	; -.
	dt       "N"
	dt       b'00000011'  	; --
	dt       "M"
	dt       b'11111111'  	; filler
	dt       " "
endtb_b

;     subroutine searching the character with W offset in the 3 signs tab_char
tab_c
	
	addwf    PCL,1 		; increments jump address
	dt       b'00000000'	; ...
	dt       "S"
	dt       b'00000100'  	; ..-
	dt       "U"
	dt       b'00000010'  	; .-.
	dt       "R"
	dt       b'00000110'  	; .--
	dt       "W"
	dt       b'00000001'  	; -..
	dt       "D"
	dt       b'00000101'  	; -.-
	dt       "K"
	dt       b'00000011'  	; --.
	dt       "G"
	dt       b'00000111'  	; ---
	dt       "O"
	dt       b'11111111'  	; filler
	dt       " "
endtb_c

;     subroutine searching the character with W offset in the 4 signs tab_char
tab_d
	
	addwf    PCL,1 		; increments jump address
	dt       b'00000000'	; ....
	dt       "H"
	dt       b'00001000'  	; ...-
	dt       "V"
	dt       b'00000100'  	; ..-.
	dt       "F"
	dt       b'00000010'  	; .-..
	dt       "L"
	dt       b'00000110'  	; .--.
	dt       "P"
	dt       b'00001110'  	; .---
	dt       "J"
	dt       b'00000001'	; -...
	dt       "B"
	dt       b'00001001'  	; -..-
	dt       "X"
	dt       b'00000101'  	; -.-.
	dt       "C"
	dt       b'00001101'  	; -.--
	dt       "Y"
	dt       b'00000011'  	; --..
	dt       "Z"
	dt       b'00001011'  	; --.-
	dt       "Q"
	dt       b'11111111'  	; filler
	dt       " "
endtb_d

;     subroutine searching the character with W offset in the 5 signs tab_char
tab_e
	
	addwf    PCL,1 		; increments jump address
	dt       b'00000000'	; .....
	dt       "5"
	dt       b'00010000'  	; ....-
	dt       "4"
	dt       b'00011000'  	; ...--
	dt       "3"
	dt       b'00011100'  	; ..---
	dt       "2"
	dt       b'00011110'  	; .----
	dt       "1"
	dt       b'00011111'  	; -----
	dt       "0"
	dt       b'00000001'  	; -....
	dt       "6"
	dt       b'00000011'  	; --...
	dt       "7"
	dt       b'00000111'	; ---..
	dt       "8"
	dt       b'00001111'  	; ----.
	dt       "9"
	dt       b'00010001'  	; -...-
	dt       "="
	dt       b'00001001'  	; -..-.
	dt       "/"
	dt       b'00000010'  	; .-...
	dt       "w"
	dt       b'00010110'  	; -.--.  same as KN :-(
	dt       "("
	dt       b'11111111'  	; filler
	dt       " "
endtb_e

;     subroutine searching the character with W offset in the 6 signs tab_char
tab_f
	
	addwf    PCL,1 		; increments jump address
	dt       b'00101000'	; ...-.-   SK
	dt       "#"
	dt       b'00001100'	; ..--.. 
	dt       "?"
	dt       b'00100001'	; -....-
	dt       "-"
	dt       b'00101010'	; .-.-.-
	dt       "."
	dt       b'00110011'	; --..--
	dt       ","
	dt       b'00101101'  	; -.--.-
	dt       ")"
	dt       b'00101010'  	; -.-.-.
	dt       ";"
	dt       b'00010010'  	; .-..-.
	dt       022h
	dt       b'00011110'  	; .----.
	dt       "'"
	dt       b'00001101'  	; ..--.-
	dt       "_"
	dt       b'11111111'  	; filler
	dt       " "
endtb_f

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

;       main program
main00
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
	bsf	 swinput, swoff	; set default OFF state
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
	clrf	 plval		; clear PLVAL and PLDATA
	clrf	 pldata
	clrf	 timchr1	; clear received characters timers 
	clrf	 timchr2
	clrf	 speed
	movlw	 chrparm	; set to CHRPARM the characters counter  
	movwf	 cntchar	; to force count start

;	initialize LCD display
	call	 inilcd
	call	 panel

;	main loop
main10
	call	 del05		; delay 5 mS
main15
	call	 del05		; delay 5 mS
	btfss	 PORTA,bit_P0	; verify if P1 pressed
	goto	 disparm	; if so call parameters display routine  
	goto	 main20
disparm
	call	 displ
dispar1
	clrwdt                  ; watchdog clear
	btfss	 PORTA,bit_P0	; display remains active as long as 
	goto	 dispar1	; P1 is pressed

;	ramo di decodifica CW
main20
	btfss	 PORTA,bit_CW	; verify if signal HIGH on P0 
	goto	 st_off		; 

;	decoding branch for an HIGH input level 
st_on
	btfsc	 swinput, swon	; verify if input state changed 
	goto	 main15		; otherwise wait (goto loop)
set_on
	bsf	 swinput, swon	; if changed set SWON
	bcf	 swinput, swoff	; reset SWOFF
	clrf	 timeon		; and clear TIMEON  
	call	 c_minof	; refresh min OFF-state time
	movf	 tmed_of,W
	subwf	 timeoff,W	; verify if OFF-state time greater
	btfss	 STATUS,C	; inter-character time (tmed_of)
	goto	 main10		; if less re-cycle otherwise
	call	 agspeed	; update CW speed value 
	call	 decod		; decode and display received char
	btfss	 PORTA,bit_P1	; verify if 'space' mode active
	goto	 main10		; otherwise re-cycle
	movf	 tmax_of,W
	subwf	 timeoff,W	; verify if OFF-state greater  
	btfss	 STATUS,C	; inter-word time (tmax_of)
	goto	 main10		; if less re-cycle
	movlw	 " "		; otherwise insert a space
	movwf	 bytelcd	; on LCD display 
	call	 wrtlcd		; at end re-cycle
	goto	 main10		

;	decoding branch for a LOW input level
st_off 
	btfss	 swinput, swoff	; verify if input state changed
	goto	 set_off	; if so set SWON
	movlw	 d'200'		; otherwise verify if OFF state
	subwf	 timeoff,W	; duration greater 2 seconds
	btfss	 STATUS,C	; if less (ris < 0) 
	goto	 main15		; re-cycle (wait)
	clrf	 timeoff	; if greater 2 seconds (ris > 0) clear timeof 
	call	 decod		; decode last received character
	movlw	 chrparm	; set characters counter  
	movwf	 cntchar	; to force count start
	goto	 main15		; and re-cycle (wait)
set_off
	bsf	 swinput, swoff	; if input state changed set SWOFF
	bcf	 swinput, swon	; reset SWON
	clrf	 timeoff	; and clear TIMEOFF
	call	 c_minon	; update min ON-state time
	incf	 ctrsegn,F	; increment received signs counter
	movlw	 sgparm 	;
	subwf	 ctrsegn,W	; verify if more than N signs received 
	btfsc	 STATUS,C	;  
	call	 ag_parm 	; if ctrsegn > N refresh calculation parameters
	call	 dec_sg		; and received sign decoding
	goto	 main10		; at end re-cycle (wait)	
	
;	end main program

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

;	Received character decoding routine
;
;	input : 	
;	- PLVAL area containing significant bits map
;	- PLDATA area containing received values (0=dit,1=dash) 
;
;	output :
;	- decoded character in w_conv  
;	- decoded character on LCD display
;	
decod
	movlw	 " "		; space default character
	movwf	 w_conv		;
	movf     plval,F      	; verify PLVAL content
	btfsc	 STATUS,Z	; if zero
	return			; go to end routine	
decod1	
	movlw	 d'1'		; verify if plval = 1
	subwf	 plval,F	;
	btfss	 STATUS,Z	;
	goto	 decod3		;
	call	 ric_a		; and tab A search
	goto	 endecod

decod3	
	movlw	 d'2'		; verify if plval = 3
	subwf	 plval,F	;
	btfss	 STATUS,Z	;
	goto	 decod7		;
	call	 ric_b		; and tab B search
	goto	 endecod

decod7	
	movlw	 d'4'		; verify if plval = 7
	subwf	 plval,F	;
	btfss	 STATUS,Z	;
	goto	 decod15	;
	call	 ric_c		; and tab C search
	goto	 endecod
	
decod15	
	movlw	 d'8'		; verify if plval = 15
	subwf	 plval,F	;
	btfss	 STATUS,Z	;
	goto	 decod31	;
	call	 ric_d		; and tab D search
	goto	 endecod

decod31	
	movlw	 d'16'		; verify if plval = 31
	subwf	 plval,F	;
	btfss	 STATUS,Z	;
	goto	 decod63	;
	call	 ric_e		; and tab E search
	goto	 endecod

decod63	
	movlw	 d'32'		; verify if plval = 63
	subwf	 plval,F	;
	btfss	 STATUS,Z	;
	goto	 nodecod	;
	call	 ric_f		; and tab F search
	goto	 endecod

nodecod
	movlw	 "*"
endecod
	movwf	 w_conv		; at end save in w_conv decoded character
	movwf	 bytelcd
	clrf	 plval		; clear PLVAL e PLDATA
	clrf	 pldata
	call	 wrtlcd		; display decoded character

	return

;	Tab search subroutines 
;
;	input : 	
;	- PLDATA area containing received values (0=dit,1=dash) 
;
;	output :
;	- decoded character in w_conv  
;	
ric_a
	clrw			; initial offset = 0
ric_a1
	movwf	 w_count	; save current offset
	call     tab_a          ; search entry at offset W
	movwf	 w_num1		; save found map 
	movlw	 b'11111111'	; verify if tab bottom reached
	subwf	 w_num1,W	;
	btfss	 STATUS,Z	; if so enforce "*" in w_conv
	goto	 ric_a2		; otherwise verify the map 
	movlw	 "*"		;
	goto	 ric_a4		;
ric_a2
	movf	 w_num1,W	; restore in W the map
	subwf	 pldata,W	; and verify if matches to PLDATA
	btfsc	 STATUS,Z	; if not re-cycle
	goto	 ric_a3
	movf	 w_count,W	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_a1		; and re-cycle
ric_a3
	movf	 w_count,W	; if map matches
	addlw	 d'1'		; 1 location increment
	call	 tab_a		; and get corresponding character
ric_a4
	movwf	 w_conv
	return

ric_b
	clrw			; initial offset = 0
ric_b1
	movwf	 w_count	; save current offset
	call     tab_b          ; search entry at offset W
	movwf	 w_num1		; save found map 
	movlw	 b'11111111'	; verify if tab bottom reached
	subwf	 w_num1,W	;
	btfss	 STATUS,Z	; if so enforce "*" in w_conv
	goto	 ric_b2		; otherwise verify the map
	movlw	 "*"		;
	goto	 ric_b4		;
ric_b2
	movf	 w_num1,W	; restore in W the map
	subwf	 pldata,W	; and verify if matches to PLDATA
	btfsc	 STATUS,Z	; if not re-cycle
	goto	 ric_b3
	movf	 w_count,W	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_b1		; and re-cycle
ric_b3
	movf	 w_count,W	; if map matches
	addlw	 d'1'		; 1 location increment
	call	 tab_b		; and get corresponding character
ric_b4
	movwf	 w_conv
	return

ric_c
	clrw			; initial offset = 0
ric_c1
	movwf	 w_count	; save current offset
	call     tab_c          ; search entry at offset W
	movwf	 w_num1		; save found map 
	movlw	 b'11111111'	; verify if tab bottom reached
	subwf	 w_num1,W	;
	btfss	 STATUS,Z	; if so enforce "*" in w_conv
	goto	 ric_c2		; otherwise verify the map
	movlw	 "*"		;
	goto	 ric_c4		;
ric_c2
	movf	 w_num1,W	; restore in W the map
	subwf	 pldata,W	; and verify if matches to PLDATA
	btfsc	 STATUS,Z	; if not re-cycle
	goto	 ric_c3
	movf	 w_count,W	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_c1		; and re-cycle
ric_c3
	movf	 w_count,W	; if map matches
	addlw	 d'1'		; 1 location increment
	call	 tab_c		; and get corresponding character
ric_c4
	movwf	 w_conv
	return

ric_d
	clrw			; initial offset = 0
ric_d1
	movwf	 w_count	; save current offset
	call     tab_d          ; search entry at offset W
	movwf	 w_num1		; save found map 
	movlw	 b'11111111'	; verify if tab bottom reached
	subwf	 w_num1,W	;
	btfss	 STATUS,Z	; if so enforce "*" in w_conv
	goto	 ric_d2		; otherwise verify the map
	movlw	 "*"		;
	goto	 ric_d4		;
ric_d2
	movf	 w_num1,W	; restore in W the map
	subwf	 pldata,W	; and verify if matches to PLDATA
	btfsc	 STATUS,Z	; if not re-cycle
	goto	 ric_d3
	movf	 w_count,W	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_d1		; and re-cycle
ric_d3
	movf	 w_count,W	; if map matches
	addlw	 d'1'		; 1 location increment
	call	 tab_d		; and get corresponding character
ric_d4
	movwf	 w_conv
	return

ric_e
	clrw			; initial offset = 0
ric_e1
	movwf	 w_count	; save current offset
	call     tab_e          ; search entry at offset W
	movwf	 w_num1		; save found map 
	movlw	 b'11111111'	; verify if tab bottom reached
	subwf	 w_num1,W	;
	btfss	 STATUS,Z	; if so enforce "*" in w_conv
	goto	 ric_e2		; otherwise verify the map
	movlw	 "*"		;
	goto	 ric_e4		;
ric_e2
	movf	 w_num1,W	; restore in W the map
	subwf	 pldata,W	; and verify if matches to PLDATA
	btfsc	 STATUS,Z	; if not re-cycle
	goto	 ric_e3
	movf	 w_count,W	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_e1		; and re-cycle
ric_e3
	movf	 w_count,W	; if map matches
	addlw	 d'1'		; 1 location increment
	call	 tab_e		; and get corresponding character
ric_e4
	movwf	 w_conv
	return

ric_f
	clrw			; initial offset = 0
ric_f1
	movwf	 w_count	; save current offset
	call     tab_f          ; search entry at offset W
	movwf	 w_num1		; save found map 
	movlw	 b'11111111'	; verify if tab bottom reached
	subwf	 w_num1,W	;
	btfss	 STATUS,Z	; if so enforce "*" in w_conv
	goto	 ric_f2		; otherwise verify the map
	movlw	 "*"		;
	goto	 ric_f4		;
ric_f2
	movf	 w_num1,W	; restore in W the map
	subwf	 pldata,W	; and verify if matches to PLDATA
	btfsc	 STATUS,Z	; if not re-cycle
	goto	 ric_f3
	movf	 w_count,W	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_f1		; and re-cycle
ric_f3
	movf	 w_count,W	; if map matches
	addlw	 d'1'		; 1 location increment
	call	 tab_f		; and get corresponding character
ric_f4
	movwf	 w_conv
	return
		 
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

;	Conversion routine from hex (1 byte) to ascii (3 bytes)
;
;	input : 	- hex value in w_num4
;
;	output :	- ascii value on 3 bytes starting from w_num1  
;	
convert
	movf	 w_num4,W 
	movwf    w_conv		; move hex byte to working area
	clrf	 w_count	; clear digit counter	
	movlw	 d'100'		; set hundred in W
conve01
	subwf	 w_conv,F	; subtract 100 from w_conv
	btfsc	 STATUS,C	; if negative
	goto	 conve02	; restore last total
	addwf	 w_conv,F	; and exit
	goto	 conve10	; otherwise ( >=0 )	
conve02				; increment hundred counter
	incf	 w_count,F	; and loop
	goto	 conve01	

conve10
	movf	 w_count,W	; 
	iorlw	 h'30'		; set numeric half digit 
	movwf	 w_num1		; move ascii character to first output byte 
	movlw	 d'10'		; set ten in W
	clrf	 w_count	; clear digit counter	
conve11
	subwf	 w_conv,F	; subtract 10 from w_conv
	btfsc	 STATUS,C	; if negative
	goto	 conve12	; restore last total
	addwf	 w_conv,F	; and exit
	goto	 conve20	; otherwise	
conve12				; increment ten counter
	incf	 w_count,F	; and loop
	goto	 conve11	

conve20	
	movf	 w_count,W	; 
	iorlw	 h'30'		; set numeric half digit
	movwf	 w_num2		; move ascii character to second output byte
	movf	 w_conv,W	; 
	iorlw	 h'30'		; set unit numeric half digit
	movwf	 w_num3		; move ascii character to third output byte
endconv
	return

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

;	Received sign decoding routine 
;
;	input : 
;	- received signal duration  	
;	- PLVAL area containing map of received signs
;	- PLDATA area containing received values (0=punto, 1=linea) 
;
;	output :
;	- updated PLVAL area  
;	- updated PLDATA area
;	
dec_sg
	btfsc	 plval, 0	; verify if plval = 00000000
	goto	 dec_sg1	;
	bsf	 plval, 0	; first sign of the received character
	movf	 tmed_on,W	;
	subwf	 timeon,W	; verify if duration > mean ON time (dit)
	btfsc	 STATUS,C	;
	bsf	 pldata, 0	; greater duration (dash)
	goto	 end_sg
dec_sg1
	btfsc	 plval, 1	; verify if plval = 00000001
	goto	 dec_sg2	;
	bsf	 plval, 1	; second sign of the received character
	movf	 tmed_on,W	;
	subwf	 timeon,W	; verify if duration > mean ON time (dit)
	btfsc	 STATUS,C	;
	bsf	 pldata, 1	; greater duration (dash)
	goto	 end_sg	
dec_sg2
	btfsc	 plval, 2	; verify if plval = 00000011
	goto	 dec_sg3	;
	bsf	 plval, 2	; third sign of the received character
	movf	 tmed_on,W	;
	subwf	 timeon,W	; verify if duration > mean ON time (dit)
	btfsc	 STATUS,C	;
	bsf	 pldata, 2	; greater duration (dash)
	goto	 end_sg
dec_sg3
	btfsc	 plval, 3	; verify if plval = 00000111
	goto	 dec_sg4	;
	bsf	 plval, 3	; fourth sign of the received character
	movf	 tmed_on,W	;
	subwf	 timeon,W	; verify if duration > mean ON time (dit)
	btfsc	 STATUS,C	;
	bsf	 pldata, 3	; greater duration (dash)
	goto	 end_sg		
dec_sg4
	btfsc	 plval, 4	; verify if plval = 00001111
	goto	 dec_sg5	;
	bsf	 plval, 4	; fifth sign of the received character
	movf	 tmed_on,W	;
	subwf	 timeon,W	; verify if duration > mean ON time (dit)
	btfsc	 STATUS,C	;
	bsf	 pldata, 4	; greater duration (dash)
	goto	 end_sg
dec_sg5
	btfsc	 plval, 5	; verify if plval = 00011111
	goto	 dec_sg6	;
	bsf	 plval, 5	; sixth sign of the received character
	movf	 tmed_on,W	;
	subwf	 timeon,W	; verify if duration > mean ON time (dit)
	btfsc	 STATUS,C	;
	bsf	 pldata, 5	; greater duration (dash)
	goto	 end_sg	
dec_sg6
	bsf	 plval, 6	; if more than six signs set a default 		
end_sg	
	return

;	Working parameters calculation routine
;	
;	tmed_on 
;	tmed_of    
;	tmax_of      
;
ag_parm
;	tmed_on computing
	movf	 tmin3_on,W
	movwf	 w_num2		; multiplicand in w_num2
	movlw	 d'2'
	movwf	 w_num3		; 2 in w_num3
	call	 moltip
	movf	 w_num2,W
	movwf	 tmed_on

;	tmed_of computing
	movf	 tmin3_of,W
	movwf	 w_num2		; multiplicand in w_num2
	movlw	 d'2'
	movwf	 w_num3		; 2 in w_num3
	call	 moltip
	movf	 w_num2,W
	movwf	 tmed_of

;	tmax_of computing
	movf	 tmin3_of,W
	movwf	 w_num2		; multiplicand in w_num2
	movlw	 d'5'
	movwf	 w_num3		; 5 in w_num3
	call	 moltip
	movf	 w_num2,W	; compute tmax_of = tmin_of * 5
	movwf	 tmax_of

	clrf	 ctrsegn
	movlw	 0xff
	movwf	 tmin1_on
	movwf	 tmin2_on
	movwf	 tmin3_on
	movwf	 tmin1_of
	movwf	 tmin2_of
	movwf	 tmin3_of
	return

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

;	Minimum ON time calculation routine.
;	stores the three lowest measured values 
;	in the observation interval (sgparm = received signs)    
c_minon
	movlw	 d'3'		; verify if timeon < 30 ms
	subwf	 timeon,W	; if so no computing is done
	btfss	 STATUS,C	; 
	goto	 end_mon	
	movf	 timeon,W	; 
	subwf	 tmin3_on,W	; calculate tmin3_on - timeon
	btfss	 STATUS,C	;
	goto	 end_mon	; if result < 0 exit
	movf	 timeon,W	; otherwise substitute for tmin3_on
	movwf	 tmin3_on	;
	call	 ord_on		; and tabel reorg 
end_mon
	return	

;	Minimum OFF time calculation routine.
;	stores the three lowest measured values 
;	in the observation interval (sgparm = received signs) 
c_minof
	movlw	 d'3'		; verify if timeoff < 30 ms
	subwf	 timeoff,W	; if so no computing is done
	btfss	 STATUS,C	; 
	goto	 end_mof	;
	movf	 timeoff,W	; 
	subwf	 tmin3_of,W	; calculate tmin3_of - timeoff
	btfss	 STATUS,C	;
	goto	 end_mof	; if result < 0 exit
	movf	 timeoff,W	; otherwise substitute for tmin3_of
	movwf	 tmin3_of	;
	call	 ord_of		; and tabel reorg
end_mof
	return	

;	Ascending sort routine for
;	tmin1_on, tmin2_on, tmin3_on
ord_on
	movf	 tmin2_on,W	; 
	subwf	 tmin3_on,W	; calculate tmin3_on - tmin2_on
	btfsc	 STATUS,C	;
	goto	 ord_on1	; if result > 0 go on
	movf	 tmin2_on,W	; otherwise swaps tmin2_on and tmin3_on 
	movwf	 w_num1		;
	movf	 tmin3_on,W	;  
	movwf	 tmin2_on	;
	movf	 w_num1,W	; 
	movwf	 tmin3_on	;
ord_on1
	movf	 tmin1_on,W	; 
	subwf	 tmin2_on,W	; calculat tmin2_on - tmin1_on
	btfsc	 STATUS,C	;
	goto	 en_ordn	; if result > 0 go to end sort
	movf	 tmin1_on,W	; otherwise swaps tmin1_on and tmin2_on 
	movwf	 w_num1		;
	movf	 tmin2_on,W	;  
	movwf	 tmin1_on	;
	movf	 w_num1,W	; 
	movwf	 tmin2_on	;
ord_on2
	movf	 tmin2_on,W	; 
	subwf	 tmin3_on,W	; calculate tmin3_on - tmin2_on
	btfsc	 STATUS,C	;
	goto	 en_ordn	; if result > 0 go to end sort
	movf	 tmin2_on,W	; otherwise swaps tmin2_on and tmin3_on 
	movwf	 w_num1		;
	movf	 tmin3_on,W	;  
	movwf	 tmin2_on	;
	movf	 w_num1,W	; 
	movwf	 tmin3_on	;
en_ordn
	return

;	Ascending sort routine for
;	tmin1_of, tmin2_of, tmin3_of
ord_of
	movf	 tmin2_of,W	; 
	subwf	 tmin3_of,W	; calculate tmin3_of - tmin2_of
	btfsc	 STATUS,C	;
	goto	 ord_of1	; if result > 0 go on
	movf	 tmin2_of,W	; otherwise swaps tmin2_of and tmin3_of 
	movwf	 w_num1		;
	movf	 tmin3_of,W	;  
	movwf	 tmin2_of	;
	movf	 w_num1,W	; 
	movwf	 tmin3_of	;
ord_of1
	movf	 tmin1_of,W	; 
	subwf	 tmin2_of,W	; calculate tmin2_of - tmin1_of
	btfsc	 STATUS,C	;
	goto	 en_ordf	; if result > 0 go to end sort
	movf	 tmin1_of,W	; otherwise swaps tmin1_of and tmin2_of 
	movwf	 w_num1		;
	movf	 tmin2_of,W	;  
	movwf	 tmin1_of	;
	movf	 w_num1,W	; 
	movwf	 tmin2_of	;
ord_of2
	movf	 tmin2_of,W	; 
	subwf	 tmin3_of,W	; calculate tmin3_of - tmin2_of
	btfsc	 STATUS,C	;
	goto	 en_ordf	; if result > 0 go to end sort
	movf	 tmin2_of,W	; otherwise swaps tmin2_on and tmin3_on 
	movwf	 w_num1		;
	movf	 tmin3_of,W	;  
	movwf	 tmin2_of	;
	movf	 w_num1,W	; 
	movwf	 tmin3_of	;
en_ordf
	return	

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

;       50 mS delay routine 
del50
	movlw    d'125'         ; 125 primary cycles
	movwf    rit1           ; 
del51
	movlw    d'100'         ; 100 secondary cycles
	movwf    rit2
del52
	clrwdt                  ; watchdog clear
	decfsz   rit2,1         ; decrement counter2
	goto     del52          ; if counter2 > 0 re-cycle				; re-cycle
	decfsz   rit1,1         ; if counter2 = 0 decrement counter1        
	goto     del51          ; if counter1 > 0 re-cycle
endl50
	return                  ; end routine

;       5 mS delay routine 
del05
	movlw    d'48'         ; 48 primary cycles
	movwf    rit1           ; 
del051
	movlw    d'25'         ; 25 secondary cycles
	movwf    rit2
del052
	clrwdt                  ; watchdog clear
	decfsz   rit2,1         ; decrement counter2
	goto     del052         ; if counter2 > 0 re-cycle
	decfsz   rit1,1         ; if counter2 = 0 decrement counter1        
	goto     del051         ; if counter1 > 0 re-cycle
endl05
	return                  ; end routine

;       0.25 mS delay routine 
delcd
	movlw    d'50'          ; 50 delay cycles
	movwf    rit1
delcd1  
	clrwdt                  ; watchdog clear
	nop                     ; 1 microsec delay
	decfsz   rit1,1         ; if counter > 0 re-cycle
	goto     delcd1         
endcd
	return                  ; end routine

	end
