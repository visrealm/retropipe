GOTO main

include "vdp-utils.bas"
include "input.bas"

#fontTable:
    DATA $0100, $0900, $1100

CONST PLAYFIELD_X = 5
CONST PLAYFIELD_Y = 3
CONST PLAYFIELD_WIDTH = 9
CONST PLAYFIELD_HEIGHT = 7

CONST CHUTE_X = 1
CONST CHUTE_Y = 3
CONST CHUTE_SIZE = 5

CONST CELL_GRID      = 0
CONST CELL_BASE      = 1
CONST CELL_PIPE_H    = 2
CONST CELL_PIPE_V    = 3
CONST CELL_PIPE_X    = 4
CONST CELL_PIPE_DR   = 5
CONST CELL_PIPE_DL   = 6
CONST CELL_PIPE_UR   = 7
CONST CELL_PIPE_UL   = 8
CONST CELL_PIPE_ST   = 9
CONST CELL_FILL_H    = 10	' bit 3 (8) set
CONST CELL_FILL_V    = 11
CONST CELL_FILL_XH   = 12
CONST CELL_FILL_XV   = 13
CONST CELL_FILL_XX   = 14
CONST CELL_FILL_DR   = 15
CONST CELL_FILL_DL   = 16
CONST CELL_FILL_UR   = 17
CONST CELL_FILL_UL   = 18

' tile definition
' appearance
' paths
CONST PIPE_LEFT   = 0
CONST PIPE_TOP    = 1
CONST PIPE_RIGHT  = 2
CONST PIPE_BOTTOM = 3

CONST FLOW_RIGHT  = 1
CONST FLOW_DOWN   = 2
CONST FLOW_LEFT   = 4
CONST FLOW_UP     = 8

CONST ANIM_FLOW_NONE       = 0
CONST ANIM_FLOW_RIGHT      = (FLOW_RIGHT * 16) OR FLOW_RIGHT
CONST ANIM_FLOW_DOWN       = (FLOW_DOWN * 16) OR FLOW_DOWN
CONST ANIM_FLOW_LEFT       = (FLOW_LEFT * 16) OR FLOW_LEFT
CONST ANIM_FLOW_UP         = (FLOW_UP * 16) OR FLOW_UP
CONST ANIM_FLOW_RIGHT_UP   = (FLOW_RIGHT * 16) OR FLOW_UP
CONST ANIM_FLOW_RIGHT_DOWN = (FLOW_RIGHT * 16) OR FLOW_DOWN
CONST ANIM_FLOW_DOWN_LEFT  = (FLOW_DOWN * 16) OR FLOW_LEFT
CONST ANIM_FLOW_DOWN_RIGHT = (FLOW_DOWN * 16) OR FLOW_RIGHT
CONST ANIM_FLOW_LEFT_UP    = (FLOW_LEFT * 16) OR FLOW_UP
CONST ANIM_FLOW_LEFT_DOWN  = (FLOW_LEFT * 16) OR FLOW_DOWN
CONST ANIM_FLOW_UP_LEFT    = (FLOW_UP * 16) OR FLOW_LEFT
CONST ANIM_FLOW_UP_RIGHT   = (FLOW_UP * 16) OR FLOW_RIGHT
CONST ANIM_FLOW_INVALID    = $ff

CONST SUBTILE_TL = 0
CONST SUBTILE_TC = 1
CONST SUBTILE_TR = 2
CONST SUBTILE_ML = 32
CONST SUBTILE_MC = 33
CONST SUBTILE_MR = 34
CONST SUBTILE_BL = 64
CONST SUBTILE_BC = 65
CONST SUBTILE_BR = 66


tileHorz:
	DATA BYTE CELL_PIPE_H
	DATA BYTE FLOW_LEFT OR FLOW_RIGHT	' entry
	DATA BYTE ANIM_FLOW_RIGHT
	DATA BYTE ANIM_FLOW_INVALID
	DATA BYTE ANIM_FLOW_LEFT
	DATA BYTE ANIM_FLOW_INVALID

tileVert:
	DATA BYTE CELL_PIPE_V
	DATA BYTE FLOW_UP OR FLOW_DOWN
	DATA BYTE ANIM_FLOW_INVALID
	DATA BYTE ANIM_FLOW_DOWN
	DATA BYTE ANIM_FLOW_INVALID
	DATA BYTE ANIM_FLOW_UP

