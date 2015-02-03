; Blinky_Int.asm: blinks LEDR0 of the DE2-8052 each second.
; Also generates a 2kHz signal at P0.0 using timer 0 interrupt.
; Also keeps a BCD counter using timer 2 interrupt.


CLK 		  EQU 33333333
FREQ_0 		  EQU 2000
FREQ_2 		  EQU 100
TIMER0_RELOAD EQU 65536-(CLK/(12*2*FREQ_0))
TIMER2_RELOAD EQU 65536-(CLK/(12*FREQ_2))
CE_ADC 		  EQU p0.3
SCLK   		  EQU p0.2
MOSI   		  EQU P0.1
MISO   		  EQU p0.0

org 0000H
	ljmp myprogram
	
org 000BH
	ljmp ISR_timer0
	
org 002BH
	ljmp ISR_timer2

DSEG at 30H
BCD_count	:  ds 1
Cnt_10ms 	:  ds 1
State_Sec	:  ds 1
Seconds  	:  ds 1
Minutes  	:  ds 1
Pulse       :  ds 1
Temperature :  ds 1
State       :  ds 1
x			:  ds 4
y			:  ds 4
bcd			:  ds 5

BSEG
mf			:  dbit 1

$include(math32.asm)
$include(LCD_Display.asm)

CSEG

; Look-up table for 7-segment displays
myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H

ISR_timer2:
	push psw
	push acc
	push dpl
	push dph
	
	clr TF2
	cpl P0.1
	
	mov a, Cnt_10ms
	inc a
	mov Cnt_10ms, a
	
	cjne a, #100, do_nothing
	
	mov Cnt_10ms, #0
	
;State_Sec    The seconds for State Transitions
	mov a, State_Sec
	inc a
	mov State_Sec, a
	
;Seconds		Can use this timer incase we decide to have a clock 
	mov a, Seconds
	inc a
	da a
	mov Seconds, a
	cjne a,#60H,do_nothing
	mov Seconds,#0
	
;Minutes
	mov a,Minutes
	inc a
	da a
	mov Minutes,a
	cjne a,#60H,do_nothing
	mov Minutes,#0
	
do_nothing:
	lcall update_display  ;Updates display on Hex to display current time
	pop dph
	pop dpl
	pop acc
	pop psw
	
	reti

	
ISR_timer0:
	cpl P0.0
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
	reti
	
;For a 33.33MHz clock, one cycle takes 30ns
WaitHalfSec:
	mov R2, #90
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1
	djnz R1, L2
	djnz R2, L3
	ret
	
myprogram:  ; Set inputs/outputs depending on what whoever does the board solders 
	mov SP, #7FH
	mov LEDRA,#0
	mov LEDRB,#0
	mov LEDRC,#0
	mov LEDG,#0
	mov Temperature,#0
	mov State_Sec,#0
	mov Seconds,#0
	mov Minutes,#0
	mov State,#0
	
	
	setb LCD_ON  ;All this code is to prep the LCD
  	setb LCD_blON
    clr LCD_EN  ; Default state of enable must be zero
    lcall Wait40us
    mov LCD_MOD, #0xff ; Use LCD_DATA as output port
    clr LCD_RW ;  Only writing to the LCD in this code.
	mov a, #0ch ; Display on command
	lcall LCD_command
	mov a, #38H ; 8-bits interface, 2 lines, 5x7 characters
	lcall LCD_command
	mov a, #01H ; Clear screen (Warning, very slow command!)
	lcall LCD_command
	
	
	mov P0MOD, #00000011B ; P0.0, P0.1 are outputs.  P0.1 is used for testing Timer 2!
	setb P0.0
	orl P0MOD, #00111000b ; make all CEs outputs  
    orl P3MOD, #11111111b ; make all CEs outputs 
	orl p0mod,#00001000b
	lcall INI_SPI

    mov TMOD,  #00000001B ; GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
	clr TR0 ; Disable timer 0
	clr TF0
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
    setb TR0 ; Enable timer 0
    setb ET0 ; Enable timer 0 interrupt
    
        
    mov T2CON, #00H ; Autoreload is enabled, work as a timer
    clr TR2
    clr TF2
    ; Set up timer 2 to interrupt every 10ms
    mov RCAP2H,#high(TIMER2_RELOAD)
    mov RCAP2L,#low(TIMER2_RELOAD)
    setb TR2
    setb ET2
    
    mov BCD_count, #0
    mov Cnt_10ms, #0
     
    setb EA  ; Enable all interrupts

M0:			;The pins here will need to be changed depending on what whoever made the board decided to use.
	cpl LEDRA.0
	clr p3.7
	clr CE_ADC
	mov R0,#00000001B ; Start bit:1
	lcall DO_SPI_G
	mov R0,#10000000B ; Single ended, read channel 0
	
	lcall DO_SPI_G
	mov a, R1 ; R1 contains bits 8 and 9
	anl a, #03H ; Make sure other bits are zero
	mov x+1,a
	mov LEDRB, a ; Display the bits
	
	mov R0, #55H ; It doesn't matter what we transmit...
	lcall DO_SPI_G
	mov LEDRA, R1 ; R1 contains bits 0 to 7
	mov x+0,r1
	setb CE_ADC
	lcall WaitHalfSec
	lcall State_Transition
	sjmp M0
	
