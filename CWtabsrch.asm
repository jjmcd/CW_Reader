;	Table search routines
		include		p16f628.inc

		global		ric_a,ric_b,ric_c,ric_d,ric_e,ric_f

		extern	tab_a,tab_b,tab_c,tab_d,tab_e,tab_f
		extern	w_num1,w_count
		extern	w_conv,pldata

		code

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
		 
		end
