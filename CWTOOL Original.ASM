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
;	RB0 : Enable                                          *                           
;	RB1 : RS                                              *
;       RB2 : n/c                                             *
;       RB3 : n/c                                             *  
;       RB4 : LCD (B4) LSB                                    *
;       RB5 : LCD (B5)                                        *
;       RB6 : LCD (B6)                                        *
;       RB7 : LCD (B7) MSB                                    *  
;                                                             *
;  	RA0 : input CW                                        *
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
	list	 p=16f84
	__config h'3ff9'

;       memory fixed locations

indf    equ      0x00
tmr0    equ      0x01
pcl     equ      0x02
status  equ      0x03
fsr     equ      0x04
port_a  equ      0x05
port_b  equ      0x06
eedata  equ      0x08
eeadr   equ      0x09
pclath  equ      0x0A
intcon  equ      0x0B
	
op_reg  equ      0x81
tris_a  equ      0x85
tris_b  equ      0x86
eecon1  equ      0x88
eecon2  equ      0x89

;       program variables definitions 
rit1    equ      0x0c   
rit2    equ      0x0d
cntchar equ      0x0e		;received characters counter  
bytelcd equ      0x0f
pldata  equ      0x10		;received dit/dash map (max 8)
plval   equ	 0x11		;significant dit/dash map (max 8)
timeon  equ      0x12		;ON signal duration 
timeoff equ	 0x13		;OFF signal duration
timchr1	equ	 0x14		;received characters timer1 (sec/10)    
timchr2	equ	 0x15		;received characters timer2 (sec/100)   

tmin1_on equ     0x16		;ON signal lowest duration
tmin2_on equ     0x17
tmin3_on equ     0x18 
tmin1_of equ	 0x19		;OFF signal lowest duration
tmin2_of equ	 0x1a
tmin3_of equ	 0x1b

tmed_on equ	 0x1c		;ON signal mean duration
tmed_of equ	 0x1d		;OFF signal mean duration
tmax_of equ	 0x1e		;interwords pause mean duration
speed	equ	 0x1f

swinput equ	 0x20		;input ON/OFF state indicator
ctrsegn equ	 0x21		;received signs counter 

save_w	equ	 0x22		;W register save area 
save_s	equ	 0x23		;STATUS register save area 

w_conv	equ	 0x24		;subroutines work areas  
w_count	equ	 0x25		; - hex to ascii conversion
w_num1	equ	 0x26		; - multiply
w_num2	equ	 0x27		; - divide
w_num3	equ	 0x28		;
w_num4	equ	 0x29		;

;       program constants definitions  
z       equ      0x02
dc	equ	 0x01
c       equ      0x00
irp     equ      0x07
rp1	equ	 0x06
rp0	equ	 0x05
w       equ      0x00
f	equ	 0x01
ps0	equ	 0x00
ps1	equ	 0x01
ps2	equ	 0x02
psa	equ	 0x03
t0cs	equ	 0x05
t0if	equ	 0x02
t0ie	equ	 0x05
gie	equ	 0x07
swon	equ	 0x00
swoff	equ	 0x01	

; 	program settable parameters 
chrparm equ	 0x08		; chars number for speed calculation
rowparm equ	 0x10		; chars number on the LCD raw
sgparm  equ	 0x0f		; dit/dashes number for param. refresh	
 	 

;       Reset address
	goto	 main00

;       Interrupt address
	org      h'0004'
	goto	 tmrint	

;     subroutine searching the character with W offset in the 1 sign tab_char
tab_a
	
	addwf    pcl,1 		; increments jump address
	dt       b'00000000'	; only a dit
	dt       "E"
	dt       b'00000001'  	; only a dash 
	dt       "T"
	dt       b'11111111'  	; filler
	dt       " "
endtb_a

;     subroutine searching the character with W offset in the 2 signs tab_char
tab_b
	
	addwf    pcl,1 		; increments jump address
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
	
	addwf    pcl,1 		; increments jump address
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
	
	addwf    pcl,1 		; increments jump address
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
	
	addwf    pcl,1 		; increments jump address
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
	dt       b'11111111'  	; filler
	dt       " "
endtb_e

;     subroutine searching the character with W offset in the 6 signs tab_char
tab_f
	
	addwf    pcl,1 		; increments jump address
	dt       b'00101000'	; ...-.-
	dt       "#"
	dt       b'00001100'	; ..--..
	dt       "?"
	dt       b'00100001'	; -....-
	dt       "-"
	dt       b'00101010'	; .-.-.-
	dt       "."
	dt       b'00110011'	; --..--
	dt       ","
	dt       b'11111111'  	; filler
	dt       " "
