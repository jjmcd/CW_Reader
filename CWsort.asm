;	Sort routines
		include		p16f628.inc

		global		ord_of,ord_on
		global		tmin1_on,tmin1_of,tmin2_on,tmin2_of,tmin3_on,tmin3_of
		extern		w_num1,w_num2,w_num3,w_num4,w_count

		udata
tmin1_on res 1 ;     0x16		;ON signal lowest duration
tmin2_on res 1 ;     0x17
tmin3_on res 1 ;     0x18 
tmin1_of res 1 ;	 0x19		;OFF signal lowest duration
tmin2_of res 1 ;	 0x1a
tmin3_of res 1 ;	 0x1b

		code

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



		end
