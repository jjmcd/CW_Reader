;	Constants used by multiple routines

;       program constants definitions  
swon	equ	 0x00
swoff	equ	 0x01	

; 	program settable parameters 
chrparm equ	 0x08		; chars number for speed calculation
rowparm equ	 0x28		; chars number on the LCD raw
sgparm  equ	 0x0f		; dit/dashes number for param. refresh	
 	 
; port_a bits
bit_P0	equ	1
bit_P1	equ	2
bit_CW	equ	4
; port_b bits
bit_EN	equ	3
bit_RS	equ	1

