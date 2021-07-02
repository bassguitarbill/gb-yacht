INCLUDE "hardware.inc"

SECTION "vblank",ROM0[$40]
    jp VBlankHandler

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

; This apparently gets fixed by rgbfix
REPT $150 - $104
	db 0
ENDR

PIP_FIELD_0 EQU %00000000 ;   _         _
PIP_FIELD_1 EQU %00001000 ;  |           |
PIP_FIELD_2 EQU %01000001 ;      1   2
PIP_FIELD_3 EQU %01001001 ;  |   3 4 5   |
PIP_FIELD_4 EQU %01100011 ;      6   7
PIP_FIELD_5 EQU %01101011 ;  |_         _|
PIP_FIELD_6 EQU %01110111 ;

DIE_1_VALUE EQU $FF80
DIE_2_VALUE EQU $FF81
DIE_3_VALUE EQU $FF82
DIE_4_VALUE EQU $FF83
DIE_5_VALUE EQU $FF84

BUTTONS_PRESSED EQU $FF85
BUTTON_DIFF EQU $FF86

CURRENTLY_SELECTED_DIE EQU $FF87

ONES_COUNT 			EQU $FF90
TWOS_COUNT 			EQU $FF91
THREES_COUNT 		EQU $FF92
FOURS_COUNT 		EQU $FF93
FIVES_COUNT 		EQU $FF94
SIXES_COUNT 		EQU $FF95
EXIST_BITFIELD 	EQU $FF96

ONES_SCORE				EQU $FFA0
TWOS_SCORE				EQU $FFA1
THREES_SCORE			EQU $FFA2
FOURS_SCORE				EQU $FFA3
FIVES_SCORE				EQU $FFA4
SIXES_SCORE				EQU $FFA5
UPPER_HALF_SCORE	EQU $FFA6

FULL_HOUSE_SCORE			EQU $FFA8
SMALL_STRAIGHT_SCORE	EQU $FFA9
LARGE_STRAIGHT_SCORE	EQU $FFAA
THREE_OF_A_KIND_SCORE	EQU $FFAB
FOUR_OF_A_KIND_SCORE	EQU $FFAC
YACHT_SCORE						EQU $FFAD
CHANCE_SCORE					EQU $FFAE

SCORE_IS_STALE				EQU $FFAF

CURSOR_SPRITE	equ	_OAMRAM


SECTION "Game code", ROM0

Start:
.waitVBlank
	ld a, [rLY]
	cp 144
	jr c, .waitVBlank

	xor a
	ld [rLCDC], a

	ld hl, _VRAM8000
	ld de, Tiles
	ld bc, TilesEnd - Tiles

.copyTiles
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .copyTiles

.clearOAM
	xor a
	ld hl, _OAMRAM
	ld c, $9F
.clearSprite
	ld [hli], a
	dec c
	jr nz, .clearSprite

.initScoreDisplay
	ld hl, $9941
	ld a, $1F
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a

	ld hl, $9961
	ld a, $22
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a

	ld hl, $9981
	ld a, $25
	ld [hli], a
	inc a
	ld [hli], a
	ld a, $21
	ld [hli], a

	ld hl, $99A1
	ld a, $27
	ld [hli], a
	ld a, $29
	ld [hli], a
	inc a
	ld [hli], a

	ld hl, $99C1
	ld a, $2B
	ld [hli], a
	inc a
	ld [hli], a
	ld a, $21
	ld [hli], a

	ld hl, $99E1
	ld a, $2D
	ld [hli], a
	inc a
	ld [hli], a
	ld a, $21
	ld [hli], a

	
	ld hl, $9948
	ld a, $2F
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	inc a
	ld [hli], a

	ld hl, $9968
	ld a, $34
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a

	ld hl, $9988
	ld a, $38
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	ld a, $37
	ld [hli], a

	ld hl, $99A6
	ld a, $3B
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a

	ld hl, $99C6
	ld a, $41
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	ld a, $3E
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a

	ld hl, $99E9
	ld a, $44
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a

	ld hl, $9A08
	ld a, $47
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a

.initCursorSprite
	ld hl, _OAMRAM
	ld a, 39  ; y
	ld [hli], a
	ld a, 16   ; x
	ld [hli], a
	ld a, $4B ; sprite index
	ld [hli], a
	ld a, %00001000
	ld [hli], a

