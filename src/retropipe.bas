GOTO main

include "vdp-utils.bas"
include "input.bas"

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
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID

DIM chute(CHUTE_SIZE + 1)
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

DIM savedNav

sin:
	DATA BYTE 1,1,2,3,4,5,6,7,8,8,7,6,5,4,3,2,1,1,2,3,4,5,6,7,8,8,7,6,5,4,3,2

main:
    ' what are we working with?
'    GOSUB vdpDetect

	VDP_REG(50) = $80  ' reset VDP registers to boot values
	VDP_REG(7) = defaultReg(7)
	VDP_REG(0) = defaultReg(0)  ' VDP_REG() doesn't accept variables, so...
	VDP_REG(1) = defaultReg(1)
	VDP_REG(2) = defaultReg(2)
	VDP_REG(3) = defaultReg(3)
	VDP_REG(4) = defaultReg(4)
	VDP_REG(5) = defaultReg(5)
	VDP_REG(6) = defaultReg(6)

	FOR #I = $0100 TO $1100 STEP $0800
        DEFINE VRAM PLETTER #I, $300, font
    NEXT #I
	
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
	FOR I = PLAYFIELD_Y + CHUTE_SIZE * 3 + 1 TO 23
		PUT_XY(4, I), 183
	NEXT I

	DEFINE SPRITE 0, 8, selSprites
	'SPRITE 5, $d0, 0, 0, 0

	WHILE 1
		GOSUB pipeGame
	WEND

pipeGame: PROCEDURE
	cursorX = 4
	cursorY = 3
	#score = 0

	GOSUB updateCursorPos

	' render chute bottom
	DEFINE VRAM NAME_TAB_XY(0, PLAYFIELD_Y + CHUTE_SIZE * 3), 5, chuteBottomNames

	' clear dynamic flow sprite patterns
	DEFINE VRAM #VDP_SPRITE_PATT + 32 * 8, 16, emptyTile
	DEFINE VRAM #VDP_SPRITE_PATT + 34 * 8, 16, emptyTile

	FOR I = 0 TO CHUTE_SIZE - 1
		chute(I) = RANDOM(7) + 2
	NEXT I
	chute(CHUTE_SIZE) = CELL_CLEAR

	PRINT AT XY(20,0), "LEVEL: 1"
	PRINT AT XY(20,1), "SCORE: "
	GOSUB updateScore

	chuteOffset = 20

	FOR I = 0 TO PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH - 1
		game(I) = CELL_GRID
	NEXT I

	currentIndex = 32
	currentAnim = ANIM_FLOW_LEFT
	currentAnimStep = 8
	currentFlowDir = FLOW_LEFT

	animNameX = PLAYFIELD_X + (currentIndex % PLAYFIELD_WIDTH) * 3
	animNameY = PLAYFIELD_Y + (currentIndex / PLAYFIELD_WIDTH) * 3
	#currentIndexAddr = #VDP_NAME_TAB + XY(animNameX, animNameY)

	game(currentIndex) = CELL_PIPE_ST OR CELL_LOCKED_FLAG

	FOR g_cell = 0 TO PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT - 1
		g_type = game(g_cell) AND CELL_TILE_MASK
		GOSUB renderGameCell
	NEXT g_cell

	flowAnimTemp = 0
	FOR I = 0 TO 7
		flowAnimBuffer(I) = 0
	NEXT I

	gameState = GAME_STATE_BUILDING
	gameFrame = 0

	VDP_ENABLE_INT
	gameSeconds = 0

	' main game loop
	WHILE 1
		WAIT
'		VDP_REG(7) = defaultReg($fb)	' green

		'VDP_DISABLE_INT
		IF gameState = GAME_STATE_FLOWING THEN
			GOSUB flowTick
		ELSEIF gameSeconds = GAME_START_DELAY_SECONDS THEN
			gameState = GAME_STATE_FLOWING
		ELSEIF gameState = GAME_STATE_FAILED THEN
			IF gameSeconds < 1 THEN
				chuteOffset = chuteOffset - 1
				GOSUB renderChute
			ELSEIF gameSeconds = 3 THEN
				EXIT WHILE
			END IF
		END IF
