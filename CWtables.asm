		include		p16f628.inc

		global	tab_a,tab_b,tab_c,tab_d,tab_e,tab_f
Tables		code	H'0005'
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
	end
