		title		"CW Decoding Program"
		subtitle	"CWreadr.asm $Revision: 1.4 $ $Date: 2005-02-11 15:15:30-05 $"
;**************************************************************
;                    CW decoding program                      *
;                for PIC16F628 microprocessor                 *
;                     40 chars display                        *
;**************************************************************
;       displays on LCD the last N characters received        *
;       with automatic left shift of the text                 *
;       A "service" push button (P1) displays                 *    
;       the CW rate in characters / minute                    *
;                                                             *
;	I/O pins configuration :                                  *
;                                                             *
;	RB0 : Enable  (RB3)                                       *                           
;	RB1 : RS                                                  *
;       RB2 : n/c                                             *
;       RB3 : n/c                                             *  
;       RB4 : LCD (B4) LSB                                    *
;       RB5 : LCD (B5)                                        *
;       RB6 : LCD (B6)                                        *
;       RB7 : LCD (B7) MSB                                    *  
;                                                             *
;  	RA0 : input CW      (RA4)                                 *
;       RA1 : P0                                              *  
;       RA2 : n/c                                             *  
;       RA3 : n/c                                             *  
;       RA4 : n/c                                             *  
;                                                             * 
;**************************************************************
;	processor pic16f628                                       *
;	no code protection                                        * 
;	power up timer disabled                                   *
;	WDT enabled                                               *
;	XT oscillator                                             *         	
;**************************************************************
		include		p16f628.inc
		__config	_XT_OSC & _WDT_OFF & _BODEN_OFF & _LVP_OFF & _PWRTE_ON
		include		CWdefs.inc

;	external functions
		extern		tmrint,Initialize
		extern		del05
		extern		inilcd,bytelcd,wrtlcd
		extern		panel,displ,cw_rate,agspeed
		extern		c_minof,c_minon,decod,ag_parm,dec_sg
;	provided storage	
		global		swinput
;	external storage
		extern		timeon,timeoff
		extern  	ctrsegn,tmed_of,tmax_of
		extern		cntchar

		udata
swinput res		 	1 				; input ON/OFF state indicator

;       Reset address
STARTUP	code
		goto		 main00

;       main program
		code
main00
		call		Initialize

;	initialize LCD display
		call	 	inilcd
		call		panel

;	main loop
main10
		call		del05			; delay 5 mS
main15
		call		del05			; delay 5 mS
		btfss	 	PORTA,bit_P0	; verify if P1 pressed
		goto		disparm			; if so call parameters display routine  
		goto		main20
disparm
		call		displ
dispar1
		clrwdt						; watchdog clear
		btfss	 	PORTA,bit_P0	; display remains active as long as 
		goto		dispar1			; P1 is pressed

;	ramo di decodifica CW
main20
		btfss		PORTA,bit_CW	; verify if signal HIGH on P0 
		goto		st_off			; 

;	decoding branch for an HIGH input level 
st_on
		btfsc		swinput,swon	; verify if input state changed 
		goto		main15			; otherwise wait (goto loop)
set_on
		bsf			swinput,swon	; if changed set SWON
		bcf			swinput,swoff	; reset SWOFF
		clrf		timeon			; and clear TIMEON  
		call		c_minof			; refresh min OFF-state time
		movf		tmed_of,W
		subwf		timeoff,W		; verify if OFF-state time greater
		btfss		STATUS,C		; inter-character time (tmed_of)
		goto		main10			; if less re-cycle otherwise
		call		agspeed			; update CW speed value 
		call		decod			; decode and display received char
		btfss		PORTA,bit_P1	; verify if 'space' mode active
		goto		main10			; otherwise re-cycle
		movf		tmax_of,W
		subwf		timeoff,W		; verify if OFF-state greater  
		btfss		STATUS,C		; inter-word time (tmax_of)
		goto		main10			; if less re-cycle
		movlw		" "				; otherwise insert a space
		movwf		bytelcd			; on LCD display 
		call		wrtlcd			; at end re-cycle
		goto		main10		

;	decoding branch for a LOW input level
st_off 
		btfss		swinput,swoff	; verify if input state changed
		goto		set_off			; if so set SWON
		movlw		d'200'			; otherwise verify if OFF state
		subwf		timeoff,W		; duration greater 2 seconds
		btfss		STATUS,C		; if less (ris < 0) 
		goto		main15			; re-cycle (wait)
		clrf		timeoff			; if greater 2 seconds (ris > 0) clear timeof 
		call		decod			; decode last received character
		movlw		chrparm			; set characters counter  
		movwf		cntchar			; to force count start
		goto		main15			; and re-cycle (wait)
set_off
		bsf			swinput,swoff	; if input state changed set SWOFF
		bcf			swinput,swon	; reset SWON
		clrf		timeoff			; and clear TIMEOFF
		call		c_minon			; update min ON-state time
		incf		ctrsegn,F		; increment received signs counter
		movlw		sgparm 			;
		subwf		ctrsegn,W		; verify if more than N signs received 
		btfsc		STATUS,C		;  
		call		ag_parm 		; if ctrsegn > N refresh calculation parameters
		call		dec_sg			; and received sign decoding
		goto		main10			; at end re-cycle (wait)	
	
;	end main program
		end
