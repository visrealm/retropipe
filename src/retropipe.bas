'
' Project: retropipe
'
' RetroPIPE - Pipe Dream clone for retro computers
'
' Copyright (c) 2025 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/retropipe
'

CONST SHOW_TITLE = 1


' ==========================================
' CONSTANTS
' ------------------------------------------
CONST PLAYFIELD_X = 5
CONST PLAYFIELD_Y = 3
CONST PLAYFIELD_WIDTH = 9
CONST PLAYFIELD_HEIGHT = 7

CONST CHUTE_X = 1
CONST CHUTE_Y = 3
CONST CHUTE_SIZE = 5

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

CONST GAME_STATE_BUILDING = 0
CONST GAME_STATE_FLOWING  = 1
CONST GAME_STATE_ENDED   = 2

CONST GAME_START_DELAY_SECONDS = 10

CONST CURSOR_SPRITE_ID         = 0
CONST CURSOR_SPRITE_PATT_ID    = 0
CONST SPILL_SPRITE_PATT_ID     = 2
CONST SPILL_SPRITE_COUNT  = 6

CONST POINTS_BUILD   		= 100
CONST POINTS_REPLACE_DEDUCT = 50
CONST POINTS_FLOW_TILE      = 100

CONST FALSE = 0
CONST TRUE  = -1

' ==========================================
' GLOBALS ( I guess everything is global :D )
' ------------------------------------------
DIM chute(CHUTE_SIZE + 1)
DIM game(PLAYFIELD_WIDTH * PLAYFIELD_HEIGHT)
DIM #score
DIM chuteOffset

DIM gameState

DIM cursorIndex

DIM remainingPipes

DIM currentLevel
DIM currentFlowDir
DIM currentIndex
DIM currentTileX
DIM currentTileY
DIM currentAnim     
DIM currentAnimStep	' 0 to 23
DIM #currentIndexAddr
DIM currentIndexPattId
DIM currentSpeed' 0, 1, 3, 7, 15 (inverse speed. actually frame delay)
DIM hoverFfwd

DIM #lastTileNameIndex

DIM flowAnimTemp
DIM flowAnimBuffer(8)
DIM silentFrame

DIM scoreCurrentOffset(5)
DIM scoreDesiredOffset(5)

SIGNED scoreCurrentOffset, scoreDesiredOffset

DIM savedNav
DIM spillSpriteId

' ==========================================
' ENTRY POINT
' ------------------------------------------
GOTO main

' ==========================================
' INCLUDES
' ------------------------------------------
include "vdp-utils.bas"
include "input.bas"
include "tiles.bas"

CONST #SCORE_VRAM_ADDR		= #VDP_FREE_START

CONST FLOW_COLOR = VDP_MED_GREEN


' ==========================================
' ACTUAL ENTRY POINT
' ------------------------------------------
main:
    ' what are we working with?
'    GOSUB vdpDetect
	'VDP_REG(50) = $80  ' reset VDP registers to boot values
	VDP_REG(7) = defaultReg(7)
	VDP_REG(0) = defaultReg(0)  ' VDP_REG() doesn't accept variables, so...
	VDP_REG(1) = defaultReg(1) OR vdpR1Flags
	VDP_REG(2) = defaultReg(2)
	VDP_REG(3) = defaultReg(3)
	VDP_REG(4) = defaultReg(4)
	VDP_REG(5) = defaultReg(5)
	VDP_REG(6) = defaultReg(6)

	SPRITE FLICKER OFF	' the CVB sprite flicker routine messes with things. turn it off

	' font patterns - write to each bank
	FOR #I = $0100 TO $1100 STEP $0800
        DEFINE VRAM PLETTER #I, $300, fontPletter
    NEXT #I

	FOR I = 32 TO 127
		DEFINE COLOR I, 1, fontColor
	NEXT I


