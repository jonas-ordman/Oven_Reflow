$NoList


Make_Buzz:
	setb Buzzer_Flag
	
Count_Down_Buzz:
	jnb Buzzer_Flag, Not_Done
	mov a, Buzz_timer
	inc a
	mov Buzz_timer,a
	;cpl p0.0 ; Set this to whatever pin the buzzer is on
	cjne a,#5, Not_Done
	clr Buzzer_Flag
	mov Buzz_Timer,#0

Not_Done:
	ret
	
	


$List