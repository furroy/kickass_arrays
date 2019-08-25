

.label ZP_BUFFER_LOCATION = $2000

#import "libs/zp_use.asm"

BasicUpstart2(Entry)

Entry:
	ZPU($02)
	jsr Blowup
	ZPX($02)
	jsr Blowup2
	jmp Entry


Blowup:
	ZPU($02)
	rts

Blowup2:
	ZPX($03)
	rts