#if SHOW_TITLE
	GOSUB titleScreen

	FOR #I = $0100 TO $1100 STEP $0800
        DEFINE VRAM PLETTER #I, $300, fontPletter
    NEXT #I

	FOR I = 0 TO 254
		DEFINE COLOR I, 1, defaultColor
	NEXT I
	FOR I = 24 TO 127
		DEFINE COLOR I, 1, fontColor
	NEXT I
	FOR I = 128 TO 254
		DEFINE COLOR I, 1, defaultColor
	NEXT I

#endif

	' title / logo patterns
    DEFINE CHAR PLETTER 0, 24, logoTopPletter

    DEFINE CHAR PLETTER 128, 30, gridPletter
    DEFINE COLOR PLETTER 128, 18, gridColorPletter
 
	' tile patterns and colors
	FOR I = 137 TO 175
	    DEFINE COLOR I, 1, baseColor
	NEXT I
    DEFINE CHAR PLETTER 158, 10, pipesPletter	' empty pipes
    DEFINE CHAR PLETTER 168, 10, pipesPletter	' full pipes

	DEFINE CHAR 31, 1, tilePiece	' remaining pipes
	DEFINE COLOR 31, 1, tilePieceColor

	FOR I = 158 TO 167
	    DEFINE COLOR I, 1, pipeColor
	NEXT I
	FOR I = 168 TO 177
	    DEFINE COLOR I, 1, pipeColorGreen
	NEXT I

	' score patterns (dynamic rolling digits)
	FOR I = 0 TO 4
		scoreCurrentOffset(I) = 0
		DEFINE VRAM #VDP_PATT_TAB1 + ((24 + I) * 8), 8, VARPTR digits(0)
		'DEFINE COLOR 24 + I, 1, digitColor
	NEXT I


	' gamefield patterns
    DEFINE CHAR PLETTER 178, 7, bordersPletter

	' set up the name table
	' ------------------------------

	DEFINE VRAM NAME_TAB_XY(0, 0), 12, logoNamesTop
	DEFINE VRAM NAME_TAB_XY(0, 1), 12, logoNamesBottom

	CONST CHUTE_BOTTOM = PLAYFIELD_Y + CHUTE_SIZE * 3

	' vertical left chute and border
	FOR I = PLAYFIELD_Y TO CHUTE_BOTTOM - 1
		DEFINE VRAM NAME_TAB_XY(0, I), 5, chuteNames
	NEXT I

	FOR I = CHUTE_BOTTOM + 1 TO 23
		PUT_XY(4, I), 183
	NEXT I

	' cursor sprites
	DEFINE SPRITE PLETTER CURSOR_SPRITE_PATT_ID, 1, cursorSpritesPletter
	DEFINE SPRITE PLETTER SPILL_SPRITE_PATT_ID, 6, spillPattPletter

	currentLevel = 1
	#score = 0

	WHILE 1
		GOSUB pipeGame
	WEND