'		VDP_REG(7) = defaultReg($f6)    ' red
		GOSUB uiTick
'		VDP_REG(7) = defaultReg($fd)	' magenta
		GOSUB logoTick
'		VDP_REG(7) = defaultReg($f4)	' blue
		gameFrame = gameFrame + 1 ' not using FRAME to ensure consistency in case of skipped frames
		IF (gameFrame AND $3f) = 0 THEN gameSeconds = gameSeconds + 1
		'VDP_ENABLE_INT
	WEND
	END

logoTick: PROCEDURE
	CONST LOGO_FRAME_DELAY = 4

	' only move the wave every 4 frames
	logoOffset = gameFrame / LOGO_FRAME_DELAY

	' every frame however, we render a quarter of the new wave
	logoOffset = (logoOffset AND $f) + 23
	logoStart = (gameFrame AND 3) * 3 + 12

	FOR I = logoStart TO logoStart + 2
		DEFINE VRAM #VDP_COLOR_TAB1 + I * 8, 8, VARPTR logoColorWhiteGreen(sin(logoOffset - I))
	NEXT I
	END

subTileForFlow0:
	DATA BYTE SUBTILE_ML, SUBTILE_TC, SUBTILE_MR, SUBTILE_BC
subTileForFlow1:
	DATA BYTE SUBTILE_MR, SUBTILE_BC, SUBTILE_ML, SUBTILE_TC
offsetForFlow2:
	DATA BYTE 1, PLAYFIELD_WIDTH, -1, -PLAYFIELD_WIDTH

flowTick: PROCEDURE
'	VDP_DISABLE_INT
	IF (gameFrame AND 1) <> 0 THEN RETURN

