		title		"CW Decoding Program - binary to ASCII conversion"
		subtitle	"CWbinasc.asm $Revision: 1.2 $ $Date: 2005-02-03 09:06:54-05 $"
;	Binary to ASCII conversion
		include		p16f628.inc

;	Provided by this component
		global		convert
		global		w_conv
;	External storage
		extern		w_num1,w_num2,w_num3,w_num4,w_count

		udata
w_conv	res 		1 				; subroutines work areas  

		code
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

	end