pipeGame: PROCEDURE
	cursorX = 4
	cursorY = 3
	remainingPipes = 13 + currentLevel
	IF remainingPipes > 24 THEN remainingPipes = 24
	vdpR1Flags = 0

	hoverFfwd = 0

	currentSpeed = 8
	J = currentLevel / 3
	WHILE J
		currentSpeed = currentSpeed / 2
		J = J - 1
	WEND	
	IF currentSpeed < 2 THEN currentSpeed = 2
	currentSpeed = currentSpeed - 1	

	' horizontal top border
	FILL_BUFFER(184)
	DEFINE VRAM NAME_TAB_XY(0, 2), 31, VARPTR rowBuffer(0)

	GOSUB renderFfwdButton
	GOSUB updateCursorPos

	SPRITE 4, 0, 0, 4, VDP_TRANSPARENT

	' render chute bottom
	DEFINE VRAM NAME_TAB_XY(0, PLAYFIELD_Y + CHUTE_SIZE * 3), 5, chuteBottomNames

	' clear dynamic flow sprite patterns
	FILL_BUFFER(0)
	DEFINE VRAM #VDP_SPRITE_PATT + 8 * 8, 8, VARPTR rowBuffer(0)

	FOR I = 0 TO CHUTE_SIZE - 1
		chute(I) = RANDOM(7) + 2
	NEXT I
	chute(CHUTE_SIZE) = CELL_CLEAR

	PRINT AT XY(20,0), "LEVEL: ", currentLevel
	PRINT AT XY(20,1), "SCORE: \24\25\26\27\28"
	GOSUB updateScore

	chuteOffset = 20

	FOR I = 0 TO PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH - 1
		game(I) = CELL_GRID
	NEXT I


	' start tile position
	currentTileX = RANDOM(PLAYFIELD_WIDTH - 2) + 1
	currentTileY = RANDOM(PLAYFIELD_HEIGHT - 2) + 1
	currentIndex = currentTileY * PLAYFIELD_WIDTH + currentTileX

	animNameX = PLAYFIELD_X + (currentIndex % PLAYFIELD_WIDTH) * 3
	animNameY = PLAYFIELD_Y + (currentIndex / PLAYFIELD_WIDTH) * 3
	#currentIndexAddr = #VDP_NAME_TAB + XY(animNameX, animNameY)

	' generate the start tile
	I = RANDOM(4)
	currentAnim = (I * 16) OR I
	currentAnimStep = 8
	currentFlowDir = I
	game(currentIndex) = (CELL_PIPE_ST + I) OR CELL_LOCKED_FLAG
	'game(15) = $81
	'game(37) = $81

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
	gameSeconds = 0
	spillSpriteId = 8
	currentStartDelay = GAME_START_DELAY_SECONDS - currentLevel
	IF currentStartDelay < 5 THEN currentStartDelay = 5

	VDP_ENABLE_INT

	' main game loop
	WHILE 1
		WAIT

		if gameFrame = silentFrame THEN SOUND 3,,0

		IF gameState = GAME_STATE_FLOWING THEN
			GOSUB flowTick
		ELSEIF gameSeconds = currentStartDelay THEN
			gameState = GAME_STATE_FLOWING
			FOR J = 0 TO 5 : rowBuffer(J) = J : NEXT J
			DEFINE VRAM NAME_TAB_XY(1, CHUTE_BOTTOM + 1), 3, VARPTR rowBuffer(0)
			DEFINE VRAM NAME_TAB_XY(1, CHUTE_BOTTOM + 2), 3, VARPTR rowBuffer(3)
		ELSEIF gameState = GAME_STATE_ENDED THEN
			IF gameSeconds < 2 THEN
				chuteOffset = chuteOffset - 1
				IF remainingPipes THEN
					vdpR1Flags = $02
					VDP_ENABLE_INT
					GOSUB spillTick
				END IF
				GOSUB renderChute
			ELSEIF gameSeconds = 3 THEN
				IF remainingPipes = 0 THEN
					currentLevel = currentLevel + 1
				ELSE
					currentLevel = 1
					#score = 0
				END IF
				EXIT WHILE
			END IF
		END IF

		GOSUB uiTick
		GOSUB logoTick
		GOSUB scoreTick
		
		gameFrame = gameFrame + 1 ' not using FRAME to ensure consistency in case of skipped frames
		IF (gameFrame AND $3f) = 0 THEN	' very rough seconds. 64 ticks so will be slow at 50FPS
			gameSeconds = gameSeconds + 1
		END IF
	WEND
	END


' ==========================================
' Handle liquid spill animation
' ------------------------------------------
spillTick: PROCEDURE
	IF (gameFrame AND 7) OR (spillSpriteId >= 28) THEN RETURN

	spillSpriteId = spillSpriteId + 4

	SPRITE 4, lastAnimSprY - .offsetY(lastFlowDir), lastAnimSprX - .offsetX(lastFlowDir), spillSpriteId, FLOW_COLOR
	END

