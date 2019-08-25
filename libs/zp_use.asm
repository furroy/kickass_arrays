
/*
** Experimental ZP address tracker.  Any functions that use a ZP address call ZPU() at the
** start and the ZPX() when finished with it.  It will generate watchpoints for C64
** debugger and halt your application any time under or over allocated.
**
** Just need to set where to place the 256 byte tracking buffer before importing
** .label ZP_BUFFER_LOCATION = 2000
** #import "libs/zp_use.asm"
**
** Ofc if you forget to call ZPX() it will mess up.
*/


#define ZP_TRACKER

#if ZP_TRACKER
	.var @brkFile = createFile("breakpoints.txt")
#endif

.macro ZPU(zp) {
		.if (zp < $02 || zp > $ff) .error "ZPU: First arg must be valid ZP"
#if ZP_TRACKER
		inc [ZP_TRACKING_BUFFER + zp]
#endif
}

.macro ZPX(zp) {
		.if (zp < $02 || zp > $ff) .error "ZPX: First arg must be valid ZP"
#if ZP_TRACKER
		inc [ZP_TRACKING_BUFFER + zp]
#endif
}

#if ZP_TRACKER
* = ZP_BUFFER_LOCATION
	ZP_TRACKING_BUFFER: .fill 256, $00

	.for(var i = ZP_TRACKING_BUFFER; i < ZP_TRACKING_BUFFER + 256; i++) {
		.eval @brkFile.writeln("breakmem " + toHexString(i) + ">=02")
	}
#endif
