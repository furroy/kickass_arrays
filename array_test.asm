
#import "libs/arrays.asm"


* = $c000
TestArray: AllocateArray(100, 32)
// GuardArray(TestArray.pre, TestArray.post)

TestArray2: AllocateArray(100, 32)
// GuardArray(TestArray2.pre, TestArray2.post)


BasicUpstart2(Entry)

Entry:
	// "accidentally" over write pre buffer data. debugger should freeze.
	lda #0
	sta TestArray.pre
	ldx #8
	ldy #2
	ArrayIndexYX($02, ScreenRamLSB, ScreenRamMSB)
	ArrayIndexYX($04, ColorRamLSB, ColorRamMSB)
	lda #$23
	sta ($02), y
	lda #RED
	sta ($04), y
	ldx #5
	ldy #12
	ArrayIndexYX($02, ScreenRamLSB, ScreenRamMSB)
	ArrayIndexYX($04, ColorRamLSB, ColorRamMSB)
	lda #$44
	sta ($02), y
	lda #GREEN
	sta ($04), y
	ldx #5
	ldy #10
	ArrayFillRow($02, ScreenRamLSB, ScreenRamMSB, 40, 23)
	ldx #5
	ldy #20
	ArrayCopyRow($02, ScreenRamLSB, ScreenRamMSB, $04, 40)
	ldx #12
	ArrayCopyIntoRow($02, ScreenRamLSB, ScreenRamMSB, TestRowData, 40)
	// self mod should break when GuardRange() is active!
	lda #4
	sta BREAK + 1
BREAK:
	ldx #4
	ArrayCopyIntoRow($02, ScreenRamLSB, ScreenRamMSB, TestRowData, 40)
	!:
		ArrayFindRow($02, ScreenRamLSB, ScreenRamMSB, 32, 30, 25)
		lda #$46
		sta ($02), y
		jmp !-
__Entry:

GuardRange(Entry, __Entry)

* = $3000
ScreenRamLSB: MakeArrayLookupsLSB($0400, 40, 25)
ScreenRamMSB: MakeArrayLookupsMSB($0400, 40, 25)
ColorRamLSB: MakeArrayLookupsLSB($d800, 40, 25)
ColorRamMSB: MakeArrayLookupsMSB($d800, 40, 25)

TestRowData:
	.text "Hello there from Furroys Test Data!!!"
	.text "                                     "

//* = $0400 "Screen Ram"
//ScreenRam: AllocateArray(1000, 32)
