;	Delay routines

		global		del50,del05,delcd

		udata
rit1    res 1 ;      0x0c   
rit2    res 1 ;      0x0d

		code
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