endtb_f

;       interrupt subroutine (only TIMER INTERRUPT)
tmrint
	movwf 	save_w		; store W in save_w
	swapf	status,w	; store STATUS in W
	movwf	save_s		; store W in save_s

	incf	timeon, f	; ON timer increment
	incf	timeoff, f	; OFF timer increment
	incf	timchr2, f	; sec/100 timer increment 
	movlw	d'10'
	subwf	timchr2, w	; verify if sec/100 timer > 9
	btfss	status, c
	goto	tmrint1
	clrf	timchr2		; if an overflow occurred clear sec/100
	incf	timchr1		; and sec/10 timer increment 
tmrint1
	movlw	d'100'		; set initial TMR0 value to 100
	movwf	tmr0		; 155 x 64 = 9.9 mS interrupt cycle
	bcf	intcon, t0if	; reset interrupt bit

	swapf	save_s, w	;
	movwf	status		; restore STATUS register
	swapf	save_w, f	; 
	swapf	save_w, w	; restore W register
	retfie

;       main program
main00
;	set initial value to I/O pins, timer and control registers
	clrf	 port_a		; clear data registers
	clrf	 port_b
	bsf	 status, rp0	; memory bank1 set to address special registers

	movlw	 0xff		; all port_a pins as input
	movwf	 tris_a
	movlw	 0x00		; all port_b pins as output
	movwf	 tris_b

	bsf	 op_reg, ps0
	bcf	 op_reg, ps1	; set prescaler ratio to 64
	bsf	 op_reg, ps2	
	bcf	 op_reg, psa	; assign prescaler to timer
	bcf	 op_reg, t0cs	; assign counter to internal clock

	bcf	 status, rp0	; memory bank0 reset to address data RAM
	movlw	 d'100'
	movwf	 tmr0		; set TMR0 initial value to 100
	bsf	 intcon, t0ie	; timer interrupt enable
	bsf	 intcon, gie	; global interrupt enable
 
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
	btfss	 port_a, 1	; verify if P1 pressed
	goto	 disparm	; if so call parameters display routine  
	goto	 main20
disparm
	call	 displ
dispar1
	clrwdt                  ; watchdog clear
	btfss	 port_a, 1	; display remains active as long as 
	goto	 dispar1	; P1 is pressed

;	ramo di decodifica CW
main20
	btfss	 port_a, 0	; verify if signal HIGH on P0 
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
	movf	 tmed_of, w
	subwf	 timeoff, w	; verify if OFF-state time greater
	btfss	 status, c	; inter-character time (tmed_of)
	goto	 main10		; if less re-cycle otherwise
	call	 agspeed	; update CW speed value 
	call	 decod		; decode and display received char
	btfss	 port_a, 2	; verify if 'space' mode active
	goto	 main10		; otherwise re-cycle
	movf	 tmax_of, w
	subwf	 timeoff, w	; verify if OFF-state greater  
	btfss	 status, c	; inter-word time (tmax_of)
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
	subwf	 timeoff, w	; duration greater 2 seconds
	btfss	 status, c	; if less (ris < 0) 
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
	incf	 ctrsegn, f	; increment received signs counter
	movlw	 sgparm 	;
	subwf	 ctrsegn, w	; verify if more than N signs received 
	btfsc	 status, c	;  
	call	 ag_parm 	; if ctrsegn > N refresh calculation parameters
	call	 dec_sg		; and received sign decoding
	goto	 main10		; at end re-cycle (wait)	
	
;	end main program

;	Speed rate update routine 
;
agspeed
	movlw	 chrparm
	subwf	 cntchar, w	; compare counter to the stated limit
	btfss	 status, c	; if counter >= limit : skip
	goto	 agsped2	; if counter < limite go to end	   
	clrf	 cntchar	; clear counter
	movf     plval, f      	; verify PLVAL content
	btfsc	 status, z	; skip if <> zero
	goto	 agsped1	; otherwise bypass speed calculation
	call	 cw_rate
agsped1
	clrf	 timchr1
	clrf	 timchr2
agsped2
	incf	 cntchar
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
	movf     plval, f      	; verify PLVAL content
	btfsc	 status, z	; if zero
	return			; go to end routine	