tileCross:
	DATA BYTE CELL_PIPE_X
	DATA BYTE FLOW_LEFT OR FLOW_RIGHT OR FLOW_UP OR FLOW_DOWN
	DATA BYTE ANIM_FLOW_NONE	' no centre animation for horizontals
	DATA BYTE ANIM_FLOW_DOWN
	DATA BYTE ANIM_FLOW_NONE    ' no centre animation for horizontals
	DATA BYTE ANIM_FLOW_UP

tileDR:
	DATA BYTE CELL_PIPE_DR
	DATA BYTE FLOW_LEFT OR FLOW_UP
	DATA BYTE ANIM_FLOW_INVALID
	DATA BYTE ANIM_FLOW_INVALID
	DATA BYTE ANIM_FLOW_LEFT_DOWN
	DATA BYTE ANIM_FLOW_UP_RIGHT


' cell-id
' inlets	1 << PILE_LEFT | 1 << PIPE_RIGHT
' paths - 4 entries for each path
' 
' 0: centre tile anim
' 1: $ff	<-- lose
' 2: centre tile anim
' 3: centre tile anim

' game state
' currentIndex into game()
' currentSubTile 
' currentAnim
' animIncrement - increments every X frames
' animIndex = animIncrement AND 0x07
'

DIM chute(6)
DIM game(PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT)
DIM #score
DIM chuteOffset
DIM gameState

main:
    ' what are we working with?
    GOSUB vdpDetect
	VDP_ENABLE_INT_DISP_OFF

	VDP_REG(50) = $80  ' reset VDP registers to boot values
	VDP_REG(7) = defaultReg(7)
	VDP_REG(0) = defaultReg(0)  ' VDP_REG() doesn't accept variables, so...
	VDP_REG(1) = defaultReg(1)
	VDP_REG(2) = defaultReg(2)
	VDP_REG(3) = defaultReg(3)
	VDP_REG(4) = defaultReg(4)
	VDP_REG(5) = defaultReg(5)
	VDP_REG(6) = defaultReg(6)

	FOR I = 0 TO 2
        DEFINE VRAM PLETTER #fontTable(I), $300, font
    NEXT I

	FOR I = 0 TO FRAME
		chute(0) = RANDOM(I)
	NEXT I
	
	VDP_DISABLE_INT

	FOR I = 0 TO CHUTE_SIZE - 1
		chute(I) = RANDOM(7) + 2
	NEXT I

    DEFINE CHAR 0, 24, logo

    DEFINE CHAR 128, 30, grid
    DEFINE COLOR 128, 18, gridColor
	FOR I = 137 TO 175
	    DEFINE COLOR I, 1, baseColor
	NEXT I
    DEFINE CHAR 158, 10, pipes	' empty pipes
    DEFINE CHAR 168, 10, pipes	' full pipes

    DEFINE CHAR 178, 7, borders

	FOR I = 158 TO 167
	    DEFINE COLOR I, 1, pipeColor
	NEXT I
	FOR I = 168 TO 177
	    DEFINE COLOR I, 1, pipeColorGreen
	NEXT I

	DEFINE VRAM NAME_TAB_XY(0, 0), 12, logoNamesTop
	DEFINE VRAM NAME_TAB_XY(0, 1), 12, logoNamesBottom

	FOR I = 0 TO 31
		PUT_XY(I, 2), 184
	NEXT I
	FOR I = PLAYFIELD_Y TO PLAYFIELD_Y + CHUTE_SIZE * 3 - 1
		DEFINE VRAM NAME_TAB_XY(0, I), 5, chuteNames
	NEXT I
	DEFINE VRAM NAME_TAB_XY(0, PLAYFIELD_Y + CHUTE_SIZE * 3), 5, chuteBottomNames
	FOR I = PLAYFIELD_Y + CHUTE_SIZE * 3 + 1 TO 23
		PUT_XY(4, I), 183
	NEXT I

	DEFINE SPRITE 0, 8, selSprites

	cursorX = 4
	cursorY = 3
	#score = 0

	PRINT AT XY(20,0), "LEVEL: 1"
	PRINT AT XY(20,1), "SCORE: ", <5>#score

	chuteOffset = 20

	FOR I = 0 TO PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH - 1
		game(I) = CELL_GRID
	NEXT I
	game(32) = CELL_PIPE_ST

	FOR g_cell = 0 TO PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT - 1
		g_type = game(g_cell)
		GOSUB renderGameCell
	NEXT g_cell

	gameState = 1
	VDP_ENABLE_INT

	WHILE 1
		WAIT
		GOSUB updateNavInput
		IF g_nav > 0 AND delayFrames > 0 THEN
			delayFrames = delayFrames - 1
		ELSE
			GOSUB uiTick
		END IF
	WEND

