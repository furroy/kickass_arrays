
/*
** Furroys array macros for making life easier. Supports arrays with width and rows both under 256.
** Most macros are setup around creating a row pointer in ZP for you, so you can then easily manipulate
** data in a given row.
**
** Typical usage:
**
** // setup constants for the array size so can easily change later if needed
** .const BUFFER_WIDTH = 40
** .const BUFFER_MAXROWS = 25
** // allocate an array in memory somewhere
** ScreenDoubleBuffer: AllocateArray(BUFFER_WIDTH * BUFFER_MAXROWS, $00)
** // setup some lookup tables for indexing to the start of each row inside it
** ScreenBufferRowLSB: MakeArrayLookupsLSB(ScreenDoubleBuffer, BUFFER_WIDTH, BUFFER_MAXROWS)
** ScreenBufferRowLSB: MakeArrayLookupsMSB(ScreenDoubleBuffer, BUFFER_WIDTH, BUFFER_MAXROWS)
**
** // now can do things like find first empty row and fill it
** ArrayFindRow($02, ScreenBufferRowLSB, ScreenBufferRowLSB, $00, $00, BUFFER_MAXROWS)
** cpx #$ff
** beq !+
** ArrayFillCurrentRow($02, BUFFER_WIDTH, $ff)
** !:
*/

// comment this out to disable the auto-generated breakpoints
#define MEMORY_GUARD

#if MEMORY_GUARD
.var @brkFile = createFile("breakpoints.txt")
#endif

.macro GuardArray(prelabel, postlabel)
{
#if MEMORY_GUARD
	.eval @brkFile.writeln("breakmem " + toHexString(prelabel) + "<=FF")
	.eval @brkFile.writeln("breakmem " + toHexString(postlabel) + "<=FF")
#endif
}

.macro GuardRange(start, end)
{
#if MEMORY_GUARD
	.for(var i = start; i <= end; i++) {
		.eval @brkFile.writeln("breakmem " + toHexString(i) + "<=FF")
	}
#endif
}

// Define and fill an array with default values. You must define a label before calling this macro!
// Example  ScreenBuffer: AllocateArray(40 * 25, $00)
.macro AllocateArray(length, defaultValue) {
#if MEMORY_GUARD
		.label pre = *
		.byte $bb
#endif
		.label actual = *
		.fill length, defaultValue
#if MEMORY_GUARD
		.label post = *
		.byte $bb
		GuardArray(pre, post)
		// i thought maybe if i set the address back the root label would have the correct value
		// but instead triggers memory overrite error
		// * = actual
#endif
}

// Generate LSB lookup table for an array. You must define a label before calling this macro!
// Example  ScreenBufferRowLSB: MakeArrayLookupsLSB(ScreenBuffer, 40, 25)
.macro MakeArrayLookupsLSB(start, width, length) {
		.fill length, <[start + i * width ]
}

// Generate MSB lookup table for an array. You must define a label before calling this macro!
// Example  ScreenBufferRowLSB: MakeArrayLookupsMSB(ScreenBuffer, 40, 25)
.macro MakeArrayLookupsMSB(start, width, length) {
	.fill length, >[start + i * width ]
}

// Setup a zp address with pointer to start of a row.
// X is the row and you can then use Y as the column (backwards i know...)
// sets up ZP pointer you pass in, so you can either lda (zp), y or sta (zp), y to access columns
// lobyte & hibyte are the labels to the lookup tables you define for this array
.macro ArrayIndexYX(zp, lobyte, hibyte) {
	.if (zp < $02 || zp > $ff) .error "ArrayIndexYX: First arg must be valid ZP"
	lda lobyte, x
	sta zp
	lda hibyte, x
	sta [zp + 1]
}

// zp address to use, lo & hi bytes of array, value to search for, byteOffset is which byte in each record to test (usually 0),
// and max number of rows to search, on return X is the row or #$ff if not found.  zp will hold the start of the row
.macro ArrayFindRow(zp, lobyte, hibyte, searchTerm, byteOffset, maxRows) {
		ldx #0
		ldy #byteOffset
	!Loop:
		ArrayIndexYX(zp, lobyte, hibyte)
		lda (zp), y
		cmp #searchTerm
		beq !Found+
		inx
		cpx #maxRows
		bne !Loop-
		ldx #$ff
	!Found:
}

// can call this if you've already called ArrayIndexYX(zp, lobyte, hibyte) previously
// otherwise use ArrayFillRow() macro
.macro ArrayFillCurrentRow(zp, width, fillValue)
{
	.if (zp < $02 || zp > $ff)  .error "ArrayIndexYX: zp arg must be valid ZP"
	!Loop:
		lda #fillValue
		sta (zp), y
		iny
		cpy #width
		bne !Loop-
}

// X is the row and Y is the column (backwards i know...) sets up ZP pointer.
// Y doesn't have to be 0 if you want to fill only the last part of a row
// It will stop when width element is reached so it won't accidentally write into next row
.macro ArrayFillRow(zp, lobyte, hibyte, width, fillValue)
{
		ArrayIndexYX(zp, lobyte, hibyte)
		ArrayFillCurrentRow(zp, width, fillValue)
}

// Copy one row X of the array into another Y. Does not check to see if X & Y are the same!
// X is the row number of source row, Y is the row number of the dest row
// NOTE: This is non-standard usage of Y, is is not column like most other functions
.macro ArrayCopyRow(src, lobyte, hibyte, dest, width)
{
		.if (src < $02 || src > $ff)  .error "ArrayIndexYX: Source arg must be valid ZP"
		.if (dest < $02 || dest > $ff)  .error "ArrayIndexYX: Dest arg must be valid ZP"
		.if (abs(src - dest) < 2) .error "ArrayIndexYX: Source arg must not overlap Dest"
		// save Y for later
		tya
		pha
		ArrayIndexYX(src, lobyte, hibyte)
		// restore Y so we can use as X for dest row
		pla
		tax
		ArrayIndexYX(dest, lobyte, hibyte)
		// now loop over and copy every column
		ldy #0
	!Loop:
		lda (src), y
		sta (dest), y
		iny
		cpy #width
		bne !Loop-
}

// Use this version if you've already called ArrayIndexYX(zp, lobyte, hibyte) to setup row pointer
.macro ArrayCopyIntoCurrentRow(zp, src, width)
{
		.if (zp < $02 || zp > $ff)  .error "ArrayIndexYX: zp arg must be valid ZP"
		ldy #0
	!Loop:
		lda src, y
		sta (zp), y
		iny
		cpy #width
		bne !Loop-
}

// Copy a row from any address in memory outside of the array
.macro ArrayCopyIntoRow(zp, lobyte, hibyte, src, width)
{
		ArrayIndexYX(zp, lobyte, hibyte)
		ArrayCopyIntoCurrentRow(zp, src, width)
}