decod1	
	movlw	 d'1'		; verify if plval = 1
	subwf	 plval, f	;
	btfss	 status, z	;
	goto	 decod3		;
	call	 ric_a		; and tab A search
	goto	 endecod

decod3	
	movlw	 d'2'		; verify if plval = 3
	subwf	 plval, f	;
	btfss	 status, z	;
	goto	 decod7		;
	call	 ric_b		; and tab B search
	goto	 endecod

decod7	
	movlw	 d'4'		; verify if plval = 7
	subwf	 plval, f	;
	btfss	 status, z	;
	goto	 decod15	;
	call	 ric_c		; and tab C search
	goto	 endecod
	
decod15	
	movlw	 d'8'		; verify if plval = 15
	subwf	 plval, f	;
	btfss	 status, z	;
	goto	 decod31	;
	call	 ric_d		; and tab D search
	goto	 endecod

decod31	
	movlw	 d'16'		; verify if plval = 31
	subwf	 plval, f	;
	btfss	 status, z	;
	goto	 decod63	;
	call	 ric_e		; and tab E search
	goto	 endecod

decod63	
	movlw	 d'32'		; verify if plval = 63
	subwf	 plval, f	;
	btfss	 status, z	;
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
	subwf	 w_num1, w	;
	btfss	 status, z	; if so enforce "*" in w_conv
	goto	 ric_a2		; otherwise verify the map 
	movlw	 "*"		;
	goto	 ric_a4		;
ric_a2
	movf	 w_num1, w	; restore in W the map
	subwf	 pldata, w	; and verify if matches to PLDATA
	btfsc	 status, z	; if not re-cycle
	goto	 ric_a3
	movf	 w_count, w	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_a1		; and re-cycle
ric_a3
	movf	 w_count, w	; if map matches
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
	subwf	 w_num1, w	;
	btfss	 status, z	; if so enforce "*" in w_conv
	goto	 ric_b2		; otherwise verify the map
	movlw	 "*"		;
	goto	 ric_b4		;
ric_b2
	movf	 w_num1, w	; restore in W the map
	subwf	 pldata, w	; and verify if matches to PLDATA
	btfsc	 status, z	; if not re-cycle
	goto	 ric_b3
	movf	 w_count, w	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_b1		; and re-cycle
ric_b3
	movf	 w_count, w	; if map matches
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
	subwf	 w_num1, w	;
	btfss	 status, z	; if so enforce "*" in w_conv
	goto	 ric_c2		; otherwise verify the map
	movlw	 "*"		;
	goto	 ric_c4		;
ric_c2
	movf	 w_num1, w	; restore in W the map
	subwf	 pldata, w	; and verify if matches to PLDATA
	btfsc	 status, z	; if not re-cycle
	goto	 ric_c3
	movf	 w_count, w	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_c1		; and re-cycle
ric_c3
	movf	 w_count, w	; if map matches
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
	subwf	 w_num1, w	;
	btfss	 status, z	; if so enforce "*" in w_conv
	goto	 ric_d2		; otherwise verify the map
	movlw	 "*"		;
	goto	 ric_d4		;
ric_d2
	movf	 w_num1, w	; restore in W the map
	subwf	 pldata, w	; and verify if matches to PLDATA
	btfsc	 status, z	; if not re-cycle
	goto	 ric_d3
	movf	 w_count, w	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_d1		; and re-cycle
ric_d3
	movf	 w_count, w	; if map matches
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
	subwf	 w_num1, w	;
	btfss	 status, z	; if so enforce "*" in w_conv
	goto	 ric_e2		; otherwise verify the map
	movlw	 "*"		;
	goto	 ric_e4		;
ric_e2
	movf	 w_num1, w	; restore in W the map
	subwf	 pldata, w	; and verify if matches to PLDATA
	btfsc	 status, z	; if not re-cycle
	goto	 ric_e3
	movf	 w_count, w	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_e1		; and re-cycle
ric_e3
	movf	 w_count, w	; if map matches
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
	subwf	 w_num1, w	;
	btfss	 status, z	; if so enforce "*" in w_conv
	goto	 ric_f2		; otherwise verify the map
	movlw	 "*"		;
	goto	 ric_f4		;
ric_f2
	movf	 w_num1, w	; restore in W the map
	subwf	 pldata, w	; and verify if matches to PLDATA
	btfsc	 status, z	; if not re-cycle
	goto	 ric_f3
	movf	 w_count, w	; restore current offset to W
	addlw	 d'2'		; 2 locations increment
	goto	 ric_f1		; and re-cycle
