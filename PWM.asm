$NOLIST


ISR_timer0:
	; Timer 1 in 16-bit mode doesn't have autoreload.  So it is up
	; to us to reload the timer:
    mov TH1, #high(TIMER1_RELOAD)
    mov TL1, #low(TIMER1_RELOAD)
    
    ; Any used register in this ISR must be saved in the stack
    push acc
    push psw ; The carry flag resides in the program status word register
    
   	mov a,Pulse
   	
   	cjne a,#100,Not_Full_Power
   	setb p1.1
	sjmp Done_PWM

Not_Full_Power:
    cjne a,#20,Turn_Off
    clr p1.1
   	lcall Small_Delay
   	lcall Small_Delay
   	lcall Small_Delay
   	lcall Small_Delay
   	setb p1.1
   	lcall Small_Delay
 	sjmp Done_PWM

Turn_off:
	clr p1.1
	
Done_PWM:	
    
    ; Restore saved registers from the stack in reverse order
    pop psw
    pop acc
	reti

$LIST