uiTick: PROCEDURE
	VDP_DISABLE_INT

	delayFrames = 8
	IF NAV(NAV_RIGHT) AND cursorX < (PLAYFIELD_WIDTH - 1) THEN
		cursorX = cursorX + 1
	ELSEIF NAV(NAV_LEFT) AND cursorX > 0 THEN
		cursorX = cursorX - 1
	ELSEIF NAV(NAV_DOWN) AND cursorY < (PLAYFIELD_HEIGHT - 1) THEN
		cursorY = cursorY + 1
	ELSEIF NAV(NAV_UP) AND cursorY > 0 THEN
		cursorY = cursorY - 1
	ELSEIF NAV(NAV_OK) THEN
		IF game(currentIndex) > 0 THEN
			#score = #score - 50
		ELSE
			#score = #score + 100
		END IF
		if #score > 65485 then #score = 0

		game(currentIndex) = chute(CHUTE_SIZE - 1)
		g_cell = currentIndex
		g_type = game(currentIndex)
		GOSUB renderGameCell
		FOR I = CHUTE_SIZE - 1 TO 1 STEP - 1
			chute(I) = chute(I-1)
		NEXT I
		chute(0) = RANDOM(7) + 2
		g_cell = CHUTE_SIZE - 1
		g_type = 1
		GOSUB renderChuteCell 
		chuteOffset = 4
		PRINT AT XY(20,1), "SCORE: ", <5>#score
	ELSE
		delayFrames = 0
	END IF

	IF chuteOffset > 0 THEN
		chuteOffset = chuteOffset - 1
		GOSUB renderChute
	END IF

	GOSUB setCursor

	VDP_ENABLE_INT
	END


renderChute: PROCEDURE
	FOR I = 0 TO CHUTE_SIZE - 1
		g_cell = I
		g_type = chute(I)
		GOSUB renderChuteCell
	NEXT I
	END
	

renderGameCell: PROCEDURE
	nameX = PLAYFIELD_X + (g_cell % PLAYFIELD_WIDTH) * 3
	nameY = PLAYFIELD_Y + (g_cell / PLAYFIELD_WIDTH) * 3

	GOSUB renderCell
	END	


renderChuteCell: PROCEDURE
	nameX = CHUTE_X
	nameY = (CHUTE_Y + (g_cell * 3)) - chuteOffset

	GOSUB renderCell
	END

setCursor: PROCEDURE
	spriteX = PLAYFIELD_X * 8 + (cursorX * 24) - 1
	spriteY = PLAYFIELD_Y * 8 + (cursorY * 24) - 2
	
	currentIndex = cursorY * PLAYFIELD_WIDTH + cursorX
	color = 8

	IF game(currentIndex) = 0 THEN color = 2

	spriteOff = (FRAME AND 8) * 2

	SPRITE 0, spriteY, spriteX, spriteOff, color
	SPRITE 1, spriteY + 16, spriteX, spriteOff + 8, color
	SPRITE 2, spriteY, spriteX + 16, spriteOff + 4, color
	SPRITE 3, spriteY + 16, spriteX + 16, spriteOff + 12, color

	END

renderCell: PROCEDURE
	index = g_type * 9

	IF nameY > 23 THEN RETURN

	IF nameY >= PLAYFIELD_Y THEN DEFINE VRAM NAME_TAB_XY(nameX, nameY), 3, VARPTR cellNames(index)
	IF nameY + 1 >= PLAYFIELD_Y THEN DEFINE VRAM NAME_TAB_XY(nameX, nameY + 1), 3, VARPTR cellNames(index + 3)
	IF nameY + 2 >= PLAYFIELD_Y THEN DEFINE VRAM NAME_TAB_XY(nameX, nameY + 2), 3, VARPTR cellNames(index + 6)
	END


include "font.bas"
include "patterns.bas"