.offsetX:
DATA BYTE -2, 4, 10, 4
.offsetY:
DATA BYTE 4, -2, 4, 10


' ==========================================
' Handle score animation
' ------------------------------------------
scoreTick: PROCEDURE
	FOR I = 0 TO 4
		IF scoreCurrentOffset(I) <> scoreDesiredOffset(I) THEN
			GOSUB .rollDigit
		END IF
	NEXT I
	END

.rollDigit: PROCEDURE
	' which way are we going and how far?
	#diff = scoreDesiredOffset(I) - scoreCurrentOffset(I)
	dist = ABS(#diff)
	speed = SGN(#diff)

	' is it closer to go the opposite direction?
	IF dist > 5 * 8 THEN
		speed = -speed
		dist = 10 * 8 - dist
	END IF
	
	' let's go faster if we're further away
	IF dist > 8 THEN
		speed = speed * (dist / 4)
	END IF

	scoreCurrentOffset(I) = scoreCurrentOffset(I) + speed

	IF scoreCurrentOffset(I) < 0 THEN
		scoreCurrentOffset(I) = 80 + scoreCurrentOffset(I)
	ELSEIF scoreCurrentOffset(I) > 79 THEN
		scoreCurrentOffset(I) = scoreCurrentOffset(I) - 80
	END IF

	DEFINE VRAM #VDP_PATT_TAB1 + (24 + I) * 8, 8, VARPTR digits(scoreCurrentOffset(I))
	END


' Update the score data
' ------------------------------------------
updateScore: PROCEDURE

	' print score to off-screen buffer (could be faster to just process manually)
	PRINT AT #SCORE_VRAM_ADDR, <5>#score

	' copy from vram to ram
	DEFINE VRAM READ #SCORE_VRAM_ADDR, 5, VARPTR scoreDesiredOffset(0)

	' offset to pattern index
	FOR I = 0 TO 4
		scoreDesiredOffset(I) = (scoreDesiredOffset(I) - 48) * 8
	NEXT I

	#addr = NAME_TAB_XY(31 - remainingPipes, 2)
	IF remainingPipes THEN FILL_BUFFER(31)
	rowBuffer(0) = 184
	DEFINE VRAM #addr, remainingPipes + 1, VARPTR rowBuffer(0)

	END


' ==========================================
' Handle title/logo animation
' ------------------------------------------
logoTick: PROCEDURE
	CONST LOGO_ANIM_TILE_ID         = 12
	CONST LOGO_ANIM_TILES_PER_FRAME = 3
	CONST LOGO_ANIM_SINE_OFFSET     = 23

	' only move the wave every 4 frames
	logoOffset = gameFrame / 4

	' every frame however, we render a quarter of the new wave
	logoStart = (gameFrame AND 3) * LOGO_ANIM_TILES_PER_FRAME + LOGO_ANIM_TILE_ID
	logoOffset = (logoOffset AND $f) + LOGO_ANIM_SINE_OFFSET - logoStart

	' update the color defs of three tiles
	#addr = #VDP_COLOR_TAB1 + logoStart * TILE_ROWS
	FOR I = 0 TO LOGO_ANIM_TILES_PER_FRAME - 1
		DEFINE VRAM #addr, TILE_ROWS, VARPTR logoColorWhiteGreen(sine(logoOffset - I))
		#addr = #addr + TILE_ROWS
	NEXT I
	END

sine:
	DATA BYTE 1,1,2,3,4,5,6,7,8,8,7,6,5,4,3,2,1,1,2,3,4,5,6,7,8,8,7,6,5,4,3,2


' ==========================================
' Handle liquid flow logic and animations
' ------------------------------------------

flowTick: PROCEDURE
	IF (gameFrame AND currentSpeed) <> 0 THEN RETURN

.startFlow:
	
	' skip frames for flow speed
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
			gameState = GAME_STATE_ENDED
			gameSeconds = 0 
		END IF
	ELSEIF animTile = 1 THEN
		currentSubTile = SUBTILE_MC
		IF currentAnim AND $80 THEN skipAnim = 1
	ELSEIF animTile = 2 THEN
		currentFlowDir = currentAnim AND 3
		currentSubTile = subTileForFlow1(currentFlowDir)

		lastAnimSprX = animSprX
		lastAnimSprY = animSprY
		lastFlowDir = currentFlowDir AND 3

	ELSE
		currentAnimStep = 0
		animSubStep = 7	' ensure flow sprite is hidden

		prevTileX = currentTileX
		prevTileY = currentTileY

		currentIndex = currentIndex + offsetForFlow2(currentFlowDir)

		currentTileX = currentIndex % PLAYFIELD_WIDTH
		currentTileY = currentIndex / PLAYFIELD_WIDTH
		IF prevTileX <> currentTileX AND prevTileY <> currentTileY THEN
			tileId = 0
		ELSE
			animNameX = PLAYFIELD_X + currentTileX * 3
			animNameY = PLAYFIELD_Y + currentTileY * 3
			#currentIndexAddr = #VDP_NAME_TAB + XY(animNameX, animNameY)
			tileId = game(currentIndex) AND CELL_TILE_MASK
		END IF

		IF tileId < 2 THEN
			gameState = GAME_STATE_ENDED
			gameSeconds = 0
		ELSE
			game(currentIndex) = tileId OR CELL_LOCKED_FLAG
			#score = #score + POINTS_FLOW_TILE
			IF (remainingPipes) THEN remainingPipes = remainingPipes - 1
			GOSUB updateScore
		END IF
		currentAnim = anims(tileId * 4 + (currentAnim AND 3))
		GOTO .startFlow
	END IF

	currentIndexPattId = (VPEEK(#currentIndexAddr + currentSubTile) - 158) * 8

	IF skipAnim AND (currentSubTile = SUBTILE_MC) THEN
		' do nothing
	ELSEIF currentSubTile = SUBTILE_MC AND ((currentAnim XOR (currentAnim / 16)) AND 3) THEN
		GOSUB .flowSpriteCorner
	ELSE
		GOSUB .flowSpriteStraight
	END IF

	IF animSubStep = 7 AND skipAnim = 0 THEN
		IF currentAnimStep > 0 THEN
			I = VPEEK(#currentIndexAddr + currentSubTile)
			VPOKE #currentIndexAddr + currentSubTile, I + 10
		END IF

		flowAnimTemp = 0
		FOR I = 0 TO 7
			flowAnimBuffer(I) = 0
		NEXT I

		DEFINE VRAM #VDP_SPRITE_PATT + 4 * 8, 8, VARPTR flowAnimBuffer(0)
		SPRITE 4, animSprY - 1, animSprX, 4, VDP_TRANSPARENT
	ELSE
		animSprX = (animNameX + (currentSubTile AND 3)) * 8
		animSprY = (animNameY + (currentSubTile / 32)) * 8

		DEFINE VRAM #VDP_SPRITE_PATT + 4 * 8, 8, VARPTR flowAnimBuffer(0)
		SPRITE 4, animSprY - 1, animSprX, 4, FLOW_COLOR
	END IF

	IF gameState = GAME_STATE_ENDED THEN GOSUB renderCursor

	END

' generate dynamic sprite pattern data for H/V liquid flow
.flowSpriteStraight: PROCEDURE
	CONST #TILE_BASE_ADDR = #VDP_PATT_TAB1 + (158 * 8)
	SELECT CASE currentFlowDir
		CASE FLOW_LEFT
			flowAnimTemp = (flowAnimTemp * 2) OR $01

			DEFINE VRAM READ #TILE_BASE_ADDR + currentIndexPattId, 8, VARPTR flowAnimBuffer(0)
			FOR I = 0 TO 7
				' NABU: For some reason  flowAnimTemp AND NOT pipes(currentIndexPattId + I))
				'       doesn't work. results in $ff
				flowAnimBuffer(I) = (NOT flowAnimBuffer(I)) AND flowAnimTemp
			NEXT I
		CASE FLOW_RIGHT
			DEFINE VRAM READ #TILE_BASE_ADDR + currentIndexPattId, 8, VARPTR flowAnimBuffer(0)
			flowAnimTemp = (flowAnimTemp / 2) OR $80
			FOR I = 0 TO 7
				flowAnimBuffer(I) = NOT flowAnimBuffer(I) AND flowAnimTemp
			NEXT I
		CASE FLOW_UP
			I = VPEEK(#TILE_BASE_ADDR + currentIndexPattId + 7 - animSubStep)
			flowAnimBuffer(7 - animSubStep) = NOT I
		CASE FLOW_DOWN
			I = VPEEK(#TILE_BASE_ADDR + currentIndexPattId + animSubStep)
			flowAnimBuffer(animSubStep) = NOT I
	END SELECT
	END	

' generate dynamic sprite pattern data for turning liquid flow
.flowSpriteCorner: PROCEDURE
	offset = animSubStep * 8
	SELECT CASE currentAnim
		CASE ANIM_FLOW_RIGHT_UP
			FOR I = 0 TO 7
				flowAnimBuffer(I) = reverseBits(cornerFlowLeftUp(offset + I))
			NEXT I
		CASE ANIM_FLOW_RIGHT_DOWN
			offset = offset + 7
			FOR I = 0 TO 7
				flowAnimBuffer(I) = reverseBits(cornerFlowLeftUp(offset - I))
			NEXT I
		CASE ANIM_FLOW_DOWN_LEFT
			FOR I = 0 TO 7
				flowAnimBuffer(I) = cornerFlowDownLeft(offset + I)
			NEXT I
		CASE ANIM_FLOW_DOWN_RIGHT
			FOR I = 0 TO 7
				flowAnimBuffer(I) = reverseBits(cornerFlowDownLeft(offset + I))
			NEXT I
		CASE ANIM_FLOW_LEFT_UP
			FOR I = 0 TO 7
				flowAnimBuffer(I) = cornerFlowLeftUp(offset + I)
			NEXT I
		CASE ANIM_FLOW_LEFT_DOWN
			offset = offset + 7
			FOR I = 0 TO 7
				flowAnimBuffer(I) = cornerFlowLeftUp(offset - I)
			NEXT I
		CASE ANIM_FLOW_UP_LEFT
			offset = offset + 7
			FOR I = 0 TO 7
				flowAnimBuffer(I) = cornerFlowDownLeft(offset - I)
			NEXT I
		CASE ANIM_FLOW_UP_RIGHT
			offset = offset + 7
			FOR I = 0 TO 7
				flowAnimBuffer(I) = reverseBits(cornerFlowDownLeft(offset - I))
			NEXT I
	END SELECT
	END

' which subtile will be next for each stage of animation?
' entries for liquid coming into left, top, right, bottom edges respectively

subTileForFlow0:	' first stage - entry subtile
	DATA BYTE SUBTILE_ML, SUBTILE_TC, SUBTILE_MR, SUBTILE_BC
subTileForFlow1:	' second stage - exit subtile
	DATA BYTE SUBTILE_MR, SUBTILE_BC, SUBTILE_ML, SUBTILE_TC
offsetForFlow2:		' third stage - offset to next tile
	DATA BYTE 1, PLAYFIELD_WIDTH, -1, -PLAYFIELD_WIDTH

' animation ids for liquid hitting the left, top, right and bottom edges of each tile id
anims:
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID	' null
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID    ' grid
	DATA BYTE ANIM_FLOW_RIGHT,      ANIM_FLOW_INVALID,    ANIM_FLOW_LEFT,      ANIM_FLOW_INVALID    ' horz
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_DOWN,       ANIM_FLOW_INVALID,   ANIM_FLOW_UP         ' vert
	DATA BYTE ANIM_FLOW_RIGHT OR ANIM_FLOW_SKIP,      ANIM_FLOW_DOWN,       ANIM_FLOW_LEFT OR ANIM_FLOW_SKIP,      ANIM_FLOW_UP   ' cross
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_LEFT_DOWN, ANIM_FLOW_UP_RIGHT   ' bottom/right corner
	DATA BYTE ANIM_FLOW_RIGHT_DOWN, ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_UP_LEFT    ' bottom/left corner
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_DOWN_RIGHT, ANIM_FLOW_LEFT_UP,   ANIM_FLOW_INVALID    ' top/right corner
	DATA BYTE ANIM_FLOW_RIGHT_UP,   ANIM_FLOW_DOWN_LEFT,  ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID    ' top/left corner
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID    ' start left
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID    ' start top
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID    ' start right
	DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID    ' start down


' ==========================================
' Handle user input and UI interaction
' ------------------------------------------
uiTick: PROCEDURE

	' get user input
	GOSUB updateNavInput
	savedNav = savedNav OR g_nav

	' when a button is pressed, we delay some frames before triggering
	' it again. unless the user releases all buttons, then we skip the delay
	IF g_nav > 0 AND delayFrames > 0 THEN
		delayFrames = delayFrames - 1
		J = RANDOM(255)	' help randomize
		RETURN
	END IF

	' handle user input
	delayFrames = nextDelayFrames
	nextDelayFrames = 4
	IF hoverFfwd AND gameState <> GAME_STATE_ENDED THEN
		IF NAV(NAV_RIGHT) THEN
			hoverFfwd = FALSE
			GOSUB renderFfwdButton
		ELSEIF NAV(NAV_OK) THEN
			currentSpeed = 0
			hoverFfwd = FALSE
			GOSUB updateCursorPos
		END IF
	ELSEIF NAV(NAV_OK) AND gameState <> GAME_STATE_ENDED THEN
		tileId = game(cursorIndex)
		IF (tileId AND CELL_LOCKED_FLAG) = 0 THEN
			GOSUB placeTile
		END IF
	ELSEIF NAV(NAV_RIGHT) AND cursorX < (PLAYFIELD_WIDTH - 1) THEN
			cursorX = cursorX + 1
			GOSUB updateCursorPos
	ELSEIF NAV(NAV_LEFT) THEN
		IF cursorX > 0 THEN
			cursorX = cursorX - 1
			GOSUB updateCursorPos
		ELSEIF gameState = GAME_STATE_FLOWING THEN
			hoverFfwd = TRUE
			GOSUB renderFfwdButton
		END IF
	ELSEIF NAV(NAV_DOWN) AND cursorY < (PLAYFIELD_HEIGHT - 1) THEN
		cursorY = cursorY + 1
		GOSUB updateCursorPos
	ELSEIF NAV(NAV_UP) AND cursorY > 0 THEN
		cursorY = cursorY - 1
		GOSUB updateCursorPos
	ELSE
		delayFrames = 0
		nextDelayFrames = 12

		' help randomize a bit more
		FOR I = 0 TO (cursorY + cursorX) AND 3
			J = RANDOM(255)
		NEXT I
	END IF

	' render the tile chute if it's not settled
	IF gameState <> GAME_STATE_ENDED AND chuteOffset <> 0 THEN
		chuteOffset = chuteOffset - 1
		GOSUB renderChute
	END IF

	' place and color the cursor
	GOSUB renderCursor
	END

' ==========================================
' Place a tile - render it to screen
'   INPUTS: tileId, cursorIndex
' ------------------------------------------
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

	SOUND 3, 6, 5
	silentFrame = gameFrame + 3

	END

' ==========================================
' Render the entire tile chute
' ------------------------------------------
renderChute: PROCEDURE
	g_cell = CHUTE_SIZE
	FOR I = 0 TO CHUTE_SIZE
		g_cell = g_cell - 1
		g_type = chute(I)
		GOSUB renderChuteCell
	NEXT I
	END
	

renderChuteCell: PROCEDURE
	nameX = CHUTE_X
	nameY = (CHUTE_Y + (g_cell * 3)) - chuteOffset
	IF nameY > 23 OR  nameY < PLAYFIELD_Y THEN RETURN

	GOSUB renderCell
	END

' ==========================================
' Render a game cell (in the playfield)
'   INPUTS: g_cell, g_type
' ------------------------------------------
renderGameCell: PROCEDURE
	nameX = PLAYFIELD_X + (g_cell % PLAYFIELD_WIDTH) * 3
	nameY = PLAYFIELD_Y + (g_cell / PLAYFIELD_WIDTH) * 3

	GOSUB renderCell
	END	

' ==========================================
' Render a game cell (any location)
'   INPUTS: g_type, nameX, nameY
' ------------------------------------------
renderCell: PROCEDURE 
	index = g_type * 9

	#addr = NAME_TAB_XY(nameX, nameY)

	FOR J = 0 TO 2
		IF nameY > 23 THEN RETURN
		IF nameY >= PLAYFIELD_Y THEN DEFINE VRAM #addr, 3, VARPTR cellNames(index)
		index = index + 3
		nameY = nameY + 1
		#addr = #addr + 32
	NEXT J
	END

' ==========================================
' Update the cursor position
'   INPUTS: cursorX, cursorY
' ------------------------------------------
updateCursorPos: PROCEDURE
	spriteX = PLAYFIELD_X * 8 + (cursorX * 24) - 1
	spriteY = PLAYFIELD_Y * 8 + (cursorY * 24) - 2
	
	cursorIndex = cursorY * PLAYFIELD_WIDTH + cursorX
	END

' ==========================================
' Render the cursor
' ------------------------------------------
renderCursor: PROCEDURE
	CONST CURSOR_SIZE   = 33
	CONST CURSOR_SPREAD = CURSOR_SIZE - 16

	IF gameFrame AND 8 THEN color = VDP_GREY ELSE color = VDP_WHITE 
	IF game(cursorIndex) AND CELL_LOCKED_FLAG THEN color = VDP_MED_RED
	IF (gameState = GAME_STATE_ENDED) OR hoverFfwd THEN
		 color = VDP_TRANSPARENT
		 spriteY = -24
	END IF

	SPRITE CURSOR_SPRITE_ID + 0, spriteY, spriteX, CURSOR_SPRITE_PATT_ID + 0, color
	SPRITE CURSOR_SPRITE_ID + 1, spriteY + CURSOR_SPREAD, spriteX, CURSOR_SPRITE_PATT_ID + 1, color
	SPRITE CURSOR_SPRITE_ID + 2, spriteY, spriteX + CURSOR_SPREAD, CURSOR_SPRITE_PATT_ID + 2, color
	SPRITE CURSOR_SPRITE_ID + 3, spriteY + CURSOR_SPREAD, spriteX + CURSOR_SPREAD, CURSOR_SPRITE_PATT_ID + 3, color
	END

renderFfwdButton: PROCEDURE
	IF hoverFfwd THEN
		DEFINE VRAM PLETTER #VDP_PATT_TAB3, 6 * 8, ffwdPattHoverPletter
		DEFINE VRAM PLETTER #VDP_COLOR_TAB3, 6 * 8, ffwdColorHoverPletter
	ELSE
		DEFINE VRAM PLETTER #VDP_PATT_TAB3, 6 * 8, ffwdPattPletter
		DEFINE VRAM PLETTER #VDP_COLOR_TAB3, 6 * 8, ffwdColorPletter
	END IF
	GOSUB updateCursorPos
	END

#if SHOW_TITLE
include "title.bas"
#endif

include "font.pletter.bas"
include "logo.pletter.bas"
include "sprites.pletter.bas"
include "tiles.pletter.bas"
include "patterns.bas"
include "lookups.bas"

