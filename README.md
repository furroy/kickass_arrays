
# KickAss Array Macros - Single file macro library for making arrays and zp row lookups inside them.

The file you want is in libs/arrays.asm

## Typical usage:

```
	// setup constants for the array size so can easily change later if needed
	.const BUFFER_WIDTH = 40
	.const BUFFER_MAXROWS = 25

	// allocate an array in memory somewhere
	ScreenDoubleBuffer: AllocateArray(BUFFER_WIDTH * BUFFER_MAXROWS, $00)
	// setup some lookup tables for indexing to the start of each row inside it
	ScreenBufferRowLSB: MakeArrayLookupsLSB(ScreenDoubleBuffer, BUFFER_WIDTH, BUFFER_MAXROWS)
	ScreenBufferRowLSB: MakeArrayLookupsMSB(ScreenDoubleBuffer, BUFFER_WIDTH, BUFFER_MAXROWS)

	// now can do things like find first empty row and fill it
	ArrayFindRow($02, ScreenBufferRowLSB, ScreenBufferRowLSB, $00, $00, BUFFER_MAXROWS)
	cpx #$ff
	beq !+
	ArrayFillCurrentRow($02, BUFFER_WIDTH, $ff)
	!:
```
