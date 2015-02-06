$NOLIST
Read_ADC:
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
	ret

Correct_Temp:  ;Turns the LM355 voltage output into the current temperature 100*(Vout-2.73) Vout=(ADC/1023)*5
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
	
User_Temp: 
	mov a, SWA
	
M0_0:
	cjne a, #1, M0_1
	jb KEY.3, M0_done
	jnb KEY.3, $
	mov a, SWC
	anl a, #02H
	cjne a, #02H, decsoaktemp
	inc soaktemp
	ljmp M0_done
decsoaktemp:
	dec soaktemp
	ljmp M0_done
M0_1:
	cjne a, #2, M0_2
	jb KEY.3, M0_done
	jnb KEY.3, $
	mov a, SWC
	anl a, #02H
	cjne a, #02H, decsoaktime
	inc soaktime
	ljmp M0_done
decsoaktime:
	dec soaktime
	ljmp M0_done
M0_2:
	cjne a, #4, M0_3
	jb KEY.3, M0_done
	jnb KEY.3, $
	mov a, SWC
	anl a, #02H
	cjne a, #02H, decreflowtemp
	inc reflowtemp
	ljmp M0_done
decreflowtemp:
	dec reflowtemp
	ljmp M0_done
M0_3:
	cjne a, #8, M0_done
	jb KEY.3, M0_done
	jnb KEY.3, $
	mov a, SWC
	anl a, #02H
	cjne a, #02H, decreflowtime
	inc reflowtime
	ljmp M0_done
decreflowtime:
	dec reflowtime	
M0_done:
	lcall user0
	ret
$LIST