startFlow:
	animTile = currentAnimStep / 8
	
	IF animTile = 4 THEN	' next tile?
	END IF

	animSubStep = currentAnimStep AND $07
	currentAnimStep = currentAnimStep + 1

	currentSubTile = 0
	skipAnim = 0
	IF animTile = 0 THEN
		currentFlowDir = (currentAnim / 16) AND 7
		IF currentFlowDir < 4 THEN
			currentSubTile = subTileForFlow0(currentFlowDir)
		ELSE
			gameState = GAME_STATE_FAILED
			gameSeconds = 0 
		END IF
	ELSEIF animTile = 1 THEN
		currentSubTile = SUBTILE_MC
		IF currentAnim AND $80 THEN skipAnim = 1
	ELSEIF animTile = 2 THEN
		currentFlowDir = currentAnim AND 3
		currentSubTile = subTileForFlow1(currentFlowDir)
	ELSE
		currentIndex = currentIndex + offsetForFlow2(currentFlowDir)
	
		animNameX = PLAYFIELD_X + (currentIndex % PLAYFIELD_WIDTH) * 3
		animNameY = PLAYFIELD_Y + (currentIndex / PLAYFIELD_WIDTH) * 3
		#currentIndexAddr = #VDP_NAME_TAB + XY(animNameX, animNameY)

		currentAnimStep = 0
		animSubStep = 7	' ensure flow sprite is hidden
		tileId = game(currentIndex) AND CELL_TILE_MASK
		IF tileId < 2 THEN
			gameState = GAME_STATE_FAILED
			gameSeconds = 0
		ELSE
			game(currentIndex) = tileId OR CELL_LOCKED_FLAG
			#score = #score + POINTS_FLOW_TILE
			GOSUB updateScore
		END IF
		currentAnim = anims(tileId * 4 + (currentAnim AND 3))
		GOTO startFlow
	END IF

	currentIndexPattId = (VPEEK(#currentIndexAddr + currentSubTile) - 158) * 8

	IF skipAnim AND (currentSubTile = SUBTILE_MC) THEN
		' do nothing
	ELSEIF currentSubTile = SUBTILE_MC AND ((currentAnim XOR (currentAnim / 16)) AND 3) THEN
		GOSUB flowSpriteCorner
	ELSE
		GOSUB flowSpriteStraight
	END IF

	IF animSubStep = 7 AND skipAnim = 0 THEN
		IF currentAnimStep > 0 THEN
			I = VPEEK(#currentIndexAddr + currentSubTile)
			VPOKE #currentIndexAddr + currentSubTile, I+ 10
		END IF

		flowAnimTemp = 0
		FOR I = 0 TO 7
			flowAnimBuffer(I) = 0
		NEXT I

		DEFINE VRAM #VDP_SPRITE_PATT + 32 * 8, 8, VARPTR flowAnimBuffer(0)
		SPRITE 4, animSprY - 1, animSprX, 32, 0
	ELSEIF gameState <> GAME_STATE_FAILED THEN
		animSprX = (animNameX + (currentSubTile AND 3)) * 8
		animSprY = (animNameY + (currentSubTile / 32)) * 8

		DEFINE VRAM #VDP_SPRITE_PATT + 32 * 8, 8, VARPTR flowAnimBuffer(0)
		SPRITE 4, animSprY - 1, animSprX, 32, $2
	END IF

	'VDP_ENABLE_INT
	END

flowSpriteStraight: PROCEDURE
	IF currentFlowDir = FLOW_LEFT THEN
		flowAnimTemp = (flowAnimTemp * 2) OR $01
		FOR I = 0 TO 7
			' NABU: For some reason  flowAnimTemp AND NOT pipes(currentIndexPattId + I))
			'       doesn't work. results in $ff
			flowAnimBuffer(I) = (NOT pipes(currentIndexPattId + I)) AND flowAnimTemp
		NEXT I
	ELSEIF currentFlowDir = FLOW_RIGHT THEN
		flowAnimTemp = (flowAnimTemp / 2) OR $80
		FOR I = 0 TO 7
			flowAnimBuffer(I) = NOT pipes(currentIndexPattId + I) AND flowAnimTemp
		NEXT I
	ELSEIF currentFlowDir = FLOW_UP THEN
		flowAnimBuffer(7 - animSubStep) = NOT pipes(currentIndexPattId + 7 - animSubStep)
	ELSEIF currentFlowDir = FLOW_DOWN THEN
		flowAnimBuffer(animSubStep) = NOT pipes(currentIndexPattId + animSubStep)
	END IF
	END	

flowSpriteCorner: PROCEDURE
	offset = animSubStep * 8
	IF currentAnim = ANIM_FLOW_RIGHT_UP THEN
		FOR I = 0 TO 7
			flowAnimBuffer(I) = reverseBits(cornerFlowLeftUp(offset + I))
		NEXT I
	ELSEIF currentAnim = ANIM_FLOW_RIGHT_DOWN THEN
		offset = offset + 7
		FOR I = 0 TO 7
			flowAnimBuffer(I) = reverseBits(cornerFlowLeftUp(offset - I))
		NEXT I
	ELSEIF currentAnim = ANIM_FLOW_DOWN_LEFT THEN
		FOR I = 0 TO 7
			flowAnimBuffer(I) = cornerFlowDownLeft(offset + I)
		NEXT I
	ELSEIF currentAnim = ANIM_FLOW_DOWN_RIGHT THEN
		FOR I = 0 TO 7
			flowAnimBuffer(I) = reverseBits(cornerFlowDownLeft(offset + I))
		NEXT I
	ELSEIF currentAnim = ANIM_FLOW_LEFT_UP THEN
		FOR I = 0 TO 7
			flowAnimBuffer(I) = cornerFlowLeftUp(offset + I)
		NEXT I
	ELSEIF currentAnim = ANIM_FLOW_LEFT_DOWN THEN
		offset = offset + 7
		FOR I = 0 TO 7
			flowAnimBuffer(I) = cornerFlowLeftUp(offset - I)
		NEXT I
	ELSEIF currentAnim = ANIM_FLOW_UP_LEFT THEN
		offset = offset + 7
		FOR I = 0 TO 7
			flowAnimBuffer(I) = cornerFlowDownLeft(offset - I)
		NEXT I
	ELSEIF currentAnim = ANIM_FLOW_UP_RIGHT THEN
		offset = offset + 7
		FOR I = 0 TO 7
			flowAnimBuffer(I) = reverseBits(cornerFlowDownLeft(offset - I))
		NEXT I
	END IF
	END



uiTick: PROCEDURE
	GOSUB updateNavInput
	savedNav = savedNav OR g_nav
	IF g_nav > 0 AND delayFrames > 0 THEN
		delayFrames = delayFrames - 1
		r = RANDOM(255)
		RETURN
	END IF

	'VDP_DISABLE_INT
	SOUND 0,,0

	delayFrames = 8
	IF NAV(NAV_OK) AND gameState <> GAME_STATE_FAILED THEN
		tileId = game(cursorIndex)
		IF (tileId AND CELL_LOCKED_FLAG) = 0 THEN
			GOSUB placeTile
		END IF
	ELSEIF NAV(NAV_RIGHT) AND cursorX < (PLAYFIELD_WIDTH - 1) THEN
		cursorX = cursorX + 1
		GOSUB updateCursorPos
	ELSEIF NAV(NAV_LEFT) AND cursorX > 0 THEN
		cursorX = cursorX - 1
		GOSUB updateCursorPos
	ELSEIF NAV(NAV_DOWN) AND cursorY < (PLAYFIELD_HEIGHT - 1) THEN
		cursorY = cursorY + 1
		GOSUB updateCursorPos
	ELSEIF NAV(NAV_UP) AND cursorY > 0 THEN
		cursorY = cursorY - 1
		GOSUB updateCursorPos
	ELSE
		delayFrames = 0
		FOR I = 0 TO (cursorY + cursorX) AND 3
			r = RANDOM(255)
		NEXT I
	END IF

	IF gameState <> GAME_STATE_FAILED AND chuteOffset <> 0 THEN
		chuteOffset = chuteOffset - 1
		GOSUB renderChute
	END IF

	GOSUB setCursor

	'VDP_ENABLE_INT
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

	SOUND 0, 254, 15

	END

renderChute: PROCEDURE
	g_cell = CHUTE_SIZE
	FOR I = 0 TO CHUTE_SIZE
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

updateCursorPos: PROCEDURE
	spriteX = PLAYFIELD_X * 8 + (cursorX * 24) - 1
	spriteY = PLAYFIELD_Y * 8 + (cursorY * 24) - 2
	
	cursorIndex = cursorY * PLAYFIELD_WIDTH + cursorX
	END

renderCell: PROCEDURE
	index = g_type * 9

	FOR J = 0 TO 2
		IF nameY > 23 THEN RETURN
		IF nameY >= PLAYFIELD_Y THEN DEFINE VRAM NAME_TAB_XY(nameX, nameY), 3, VARPTR cellNames(index)
		index = index + 3
		nameY = nameY + 1
	NEXT J
	END

setCursor: PROCEDURE
	color = 15
	
	IF gameFrame AND 8 THEN color = 14
	IF game(cursorIndex) AND CELL_LOCKED_FLAG THEN color = 8
	IF gameState = GAME_STATE_FAILED THEN color = 0

	SPRITE 0, spriteY, spriteX, 0, color
	SPRITE 1, spriteY + 16, spriteX, 8, color
	SPRITE 2, spriteY, spriteX + 16, 4, color
	SPRITE 3, spriteY + 16, spriteX + 16, 12, color

	END


include "font.bas"
include "patterns.bas"