.exampleInitCode
	ld hl, DIE_1_VALUE
	ld a, 2
	ld [hli], a
	ld a, 2
	ld [hli], a
	ld a, 2
	ld [hli], a
	ld a, 4
	ld [hli], a
	ld a, 4
	ld [hli], a

	xor a
	ld [BUTTONS_PRESSED], a

	ld a, 1
	ld [SCORE_IS_STALE], a
	ld [CURRENTLY_SELECTED_DIE], a

	; init display!
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a

	xor a
	ld [rSCY], a
	ld [rSCX], a

	; no sound
	ld [rNR52], a

	; screen, sprites, and bg on
	ld a, %10010011
	ld [rLCDC], a

	ld a, $0F ; Interrupts on
	ld [$ffff], a
	 

.lockup
	ei
	halt 
	jr .lockup

; +---------------------------------------------------------+
; |                                                         |
; |                      GAME LOOP                          |
; |                                                         |
; +---------------------------------------------------------+

VBlankHandler:
	di
	call .getInput
	call .handleInput
	call .calculateScore
	;call .drawDice
	call .displayScore
	ei
	reti

.getInput
	ld hl, _IO
	ld a, %00010000 ; direction buttons
	ld [hl], a
	ld a, [hl]
	ld a, [hl]
	ld a, [hl]
	ld a, [hl]
	ld a, [hl] 	; okay okay he's had enough
	cpl 				; 1 means 'pressed'
	and $0F			; blank out unused buttons
	swap a			; put buttons in the bottom nybble
	ld b, a			; store it

	ld a, %00100000 ; direction buttons
	ld [hl], a
	ld a, [hl]
	ld a, [hl]
	ld a, [hl]
	ld a, [hl]
	ld a, [hl]
	cpl 				; 1 means 'pressed'
	and $0F			; blank out unused buttons
	or b

	ld b, a									; b = current frame
	ld a, [BUTTONS_PRESSED] ; a = last frame
	xor b										; a = diff from last frame
	and b										; a = buttondown this frame

	;xor a
	ld [BUTTON_DIFF], a
	ld a, b
	ld [BUTTONS_PRESSED], a
	reti

.handleInput
	ld a, [BUTTON_DIFF]
	cp 1
	jr z, .nextDie
	cp 2
	jr z, .prevDie
	cp 4
	jr z, .increaseCurrentDie
	cp 8
	jr z, .decreaseCurrentDie
	jr .doneWithInput

.nextDie
	ld a, [CURRENTLY_SELECTED_DIE]
	inc a
	cp 6
	jr nz, .noNextDieOverflow
	ld a, 1
.noNextDieOverflow
	ld [CURRENTLY_SELECTED_DIE], a
	call .drawCursor
	jr .doneWithInput

.prevDie
	ld a, [CURRENTLY_SELECTED_DIE]
	dec a
	cp 0
	jr nz, .noPrevDieUnderflow
	ld a, 5
.noPrevDieUnderflow
	ld [CURRENTLY_SELECTED_DIE], a
	call .drawCursor
	jr .doneWithInput

.increaseCurrentDie
	ld a, 1
	ld [SCORE_IS_STALE], a
	ld a, [CURRENTLY_SELECTED_DIE]
	ld hl, $FF7F ; Right before the dice values start
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]   ; Should be the value of the selected die
	inc a
	cp 7
	jr nz, .noIncreaseCurrentDieOverflow
	ld a, 1
.noIncreaseCurrentDieOverflow
	ld [hl], a
	ld a, [CURRENTLY_SELECTED_DIE]
	call .drawDieIndex
	jr .doneWithInput

.decreaseCurrentDie
	ld a, 1
	ld [SCORE_IS_STALE], a
	ld a, [CURRENTLY_SELECTED_DIE]
	ld hl, $FF7F ; Right before the dice values start
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]   ; Should be the value of the selected die
	dec a
	cp 0
	jr nz, .noDecreaseCurrentDieOverflow
	ld a, 6
.noDecreaseCurrentDieOverflow
	ld [hl], a
	ld a, [CURRENTLY_SELECTED_DIE]
	call .drawDieIndex
	jr .doneWithInput

.doneWithInput
	reti

