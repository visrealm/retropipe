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
'CONST CELL_FILL_H    = 10	' bit 3 (8) set
'CONST CELL_FILL_V    = 11
'CONST CELL_FILL_XH   = 12
'CONST CELL_FILL_XV   = 13
'CONST CELL_FILL_XX   = 14
'CONST CELL_FILL_DR   = 15
'CONST CELL_FILL_DL   = 16
'CONST CELL_FILL_UR   = 17
'CONST CELL_FILL_UL   = 18
CONST CELL_CLEAR     = 19

CONST CELL_LOCKED_FLAG = $80
CONST CELL_TILE_MASK   = $0f

' tile definition
' appearance
' paths
CONST PIPE_LEFT   = 0
CONST PIPE_TOP    = 1
CONST PIPE_RIGHT  = 2
CONST PIPE_BOTTOM = 3

CONST FLOW_RIGHT  = 0
CONST FLOW_DOWN   = 1
CONST FLOW_LEFT   = 2
CONST FLOW_UP     = 3

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
CONST ANIM_FLOW_SKIP       = $80

CONST SUBTILE_TL = 0
CONST SUBTILE_TC = 1
CONST SUBTILE_TR = 2
CONST SUBTILE_ML = 32
CONST SUBTILE_MC = 33
CONST SUBTILE_MR = 34
CONST SUBTILE_BL = 64
CONST SUBTILE_BC = 65
CONST SUBTILE_BR = 66

CONST ANIM_STEPS = 8 * 3

CONST GAME_STATE_BUILDING = 0
CONST GAME_STATE_FLOWING  = 1
CONST GAME_STATE_FAILED   = 2

CONST GAME_START_DELAY_SECONDS = 5
CONST GAME_START_DELAY_FRAMES  = GAME_START_DELAY_SECONDS * 60

CONST POINTS_BUILD   		= 100
CONST POINTS_REPLACE_DEDUCT = 50
CONST POINTS_FLOW_TILE      = 100


anims:
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID
	DATA BYTE ANIM_FLOW_RIGHT,      ANIM_FLOW_INVALID,    ANIM_FLOW_LEFT,      ANIM_FLOW_INVALID
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_DOWN,       ANIM_FLOW_INVALID,   ANIM_FLOW_UP
	DATA BYTE ANIM_FLOW_RIGHT OR ANIM_FLOW_SKIP,      ANIM_FLOW_DOWN,       ANIM_FLOW_LEFT OR ANIM_FLOW_SKIP,      ANIM_FLOW_UP
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_LEFT_DOWN, ANIM_FLOW_UP_RIGHT
	DATA BYTE ANIM_FLOW_RIGHT_DOWN, ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_UP_LEFT
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_DOWN_RIGHT, ANIM_FLOW_LEFT_UP,   ANIM_FLOW_INVALID
	DATA BYTE ANIM_FLOW_RIGHT_UP,   ANIM_FLOW_DOWN_LEFT,  ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID

DIM chute(6)
DIM game(PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT)
DIM #score
DIM chuteOffset

DIM gameState

DIM cursorIndex

DIM currentFlowDir
DIM currentIndex
DIM currentAnim     
DIM currentAnimStep	' 0 to 23
DIM #currentIndexAddr
DIM currentIndexPattId

DIM flowAnimTemp
DIM flowAnimBuffer(8)

