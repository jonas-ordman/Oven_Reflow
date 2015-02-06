$NOLIST
;For a 33.33MHz clock, one cycle takes 30ns
WaitHalfSec:
	mov R2, #90
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1
	djnz R1, L2
	djnz R2, L3
	ret
Small_Delay:
	mov R2, #40
L6: mov R1, #40
L5: mov R0, #140
L4: djnz R0, L4
	djnz R1, L5
	djnz R2, L6
	ret
	
$LIST