.drawDice
	ld   hl, $FF41     ; STAT Register
.drawDiceWait
  ld a, [hl]       ; Wait until Mode is 0 or 1
	and $01
	cp $01
	jr   nz, .drawDiceWait

	ld hl, DIE_1_VALUE
	ld a, [hl]
	ld d, a
	ld b, 2
	ld c, 2
	call .drawDie

	ld hl, DIE_2_VALUE
	ld a, [hl]
	ld d, a
	ld b, 6
	ld c, 2
	call .drawDie

	ld hl, DIE_3_VALUE
	ld a, [hl]
	ld d, a
	ld b, 10
	ld c, 2
	call .drawDie

	ld hl, DIE_4_VALUE
	ld a, [hl]
	ld d, a
	ld b, 4
	ld c, 6
	call .drawDie

	ld hl, DIE_5_VALUE
	ld a, [hl]
	ld d, a
	ld b, 8
	ld c, 6
	call .drawDie

	reti

; a - which die to draw (1 through 5)
.drawDieIndex
	ld d, a ; save the die for later
	ld hl, DicePosition ; Load into the dice position data
	ld b, 0
	ld c, a	; half of index into dice position data 
	sla c ; Each position is 2 bytes
	add hl, bc ; correct X is now in [hl]
	ld a, [hli]
	ld b, a			; b contains X
	ld a, [hl]
	ld c, a    	; c contains Y
	ld a, d

	ld hl, $FF7F
	ld d, 0
	ld e, a
	add hl, de
	ld a, [hl]
	ld d, a ; d contains the dice value
	call .drawDie
	reti


; draw die - draws a die to the screen on the background layer
; args
;		b - the x-coordinate of the top-left corner of the die
;		c - the y-coordinate of the top-left corner of the die
; 	d - the face of the die to draw, from 1 to 6

.drawDie
	ld hl, _SCRN0 ; point to the top left of the screen
	ld a, b
	or 0
.moveRight
	jr z, .prepareToMoveDown
	inc hl
	dec a
	jr .moveRight
.prepareToMoveDown
	ld a, c
	or 0
	ld bc, $20 ; This is one row worth of movement
.moveDown
	jr z, .doneMovingDown
	add hl, bc 
	dec a
	jr .moveDown
.doneMovingDown ; hl is now in the correct place
	; time to load the correct pip field
	ld e, PIP_FIELD_1
	dec d
	jr z, .pipFieldLoaded
	ld e, PIP_FIELD_2
	dec d
	jr z, .pipFieldLoaded
	ld e, PIP_FIELD_3
	dec d
	jr z, .pipFieldLoaded
	ld e, PIP_FIELD_4
	dec d
	jr z, .pipFieldLoaded
	ld e, PIP_FIELD_5
	dec d
	jr z, .pipFieldLoaded
	ld e, PIP_FIELD_6
	dec d
	jr z, .pipFieldLoaded
.pipFieldLoaded ; into register E
	ld bc, $1E ; This is one row down and two tiles left

	; top left
	ld a, $50
	bit 6, e
	jr z, .pipTopLeft
	ld a, $59
.pipTopLeft
	ld [hli], a

	; top middle
	ld a, $51
	ld [hli], a

	; top right
	ld a, $52
	bit 5, e
	jr z, .pipTopRight
	ld a, $5A
.pipTopRight
	ld [hl], a

	; down a line
	add hl, bc

	; middle left
	ld a, $53
	bit 4, e
	jr z, .pipMiddleLeft
	ld a, $5B
.pipMiddleLeft
	ld [hli], a

	; middle
	ld a, $54
	bit 3, e
	jr z, .pipMiddle
	ld a, $5C
.pipMiddle
	ld [hli], a

	; middle right
	ld a, $55
	bit 2, e
	jr z, .pipMiddleRight
	ld a, $5D
.pipMiddleRight
	ld [hl], a

	; down a line
	add hl, bc

	; bottom left
	ld a, $56
	bit 1, e
	jr z, .pipBottomLeft
	ld a, $5E
.pipBottomLeft
	ld [hli], a

	; bottom middle
	ld a, $57
	ld [hli], a

	; bottom right
	ld a, $58
	bit 0, e
	jr z, .pipBottomRight
	ld a, $5F
.pipBottomRight
	ld [hl], a
	reti