sin:
	DATA BYTE 1,1,2,3,4,5,6,6,7,7,6,6,5,4,3,2,1,1,2,3,4,5,6,6,7,7,6,6,5,4,3,2

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

	VDP_DISABLE_INT

	FOR I = 0 TO 2
        DEFINE VRAM PLETTER #fontTable(I), $300, font
    NEXT I
	
	FOR I = 0 TO CHUTE_SIZE - 1
		chute(I) = RANDOM(7) + 2
	NEXT I


    DEFINE CHAR 0, 24, logo
	GOSUB updateLogo

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
	PRINT AT XY(20,1), "SCORE: "

	chuteOffset = 20

	FOR I = 0 TO PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH - 1
		game(I) = CELL_GRID
	NEXT I

	currentIndex = 32
	currentAnim = ANIM_FLOW_LEFT
	currentAnimStep = 8
	currentFlowDir = FLOW_LEFT
	game(currentIndex) = CELL_PIPE_ST OR CELL_LOCKED_FLAG

	FOR g_cell = 0 TO PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT - 1
		g_type = game(g_cell) AND CELL_TILE_MASK
		GOSUB renderGameCell
	NEXT g_cell

	flowAnimTemp = 0
	FOR I = 0 TO 7
		flowAnimBuffer(I) = 0
	NEXT I
	DEFINE VRAM #VDP_SPRITE_PATT + 32 * 8, 8, VARPTR flowAnimBuffer(0)


	gameState = GAME_STATE_BUILDING
	gameFrame = 0

	VDP_ENABLE_INT

	WHILE 1
		WAIT
		IF gameState = GAME_STATE_FLOWING THEN
			GOSUB flowTick
		ELSEIF gameFrame > GAME_START_DELAY_FRAMES AND gameFrame < GAME_START_DELAY_FRAMES + 5 THEN
			gameState = GAME_STATE_FLOWING
		END IF

		GOSUB uiTick
		GOSUB updateLogo
		gameFrame = gameFrame + 1 ' not using FRAME to ensure consistency in case of skipped frames
	WEND

updateLogo: PROCEDURE
	CONST LOGO_FRAME_DELAY = 4
	IF gameFrame AND (LOGO_FRAME_DELAY - 1) THEN RETURN
	logoOffset = ((gameFrame / LOGO_FRAME_DELAY) AND $f)
	FOR I = 0 TO 11
		DEFINE COLOR I + 12, 1, VARPTR logoColorWhiteGreen(sin(I + logoOffset))
	NEXT I
	END