ric_f3
	movf	 w_count, w	; if map matches
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
	movlw    b'00110001'    ; 8 bits initialization
	movwf    port_b         
	bcf      port_b,0       ; reset enable
	call     del50
	movlw    b'00110001'    ; repeat 8 bits initialization
	movwf    port_b         
	bcf      port_b,0       ; reset enable
	call     del50
	movlw    b'00110001'    ; repeat 8 bits initialization
	movwf    port_b         
	bcf      port_b,0       ; reset enable
	call     del50
	movlw    b'00100001'    ; 4 bits initialization
	movwf    port_b         
	bcf      port_b,0       ; reset enable
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
	movf	 w_num4, w 
	movwf    w_conv		; move hex byte to working area
	clrf	 w_count	; clear digit counter	
	movlw	 d'100'		; set hundred in W
conve01
	subwf	 w_conv, f	; subtract 100 from w_conv
	btfsc	 status, c	; if negative
	goto	 conve02	; restore last total
	addwf	 w_conv, f	; and exit
	goto	 conve10	; otherwise ( >=0 )	
conve02				; increment hundred counter
	incf	 w_count, f	; and loop
	goto	 conve01	

conve10
	movf	 w_count, w	; 
	iorlw	 h'30'		; set numeric half digit 
	movwf	 w_num1		; move ascii character to first output byte 
	movlw	 d'10'		; set ten in W
	clrf	 w_count	; clear digit counter	
conve11
	subwf	 w_conv, f	; subtract 10 from w_conv
	btfsc	 status, c	; if negative
	goto	 conve12	; restore last total
	addwf	 w_conv, f	; and exit
	goto	 conve20	; otherwise	
conve12				; increment ten counter
	incf	 w_count, f	; and loop
	goto	 conve11	

conve20	
	movf	 w_count, w	; 
	iorlw	 h'30'		; set numeric half digit
	movwf	 w_num2		; move ascii character to second output byte
	movf	 w_conv, w	; 
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
	decfsz	 w_count, f
	goto	 displ0
	movf	 speed, w	; display "nnn"
	movwf	 w_num4
	call	 convert
	movf	 w_num1, w
	andlw	 h'0f'
	btfss	 status, z	; if first digit zero set " "
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
	movf	 tmed_on, w	;
	subwf	 timeon, w	; verify if duration > mean ON time (dit)
	btfsc	 status, c	;
	bsf	 pldata, 0	; greater duration (dash)
	goto	 end_sg
dec_sg1
	btfsc	 plval, 1	; verify if plval = 00000001
	goto	 dec_sg2	;
	bsf	 plval, 1	; second sign of the received character
	movf	 tmed_on, w	;
	subwf	 timeon, w	; verify if duration > mean ON time (dit)
	btfsc	 status, c	;
	bsf	 pldata, 1	; greater duration (dash)
	goto	 end_sg	
dec_sg2
	btfsc	 plval, 2	; verify if plval = 00000011
	goto	 dec_sg3	;
	bsf	 plval, 2	; third sign of the received character
	movf	 tmed_on, w	;
	subwf	 timeon, w	; verify if duration > mean ON time (dit)
	btfsc	 status, c	;
	bsf	 pldata, 2	; greater duration (dash)
	goto	 end_sg
dec_sg3
	btfsc	 plval, 3	; verify if plval = 00000111
	goto	 dec_sg4	;
	bsf	 plval, 3	; fourth sign of the received character
	movf	 tmed_on, w	;
	subwf	 timeon, w	; verify if duration > mean ON time (dit)
	btfsc	 status, c	;
	bsf	 pldata, 3	; greater duration (dash)
	goto	 end_sg		
dec_sg4
	btfsc	 plval, 4	; verify if plval = 00001111
	goto	 dec_sg5	;
	bsf	 plval, 4	; fifth sign of the received character
	movf	 tmed_on, w	;
	subwf	 timeon, w	; verify if duration > mean ON time (dit)
	btfsc	 status, c	;
	bsf	 pldata, 4	; greater duration (dash)
	goto	 end_sg