; loads the currently-selected die from memory
; and draws the sprite cursor in the correct
; location to point to that die
.drawCursor
	ld a, [CURRENTLY_SELECTED_DIE]
	ld hl, CursorDicePosition
	ld b, 0
	ld c, a
	sla c
	add hl, bc
	ld a, [hli]
	ld b, a ; b = y position
	ld a, [hl]
	ld c, a ; c = x position

	ld hl, CURSOR_SPRITE
	ld a, b
	ld [hli], a
	ld a, c
	ld [hl], a

	reti


.calculateScore
	; check for staleness
	ld a, [SCORE_IS_STALE]
	and 1
	jr nz, .stale
	reti 
.stale

	; clear the count registers
	xor a
	ld hl, ONES_COUNT
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

	; clear the score registers
	ld hl, ONES_SCORE
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a

	ld a, [DIE_1_VALUE]
	call .addSingleDieToCount
	ld a, [DIE_2_VALUE]
	call .addSingleDieToCount
	ld a, [DIE_3_VALUE]
	call .addSingleDieToCount
	ld a, [DIE_4_VALUE]
	call .addSingleDieToCount
	ld a, [DIE_5_VALUE]
	call .addSingleDieToCount

	xor a
	ld c, a ; chance
	ld d, a ; max count
	ld e, a ; count has a non-full-house number in it

	; all of the count fields are now populated
	ld hl, ONES_SCORE
	ld a, [ONES_COUNT]
	call .checkCountForNonFullHouseNumber
	ld d, a ; automatically the highest count so far
	ld [hli], a
	ld c, a

	ld a, [TWOS_COUNT]
	call .checkCountForNonFullHouseNumber
	cp d
	jr c, .twoIsNotHighestCount
	ld d, a
.twoIsNotHighestCount
	sla a ; multiply by 2
	ld [hli], a
	add c
	ld c, a

	ld a, [THREES_COUNT]
	call .checkCountForNonFullHouseNumber
	cp d
	jr c, .threeIsNotHighestCount
	ld d, a
.threeIsNotHighestCount
	ld b, a
	sla a
	add b
	ld [hli], a
	add c
	ld c, a

	ld a, [FOURS_COUNT]
	call .checkCountForNonFullHouseNumber
	cp d
	jr c, .fourIsNotHighestCount
	ld d, a
.fourIsNotHighestCount
	sla a
	sla a
	ld [hli], a
	add c
	ld c, a

	ld a, [FIVES_COUNT]
	call .checkCountForNonFullHouseNumber
	cp d
	jr c, .fiveIsNotHighestCount
	ld d, a
.fiveIsNotHighestCount
	ld b, a
	sla a
	sla a
	add b
	ld [hli], a
	add c
	ld c, a

	ld a, [SIXES_COUNT]
	cp d
	jr c, .sixIsNotHighestCount
	call .checkCountForNonFullHouseNumber
	ld d, a
.sixIsNotHighestCount
	ld b, a
	sla a
	add b
	sla a
	ld [hli], a
	add c

	ld [CHANCE_SCORE], a

	ld c, a  ; chance
	
	ld a, d ; load in the max count
	cp 3 ; carry is set if a is 1 or 2
	jr c, .doneWithMax
	ld a, c
	ld [THREE_OF_A_KIND_SCORE], a
	ld a, d
	cp 4
	jr c, .doneWithMax
	ld a, c
	ld [FOUR_OF_A_KIND_SCORE], a
	ld a, d
	cp 5
	jr c, .doneWithMax
	ld a, 50
	ld [YACHT_SCORE], a
.doneWithMax

	; full house
	xor a
	add e ; zero flag is set if e is 0 and therefore there is a full house
	ld e, 25 ; full house points
	jr z, .doneWithFullHouse
	ld e, 0
.doneWithFullHouse
	ld a, e
	ld [FULL_HOUSE_SCORE], a


	ld c, 30 ; little straight points
	ld d, 40 ; large straight points
	ld a, [EXIST_BITFIELD] ; check for straights
	ld b, a
	and %01111100 ; 1 2 3 4 5
	cp  %01111100
	jr z, .gotAStraight
	ld a, b
	and %00111110 ; 2 3 4 5 6
	cp  %00111110
	jr z, .gotAStraight
	ld d, 0 ; if there is a straight, it isn't large

	ld a, b
	and %01111000 ; 1 2 3 4
	cp  %01111000
	jr z, .gotAStraight
	ld a, b
	and %00111100 ; 2 3 4 5
	cp  %00111100
	jr z, .gotAStraight
	ld a, b
	and %00011110 ; 3 4 5 6
	cp  %00011110
	jr z, .gotAStraight
	ld c, 0 ; no straights