flowTick: PROCEDURE
	VDP_DISABLE_INT

	animTile = currentAnimStep / 8
	animSubStep = currentAnimStep AND $07
	currentSubTile = 0
	skipAnim = 0	
	IF animTile = 0 THEN
		currentFlowDir = (currentAnim / 16) AND 7
		SELECT CASE (currentAnim / 16) AND 7
			CASE FLOW_RIGHT
				currentSubTile = SUBTILE_ML
			CASE FLOW_DOWN
				currentSubTile = SUBTILE_TC
			CASE FLOW_LEFT
				currentSubTile = SUBTILE_MR
			CASE FLOW_UP
				currentSubTile = SUBTILE_BC
			CASE ELSE
				gameState = GAME_STATE_FAILED
		END SELECT

	ELSEIF animTile = 1 THEN
		currentSubTile = SUBTILE_MC
		IF currentAnim AND $80 THEN skipAnim = 1
	ELSEIF animTile = 2 THEN
		currentFlowDir = currentAnim AND 3
		SELECT CASE currentFlowDir
			CASE FLOW_RIGHT
				currentSubTile = SUBTILE_MR
			CASE FLOW_DOWN
				currentSubTile = SUBTILE_BC
			CASE FLOW_LEFT
				currentSubTile = SUBTILE_ML
			CASE FLOW_UP
				currentSubTile = SUBTILE_TC
		END SELECT
	ELSE
		SELECT CASE currentFlowDir
			CASE FLOW_RIGHT
				currentIndex = currentIndex + 1
			CASE FLOW_DOWN
				currentIndex = currentIndex + PLAYFIELD_WIDTH
			CASE FLOW_LEFT
				currentIndex = currentIndex - 1
			CASE FLOW_UP
				currentIndex = currentIndex - PLAYFIELD_WIDTH
		END SELECT
	
		currentAnimStep = 0
		tileId = game(currentIndex) AND CELL_TILE_MASK
		IF tileId < 2 THEN
			gameState = GAME_STATE_FAILED
		ELSE
			game(currentIndex) = tileId OR CELL_LOCKED_FLAG
			#score = #score + POINTS_FLOW_TILE
			GOSUB updateScore
		END IF
		currentAnim = anims(tileId * 4 + (currentAnim AND 3))
	END IF

	IF (gameFrame AND 7) = 7 THEN
		nameX = PLAYFIELD_X + (currentIndex % PLAYFIELD_WIDTH) * 3
		nameY = PLAYFIELD_Y + (currentIndex / PLAYFIELD_WIDTH) * 3

		#currentIndexAddr = #VDP_NAME_TAB + XY(nameX, nameY) + currentSubTile
		currentIndexPattId = (VPEEK(#currentIndexAddr) - 158) * 8

		currentAnimStep = currentAnimStep + 1

		animSprX = PLAYFIELD_X + (currentIndex % PLAYFIELD_WIDTH) * 3
		animSprY = PLAYFIELD_Y + (currentIndex / PLAYFIELD_WIDTH) * 3

		animSprX = (animSprX + (currentSubTile AND 3)) * 8
		animSprY = (animSprY + (currentSubTile / 32)) * 8
		
		SELECT CASE currentFlowDir
			CASE FLOW_LEFT
				flowAnimTemp = (flowAnimTemp * 2) OR $01
				FOR I = 0 TO 7
					flowAnimBuffer(I) = flowAnimTemp AND NOT pipes(currentIndexPattId + I)
				NEXT I
			CASE FLOW_RIGHT
				flowAnimTemp = (flowAnimTemp / 2) OR $80
				FOR I = 0 TO 7
					flowAnimBuffer(I) = flowAnimTemp AND NOT pipes(currentIndexPattId + I)
				NEXT I
			CASE FLOW_UP
					flowAnimBuffer(7 - animSubStep) = NOT pipes(currentIndexPattId + 7 - animSubStep)
			CASE FLOW_DOWN
					flowAnimBuffer(animSubStep) = NOT pipes(currentIndexPattId + animSubStep)
		END SELECT
		DEFINE VRAM #VDP_SPRITE_PATT + 32 * 8, 8, VARPTR flowAnimBuffer(0)

		SPRITE 4, animSprY - 1, animSprX, 32, $2

		IF animSubStep = 7 AND skipAnim = 0 THEN
			c = VPEEK(#currentIndexAddr)
			VPOKE #currentIndexAddr, c + 10

			flowAnimTemp = 0
			FOR I = 0 TO 7
				flowAnimBuffer(I) = 0
			NEXT I
			DEFINE VRAM #VDP_SPRITE_PATT + 32 * 8, 8, VARPTR flowAnimBuffer(0)

			SPRITE 4, animSprY - 1, animSprX, 32, 0
		END IF
	END IF

	VDP_ENABLE_INT
	END


uiTick: PROCEDURE
	GOSUB updateNavInput

	IF g_nav > 0 AND delayFrames > 0 THEN
		delayFrames = delayFrames - 1
		r = RANDOM(255)
		RETURN
	END IF

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
		tileId = game(cursorIndex)
		IF (tileId AND CELL_LOCKED_FLAG) = 0 THEN
			GOSUB placeTile
		END IF
	ELSE
		delayFrames = 0
		FOR I = 0 TO cursorY + cursorX
			r = RANDOM(255)
		NEXT I
	END IF

	IF chuteOffset > 0 THEN
		chuteOffset = chuteOffset - 1
		GOSUB renderChute
	END IF

	GOSUB setCursor

	VDP_ENABLE_INT
	END

updateScore: PROCEDURE
	PRINT AT XY(27,1), <5>#score
	END

placeTile: PROCEDURE
	tileId = tileId AND CELL_TILE_MASK
	IF tileId > 0 THEN
		#score = #score - POINTS_REPLACE_DEDUCT
		
		' test going negative
		IF #score > 65485 then #score = 0
	ELSE
		#score = #score + POINTS_BUILD
	END IF
	

	g_type = chute(0)
	g_cell = cursorIndex
	game(cursorIndex) = g_type
	GOSUB renderGameCell
	FOR I = 0 TO CHUTE_SIZE - 2
		chute(I) = chute(I + 1)
	NEXT I
	chute(CHUTE_SIZE - 1) = RANDOM(7) + 2
	g_cell = CHUTE_SIZE - 1
	g_type = CELL_CLEAR
	GOSUB renderChuteCell 
	chuteOffset = 4
	GOSUB updateScore
	END

renderChute: PROCEDURE
	g_cell = CHUTE_SIZE
	FOR I = 0 TO CHUTE_SIZE - 1
		g_cell = g_cell - 1
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
	
	cursorIndex = cursorY * PLAYFIELD_WIDTH + cursorX
	color = 2

	IF game(cursorIndex) AND CELL_LOCKED_FLAG THEN color = 8

	spriteOff = (gameFrame AND 8) * 2

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