dec_sg5
	btfsc	 plval, 5	; verify if plval = 00011111
	goto	 dec_sg6	;
	bsf	 plval, 5	; sixth sign of the received character
	movf	 tmed_on, w	;
	subwf	 timeon, w	; verify if duration > mean ON time (dit)
	btfsc	 status, c	;
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
	movf	 tmin3_on, w
	movwf	 w_num2		; multiplicand in w_num2
	movlw	 d'2'
	movwf	 w_num3		; 2 in w_num3
	call	 moltip
	movf	 w_num2, w
	movwf	 tmed_on

;	tmed_of computing
	movf	 tmin3_of, w
	movwf	 w_num2		; multiplicand in w_num2
	movlw	 d'2'
	movwf	 w_num3		; 2 in w_num3
	call	 moltip
	movf	 w_num2, w
	movwf	 tmed_of

;	tmax_of computing
	movf	 tmin3_of, w
	movwf	 w_num2		; multiplicand in w_num2
	movlw	 d'5'
	movwf	 w_num3		; 5 in w_num3
	call	 moltip
	movf	 w_num2, w	; compute tmax_of = tmin_of * 5
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
	movf	 timchr1, w	
	movwf	 w_num3		; set the divisor to timchr1
	call	 dividi
	movf	 w_num2, w
	addwf	 w_num2, w	; multiply remainder x 2
	subwf	 timchr1, w	; compare timchr1 to (remainder x 2)
	btfsc	 status, c	;
	goto	 cw_rate1	; if result > 0 there is no rounding
	incf	 w_num1, f	; otherwise rounding to the upper digit	 
cw_rate1
	movf	 w_num1, w
	movwf	 speed
	return

;	Minimum ON time calculation routine.
;	stores the three lowest measured values 
;	in the observation interval (sgparm = received signs)    
c_minon
	movlw	 d'3'		; verify if timeon < 30 ms
	subwf	 timeon, w	; if so no computing is done
	btfss	 status, c	; 
	goto	 end_mon	
	movf	 timeon, w	; 
	subwf	 tmin3_on, w	; calculate tmin3_on - timeon
	btfss	 status, c	;
	goto	 end_mon	; if result < 0 exit
	movf	 timeon, w	; otherwise substitute for tmin3_on
	movwf	 tmin3_on	;
	call	 ord_on		; and tabel reorg 
end_mon
	return	

;	Minimum OFF time calculation routine.
;	stores the three lowest measured values 
;	in the observation interval (sgparm = received signs) 
c_minof
	movlw	 d'3'		; verify if timeoff < 30 ms
	subwf	 timeoff, w	; if so no computing is done
	btfss	 status, c	; 
	goto	 end_mof	;
	movf	 timeoff, w	; 
	subwf	 tmin3_of, w	; calculate tmin3_of - timeoff
	btfss	 status, c	;
	goto	 end_mof	; if result < 0 exit
	movf	 timeoff, w	; otherwise substitute for tmin3_of
	movwf	 tmin3_of	;
	call	 ord_of		; and tabel reorg
end_mof
	return	

;	Ascending sort routine for
;	tmin1_on, tmin2_on, tmin3_on
ord_on
	movf	 tmin2_on, w	; 
	subwf	 tmin3_on, w	; calculate tmin3_on - tmin2_on
	btfsc	 status, c	;
	goto	 ord_on1	; if result > 0 go on
	movf	 tmin2_on, w	; otherwise swaps tmin2_on and tmin3_on 
	movwf	 w_num1		;
	movf	 tmin3_on, w	;  
	movwf	 tmin2_on	;
	movf	 w_num1, w	; 
	movwf	 tmin3_on	;
ord_on1
	movf	 tmin1_on, w	; 
	subwf	 tmin2_on, w	; calculat tmin2_on - tmin1_on
	btfsc	 status, c	;
	goto	 en_ordn	; if result > 0 go to end sort
	movf	 tmin1_on, w	; otherwise swaps tmin1_on and tmin2_on 
	movwf	 w_num1		;
	movf	 tmin2_on, w	;  
	movwf	 tmin1_on	;
	movf	 w_num1, w	; 
	movwf	 tmin2_on	;
ord_on2
	movf	 tmin2_on, w	; 
	subwf	 tmin3_on, w	; calculate tmin3_on - tmin2_on
	btfsc	 status, c	;
	goto	 en_ordn	; if result > 0 go to end sort
	movf	 tmin2_on, w	; otherwise swaps tmin2_on and tmin3_on 
	movwf	 w_num1		;
	movf	 tmin3_on, w	;  
	movwf	 tmin2_on	;
	movf	 w_num1, w	; 
	movwf	 tmin3_on	;
