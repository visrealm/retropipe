GOTO main

include "vdp-utils.bas"

#fontTable:
    DATA $0100, $0900, $1100, $0500, $0D00, $1500

CONST PLAYFIELD_X = 5
CONST PLAYFIELD_Y = 3
CONST PLAYFIELD_WIDTH = 9
CONST PLAYFIELD_HEIGHT = 7

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

    DEFINE CHAR 128, 36, grid
    DEFINE COLOR 128, 18, gridColor
	FOR I = 137 TO 137 + 9
	    DEFINE COLOR I, 1, baseColor
	NEXT I

	DEFINE VRAM NAME_TAB_XY(0, 0), 12, logoNamesTop
	DEFINE VRAM NAME_TAB_XY(0, 1), 12, logoNamesBottom

	PRINT AT XY(20,1), "SCORE: 00000"

	FOR g_cell = 0 TO PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT - 1
		GOSUB renderGrid
	NEXT g_cell

	FOR g_cell = 11 TO 14
		GOSUB renderCell
	NEXT g_cell
	FOR g_cell = 22 TO 42 STEP 9
		GOSUB renderCell
	NEXT g_cell

	VDP_ENABLE_INT
	
end:
	GOTO end

renderGrid: PROCEDURE
	nameX = PLAYFIELD_X + (g_cell % PLAYFIELD_WIDTH) * 3
	nameY = PLAYFIELD_Y + (g_cell / PLAYFIELD_WIDTH) * 3

	DEFINE VRAM NAME_TAB_XY(nameX, nameY), 3, VARPTR gridNames(0)
	DEFINE VRAM NAME_TAB_XY(nameX, nameY + 1), 3, VARPTR gridNames(3)
	DEFINE VRAM NAME_TAB_XY(nameX, nameY + 2), 3, VARPTR gridNames(6)
	END	

renderCell: PROCEDURE
	nameX = PLAYFIELD_X + (g_cell % PLAYFIELD_WIDTH) * 3
	nameY = PLAYFIELD_Y + (g_cell / PLAYFIELD_WIDTH) * 3

	DEFINE VRAM NAME_TAB_XY(nameX, nameY), 3, VARPTR cellNames(0)
	DEFINE VRAM NAME_TAB_XY(nameX, nameY + 1), 3, VARPTR cellNames(3)
	DEFINE VRAM NAME_TAB_XY(nameX, nameY + 2), 3, VARPTR cellNames(6)
	END	


include "font.bas"
include "patterns.bas"