.gotAStraight
	ld a, c
	ld [SMALL_STRAIGHT_SCORE], a
	ld a, d
	ld [LARGE_STRAIGHT_SCORE], a

	xor a
	ld [SCORE_IS_STALE], a

	reti

; a - count of current die
; b - work register
; e - non-full house flag
.checkCountForNonFullHouseNumber
	ld b, a
	xor a
	add e ; sets zero flag if the non-full house flag is indeed zero 
	jr z, .checkCountForReal
	ld a, b
	reti
.checkCountForReal
	ld a, b
	cp 1
	jr z, .nonFullHouseNumberFound
	cp 4
	jr z, .nonFullHouseNumberFound
	cp 5                           ;; comment these two lines out
	jr z, .nonFullHouseNumberFound ;; if yachts should count as full houses

	reti 
.nonFullHouseNumberFound
	ld e, 1
	reti 


; a - dice value
.addSingleDieToCount
	ld b, %10000000 ; Rotating this bit right until it stops in bit=dice value

	ld hl, ONES_COUNT
	srl b
	dec a
	jr z, .countRegisterSelected ;; PLEASE OPTIMIZE THIS
	inc hl
	srl b
	dec a
	jr z, .countRegisterSelected
	inc hl
	srl b
	dec a
	jr z, .countRegisterSelected
	inc hl
	srl b
	dec a
	jr z, .countRegisterSelected
	inc hl
	srl b
	dec a
	jr z, .countRegisterSelected
	inc hl
	srl b
.countRegisterSelected
	inc [hl]
	ld a, [EXIST_BITFIELD]
	or a, b
	ld [EXIST_BITFIELD], a

	reti

.displayScore
	ld   hl, $FF41     ; STAT Register
.wait
  ld a, [hl]       ; Wait until Mode is 0 or 1
	and $01
	cp $01
	jr   nz, .wait

	ld bc, $20
	ld hl, $9944
	ld a, [ONES_SCORE]
	ld [hl], a

	add hl, bc
	ld a, [TWOS_SCORE]
	ld [hl], a

	add hl, bc
	ld a, [THREES_SCORE]
	ld [hl], a
	add hl, bc
	ld a, [FOURS_SCORE]
	ld [hl], a

	add hl, bc
	ld a, [FIVES_SCORE]
	ld [hl], a

	add hl, bc
	ld a, [SIXES_SCORE]
	ld [hl], a

	ld hl, $994C
	ld a, [FULL_HOUSE_SCORE]
	ld [hl], a

	add hl, bc
	ld a, [THREE_OF_A_KIND_SCORE]
	ld [hl], a

	add hl, bc
	ld a, [FOUR_OF_A_KIND_SCORE]
	ld [hl], a

	add hl, bc
	ld a, [SMALL_STRAIGHT_SCORE]
	ld [hl], a

	add hl, bc
	ld a, [LARGE_STRAIGHT_SCORE]
	ld [hl], a

	add hl, bc
	ld a, [YACHT_SCORE]
	ld [hl], a

	add hl, bc
	ld a, [CHANCE_SCORE]
	ld [hl], a
	
	reti 

SECTION "Tiles", ROM0

Tiles:
INCBIN "tiles.2bpp"
TilesEnd:

SECTION "Dice", ROM0

DicePosition:
	DB 0, 0		; 0th die
	DB 2, 2		; 1st die
	DB 6, 2		; 2nd die
	DB 10, 2	; 3rd die
	DB 4, 6		; 4th die
	DB 8 ,6		; 5th die
	
SECTION "Cursor", ROM0

CursorDicePosition:
	DB 0, 0 	; 0th die
	DB 39, 16	; 1st die
	DB 39, 48	; 2nd die
	DB 39, 80	; 3rd die
	DB 71, 32	; 4th die
	DB 71, 64	; 5th die