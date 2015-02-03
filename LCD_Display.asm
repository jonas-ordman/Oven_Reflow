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
	mov a, #0xc0
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
  
end
$LIST