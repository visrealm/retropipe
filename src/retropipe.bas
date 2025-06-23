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
CONST CELL_FILL_H    = 9
CONST CELL_FILL_V    = 10
CONST CELL_FILL_XH   = 11
CONST CELL_FILL_XV   = 12
CONST CELL_FILL_XX   = 13
CONST CELL_FILL_DR   = 14
CONST CELL_FILL_DL   = 15
CONST CELL_FILL_UR   = 16
CONST CELL_FILL_UL   = 17

DIM chute(6)
DIM game(PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT)
DIM #score
DIM chuteOffset

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
		game(I) = 0
	NEXT I

	FOR g_cell = 0 TO PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT - 1
		g_type = game(I)
		GOSUB renderGameCell
	NEXT g_cell

	VDP_ENABLE_INT

	WHILE 1
		GOSUB updateNavInput

		IF NAV(NAV_RIGHT) AND cursorX < (PLAYFIELD_WIDTH - 1) THEN
			cursorX = cursorX + 1
		ELSEIF NAV(NAV_LEFT) AND cursorX > 0 THEN
			cursorX = cursorX - 1
		ELSEIF NAV(NAV_DOWN) AND cursorY < (PLAYFIELD_HEIGHT - 1) THEN
			cursorY = cursorY + 1
		ELSEIF NAV(NAV_UP) AND cursorY > 0 THEN
			cursorY = cursorY - 1
		ELSEIF NAV(NAV_OK) THEN
			WAIT
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
		END IF

		IF chuteOffset > 0 THEN
			chuteOffset = chuteOffset - 1
			GOSUB renderChute
		END IF

		GOSUB setCursor
		GOSUB delay
	WEND
	
end:
	GOTO end

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