Update_Display: 
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;			Update the Display for the Clock 
;
;			It also currently displays the variable I'm using for state transitions so its going to jump all over the place
;			Just plug in Seconds instead of State_Seconds and it will work
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	mov dptr, #myLUT
; Display State_Sec 0
    mov A,Seconds
    anl A, #0FH
    movc A, @A+dptr
    mov HEX2, A
; Display State_Sec 1
	mov A,Seconds
    swap A
    anl A, #0FH
    movc A, @A+dptr
    mov HEX3, A	
;Display Minutes 0
	mov A,Minutes
	anl A, #0FH
    movc A, @A+dptr
    mov HEX4, A
;Display Minutes 1
	mov A,Minutes
    swap A
    anl A, #0FH
    movc A, @A+dptr
    mov HEX5, A	
    
    ret
    
INI_SPI:
	orl P0MOD,#00000110b ; Set SCLK, MOSI as outputs
	anl P0MOD,#11111110b ; Set MISO as input
	clr SCLK ; Mode 0,0 default
	ret

DO_SPI_G:
	mov R1,#0 ; Received byte stored in R1
	mov R2,#8 ; Loop counter (8-bits)

DO_SPI_G_LOOP:
	mov a, R0 ; Byte to write is in R0
	rlc a ; Carry flag has bit to write
	mov R0, a
	mov MOSI, c
	setb SCLK ; Transmit
	mov c, MISO ; Read received bit
	mov a, R1 ; Save received bit in R1
	rlc a
	mov R1, a
	clr SCLK
	djnz R2, DO_SPI_G_LOOP
	ret

Correct_Voltage:  ;Turns the LM355 voltage output into the current temperature 100*(Vout-2.73) Vout=(ADC/1023)*5
				  ; For oven reflow project Find out the conversion from the Hot junction and add here
	Load_y(500)
	lcall mul32
	
	Load_y(100)
	lcall mul32
	
	Load_y(1023)
	lcall div32
	
	Load_y(27300)
	lcall sub32 
	
	ret
	
	
State_Transition:  ;Function made to transition states, call it in the main when you want to check the current state/change to another 
			       ; Alternitivly move it into an interupt, im not positive how this is going to function yet.  
	lcall Current_State
	mov a, State ;Moves state into a
	
State0:  ;Functionality for state 0
	cjne a,#0,State1
	mov State_Sec,#0
	mov Pulse,#0
	jb Key.1,Continue_in_State
	jnb Key.1,$
	mov State_Sec,#0
	mov State,#1
	lcall Not_Safe_To_Remove
	ljmp M0
	
State1:  ;Functionality for state 1
	cjne a,#1,State2
	mov Pulse,#100
	mov a,#150
	clr c
	subb a,Temperature
	jnc State1_Abort
	mov State,#2
	ljmp M0

State1_Abort: ;Checks if 60 seconds pass before Thermocouple hits 50 Degrees
	mov a,#60
	clr c
	subb a,State_Sec
	jnc Continue_in_State
	mov state,#5
	ljmp M0

Continue_in_State:  ;The exit state test failed, Machine will continue in current state its in the middle so that its in range of everything
	jb Key.2,Dont_Abort	; Also checks if user wants to cancel the reflow process 
	mov State,#5
Dont_Abort:
	ret
	
		 
State2: ;Functionality for state 2
	cjne a,#2,State3
	mov Pulse,#20
	mov a,#60
	clr c
	subb a,State_Sec
	jnc Continue_in_State
	mov State,#3
	ljmp M0

State3:	;Functionality for state 3
	cjne a,#3,State4
	mov Pulse,#100
	mov State_Sec,#0
	mov a,#220
	clr c
	subb a,Temperature
	jnc Continue_in_State
	mov State,#4
	ljmp M0
	
State4:	;Functionality for state 4
	cjne a,#4,State5
	mov Pulse,#20
	mov a,#45
	clr c
	subb a,State_Sec
	jnc Continue_in_State
	mov State,#4
	ljmp M0
	
State5:	;Functionality for state 5  (State 5 waits to see if temperature is below 60 Degrees to see if its safe to remove 
		;All abort commands revert to state 5 so they can give the oven time to cool down before you pull it out
		;Because The Temperature sensor is not plugged in yet its going to jump from state 5 to 0 instantly
	cjne a,#5,Continue_in_State
	mov Pulse,#0
	mov a,Temperature
	clr c
	subb a,#60
	jnc Continue_in_State
	mov State,#0
	lcall Safe_to_Remove
	ljmp M0

	ret	
END

