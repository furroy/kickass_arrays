

.label ZP_BUFFER_LOCATION = $2000
#define ZP_TRACKER

#import "libs/zp_use.asm"

BasicUpstart2(Entry)

Entry:
	ZPU($04)
	jsr Blowup
	ZPX($04)
	jsr Blowup2
	jmp Entry


Blowup:
	ZPU($02)
	jsr Blowup2
	ZPX($02)
	rts

Blowup2:
	ZPU($04)
	ZPX($04)
	rts
