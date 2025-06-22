GOTO main

include "vdp-utils.bas"

#fontTable:
    DATA $0100, $0900, $1100, $0500, $0D00, $1500

CONST PLAYFIELD_X = 5
CONST PLAYFIELD_Y = 3
CONST PLAYFIELD_WIDTH = 9
CONST PLAYFIELD_HEIGHT = 7

CONST CELL_GRID      = 0 * 9
CONST CELL_BASE      = 1 * 9
CONST CELL_PIPE_H    = 2 * 9
CONST CELL_PIPE_V    = 3 * 9
CONST CELL_PIPE_X    = 4 * 9
CONST CELL_PIPE_DR   = 5 * 9
CONST CELL_PIPE_DL   = 6 * 9
CONST CELL_PIPE_UR   = 7 * 9
CONST CELL_PIPE_UL   = 8 * 9
CONST CELL_FILL_H    = 9 * 9
CONST CELL_FILL_V    = 10 * 9
CONST CELL_FILL_XH   = 11 * 9
CONST CELL_FILL_XV   = 12 * 9
CONST CELL_FILL_XX   = 13 * 9
CONST CELL_FILL_DR   = 14 * 9
CONST CELL_FILL_DL   = 15 * 9
CONST CELL_FILL_UR   = 16 * 9
CONST CELL_FILL_UL   = 17 * 9

main:
    ' what are we working with?
    GOSUB vdpDetect

	VDP_REG(50) = $80  ' reset VDP registers to boot values
	VDP_REG(7) = defaultReg(7)
	VDP_REG(0) = defaultReg(0)  ' VDP_REG() doesn't accept variables, so...
	VDP_REG(1) = defaultReg(1)
	VDP_REG(2) = defaultReg(2)
	VDP_REG(3) = defaultReg(3)
	VDP_REG(4) = defaultReg(4)
	VDP_REG(5) = defaultReg(5)
	VDP_REG(6) = defaultReg(6)

	FOR I = 0 TO 5
        DEFINE VRAM PLETTER #fontTable(I), $300, font
    NEXT I

    DEFINE CHAR 0, 24, logo

    DEFINE CHAR 128, 30, grid
    DEFINE COLOR 128, 18, gridColor
	FOR I = 137 TO 175
	    DEFINE COLOR I, 1, baseColor
	NEXT I
    DEFINE CHAR 158, 10, pipes	' empty pipes
    DEFINE CHAR 168, 10, pipes	' full pipes

	FOR I = 158 TO 167
	    DEFINE COLOR I, 1, pipeColor
	NEXT I
	FOR I = 168 TO 177
	    DEFINE COLOR I, 1, pipeColorGreen
	NEXT I

	DEFINE VRAM NAME_TAB_XY(0, 0), 12, logoNamesTop
	DEFINE VRAM NAME_TAB_XY(0, 1), 12, logoNamesBottom

	PRINT AT XY(20,1), "SCORE: 00000"

	g_type = CELL_GRID
	FOR g_cell = 0 TO PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT - 1
		GOSUB renderCell
	NEXT g_cell

	g_type = CELL_PIPE_H
	FOR g_cell = 11 TO 14
		GOSUB renderCell
	NEXT g_cell
	g_cell = 5
	GOSUB renderCell
	
	g_type = CELL_FILL_V
	FOR g_cell = 22 TO 42 STEP 9
		GOSUB renderCell
	NEXT g_cell

	g_type = CELL_FILL_XV
	g_cell = 13
	GOSUB renderCell

	g_type = CELL_FILL_DR
	g_cell = 4
	GOSUB renderCell
	g_type = CELL_PIPE_DL
	g_cell = 6
	GOSUB renderCell

	g_type = CELL_PIPE_UL
	g_cell = 15
	GOSUB renderCell

	VDP_ENABLE_INT
	
end:
	GOTO end

renderCell: PROCEDURE
	nameX = PLAYFIELD_X + (g_cell % PLAYFIELD_WIDTH) * 3
	nameY = PLAYFIELD_Y + (g_cell / PLAYFIELD_WIDTH) * 3

	DEFINE VRAM NAME_TAB_XY(nameX, nameY), 3, VARPTR cellNames(g_type)
	DEFINE VRAM NAME_TAB_XY(nameX, nameY + 1), 3, VARPTR cellNames(g_type + 3)
	DEFINE VRAM NAME_TAB_XY(nameX, nameY + 2), 3, VARPTR cellNames(g_type + 6)
	END	

include "font.bas"
include "patterns.bas"