en_ordn
	return

;	Ascending sort routine for
;	tmin1_of, tmin2_of, tmin3_of
ord_of
	movf	 tmin2_of, w	; 
	subwf	 tmin3_of, w	; calculate tmin3_of - tmin2_of
	btfsc	 status, c	;
	goto	 ord_of1	; if result > 0 go on
	movf	 tmin2_of, w	; otherwise swaps tmin2_of and tmin3_of 
	movwf	 w_num1		;
	movf	 tmin3_of, w	;  
	movwf	 tmin2_of	;
	movf	 w_num1, w	; 
	movwf	 tmin3_of	;
ord_of1
	movf	 tmin1_of, w	; 
	subwf	 tmin2_of, w	; calculate tmin2_of - tmin1_of
	btfsc	 status, c	;
	goto	 en_ordf	; if result > 0 go to end sort
	movf	 tmin1_of, w	; otherwise swaps tmin1_of and tmin2_of 
	movwf	 w_num1		;
	movf	 tmin2_of, w	;  
	movwf	 tmin1_of	;
	movf	 w_num1, w	; 
	movwf	 tmin2_of	;
ord_of2
	movf	 tmin2_of, w	; 
	subwf	 tmin3_of, w	; calculate tmin3_of - tmin2_of
	btfsc	 status, c	;
	goto	 en_ordf	; if result > 0 go to end sort
	movf	 tmin2_of, w	; otherwise swaps tmin2_on and tmin3_on 
	movwf	 w_num1		;
	movf	 tmin3_of, w	;  
	movwf	 tmin2_of	;
	movf	 w_num1, w	; 
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
	movf	 w_num2, w	;
	movwf	 w_count	; save multiplicand in w_count
	decf	 w_num3, f	; 
moltip1		
	clrwdt                  ; watchdog clear
	movf	 w_count, w	; sum multiplicand to the result
	addwf	 w_num2, f	; of the previous sum 
	btfss	 status, c	;
	goto	 moltip2	; if there is a carry increment the
	incf	 w_num1, f	; first product digit
moltip2
	decfsz	 w_num3, f	; otherwise decrement multiplyer
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
	incf	 w_count, f 	; increment quotient at every re-cycle	
	movf	 w_num3, w	; subtract divisor from result obtained
	subwf	 w_num2, f	; by the previous subtraction
	btfsc	 status, c	; if negative carry
	goto	 dividi1	; decrement fist dividend digit
	movlw	 d'1'		; 
	subwf	 w_num1, f
	btfsc	 status,c	; re-cycle until first digit 
	goto	 dividi1	; becomes negative and
	movf	 w_num3, w	; at end restore last 
	addwf	 w_num2, f	; subtraction, putting the remainder
	decf	 w_count, f	; in w_num2
	movf	 w_count, w	; then decrements quotient
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
	movwf    fsr		; load pointer to w_num1
sendlc1
	movf	 indf, w	;
	movwf	 bytelcd	; move to bytelcd the character to send 
	call	 wrtlcd
	incf	 fsr, f		; position indf at next character	
	decfsz	 w_count, f	; re-cycle until counter is zero
	goto	 sendlc1
endsend
	return

;     This routine sends a command to LCD display (4 bits at a time)
cmdlcd
	movf     bytelcd,w
	andlw    b'11110000'    ; clear right nibble
	iorlw    b'00000001'    ; set RS = 0, ENA = 1
	movwf    port_b         ; move nibble to port_b
	bcf      port_b,0       ; enable goes down
	call     delcd          ; one delay
	
	swapf    bytelcd,0      ; exchange nibbles in bytelcd
	andlw    b'11110000'
	iorlw    b'00000001'  
	movwf    port_b
	bcf      port_b,0
	call     delcd
endcmlc
	return                

;       This routine sends a character to LCD display (4 bits at a time)
wrtlcd
	movf     bytelcd,w
	andlw    b'11110000'    ; clear right nibble
	iorlw    b'00000011'    ; set RS = 1, ENA = 1
	movwf    port_b         ; move nibble to port_b
	bcf      port_b,0       ; enable goes down
	call     delcd          ; one delay
	
	swapf    bytelcd,w      ; exchange nibbles in bytelcd
	andlw    b'11110000'
	iorlw    b'00000011'  
	movwf    port_b
	bcf      port_b,0
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