$NOLIST
$MODDE2

Wait40us:
	mov R0, #149
	
X1: 
	nop
	nop
	nop
	nop
	nop
	nop
	djnz R0, X1 ; 9 machine cycles-> 9*30ns*149=40us
    ret

LCD_command:
	mov	LCD_DATA, A
	clr	LCD_RS
	nop
	nop
	setb LCD_EN ; Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us

LCD_put:
	mov	LCD_DATA, A
	setb LCD_RS
	nop
	nop
	setb LCD_EN ; Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us
	
Current_State:

	lcall Wait40us
	djnz R1, Current_State

	; Move to first column of first row	
	mov a, #80H
	lcall LCD_command
		
	; Display letter A
	mov a, #'S'
	lcall LCD_put
	
	mov a, #'t'
	lcall LCD_put
	
	mov a, #'a'
	lcall LCD_put
	
	mov a, #'t'
	lcall LCD_put
	
	mov a, #'e'
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a,State
	anl a,#0FH
	orl a,#30H
	lcall LCD_put
	
    ret
    
Safe_To_Remove:

	lcall Wait40us
	djnz R1, Safe_To_Remove

	; Move to first column of first row	
	mov a, #80H
	lcall LCD_command
		
	; Display letter A
	mov a, #'S'
	lcall LCD_put
	
	mov a, #'a'
	lcall LCD_put
	
	mov a, #'f'
	lcall LCD_put
	
	mov a, #'e'
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #'t'
	lcall LCD_put
	
	mov a, #'o'
	lcall LCD_put

	mov a, #' '
	lcall LCD_put
	
	mov a, #'G'
	lcall LCD_put
	
	mov a, #'r'
	lcall LCD_put
	
	mov a, #'a'
	lcall LCD_put
	
	mov a, #'b'
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
    ret
    
Not_Safe_To_Remove:

	lcall Wait40us
	djnz R1, Not_Safe_To_Remove

	; Move to first column of first row	
	mov a, #80H
	lcall LCD_command
		
	; Display letter A
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put

	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	mov a, #' '
	lcall LCD_put
	
	
	
    ret
  
Display_BCD:  ;Display_BCD numbers on the Hex keys
	mov dptr, #myLUT

	mov r0,bcd+2
	cjne r0,#0,Turn_on
	sjmp not_100
Turn_on:
	mov a, bcd+2
	anl a, #0FH
	movc a, @a+dptr
	mov HEX6, a
	sjmp Continue_Dude
	
Not_100:
	mov Hex6,#1111111B
	
Continue_dude:	
	mov a, bcd+1
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX5, a
	
	mov a, bcd+1
	anl a, #0FH
	movc a, @a+dptr
	mov HEX4, a

	mov a, bcd+0
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX3, a
	
	mov a, bcd+0
	anl a, #0FH
	movc a, @a+dptr
	mov HEX2, a
	
	ret

	
user0:	
	;load a with swithes to check what the user wants to set
	mov a, SWA	
	cjne a, #01H, user1
	
	mov a, #0A8H
	lcall LCD_command
	
	;------Display the User Settable Soak Temp
	
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	mov x+0, soaktemp
	mov x+1, #0
	mov x+2, #0
	mov x+3, #0
	lcall hex2bcd
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	ret
	
user1:
	mov a, SWA
	cjne a, #02H, user2
	
	;----move to second line of LCD_Display
	mov a, #0A8H
	lcall LCD_command
	
	mov a, #'S'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'a'
	lcall LCD_put
	mov a, #'k'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	mov x+0, soaktime
	mov x+1, #0
	mov x+2, #0
	mov x+3, #0
	lcall hex2bcd
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	ret	

user2:
	mov a, SWA
	cjne a, #04H, user3
	
	;----move to second line of LCD_Display
	mov a, #80H
	lcall LCD_command
	
	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'p'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	
	mov x+0, reflowtemp
	mov x+1, #0
	mov x+2, #0
	mov x+3, #0
	lcall hex2bcd
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	ret	
	
user3:
	mov a, SWA
	cjne a, #08H, done
	
	;----move to second line of LCD_Display
	mov a, #0A8H
	lcall LCD_command	
	
	mov a, #'R'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #'f'
	lcall LCD_put
	mov a, #'l'
	lcall LCD_put
	mov a, #'o'
	lcall LCD_put
	mov a, #'w'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'i'
	lcall LCD_put
	mov a, #'m'
	lcall LCD_put
	mov a, #'e'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	
	
	mov x+0, reflowtime
	mov x+1, #0
	mov x+2, #0
	mov x+3, #0
	lcall hex2bcd
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #30H
	lcall LCD_put

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #30H
	lcall LCD_put
	
	ret
	
done:
;clear bottom line
	mov a, #0A8H
	lcall LCD_command
	
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	mov a, #' '
	lcall LCD_put	
	ret	
	
Current_Temp:
	lcall Wait40us
	djnz R1, Current_Temp

	; Move to first column of first row	
	mov a, #89H
	lcall LCD_command
	mov dptr, #MyLUT
	
	mov r0,bcd+2
	cjne r0,#0,Turn_ona
	sjmp not_100a
Turn_ona:
	mov a, bcd+2
	anl a,#0FH
	orl a,#30H
	lcall LCD_PUT
	
	sjmp Continue_Dudea
	
Not_100a:
	mov a,#' '
	
Continue_dudea:			
	mov a, bcd+1
	swap a
	anl a,#0FH
	orl a, #30H
	lcall LCD_Put
	
	mov a, bcd+1
	anl a,#0FH
	orl a,#30H
	lcall LCD_PUt
	
	mov a,#'.'
	lcall LCD_PUT
	
	mov a, bcd+0
	swap a
	anl a,#0FH
	orl a, #30H
	lcall LCD_PUt
	
	mov a, bcd+0
	anl a,#0FH
	orl a,#30H
	lcall LCD_put
	
    ret	    
end
$LIST