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

CONST FFWD_PATT_ID 		= 24

CONST GAME_STATE_BUILDING = 0
CONST GAME_STATE_FLOWING  = 1
CONST GAME_STATE_ENDED   = 2

CONST GAME_START_DELAY_SECONDS = 10
CONST GAME_START_DELAY_SECONDS_SLIDE_MODE = 30

CONST CURSOR_SPRITE_ID         = 0
CONST FLOW_SPRITE_ID           = 4
CONST SPILL_SPRITE_ID          = FLOW_SPRITE_ID
CONST CRACK_SPRITE_ID          = 5
CONST EXPLODE_SPRITE_ID        = 6
CONST EXPLODE_SPRITE_ID_CNT    = 4

CONST CURSOR_SPRITE_PATT_ID    = 0
CONST CURSOR_SPRITE_COUNT      = 4
CONST FLOW_SPRITE_PATT_ID      = CURSOR_SPRITE_PATT_ID + CURSOR_SPRITE_COUNT
CONST FLOW_SPRITE_COUNT        = 1
CONST SPILL_SPRITE_PATT_ID     = FLOW_SPRITE_PATT_ID + FLOW_SPRITE_COUNT
CONST SPILL_SPRITE_COUNT       = 6
CONST CRACK_SPRITE_PATT_ID     = SPILL_SPRITE_PATT_ID + SPILL_SPRITE_COUNT
CONST CRACK_SPRITE_COUNT       = 4
CONST EXPLODE_SPRITE_PATT_ID   = CRACK_SPRITE_PATT_ID + CRACK_SPRITE_COUNT
CONST EXPLODE_SPRITE_COUNT     = 6

CONST LOADING_STRING_COUNT     = 10
CONST LOADING_STRING_LEN       = 20

CONST POINTS_BUILD   		= 100
CONST POINTS_REPLACE_DEDUCT = 50
CONST POINTS_FLOW_TILE      = 100
CONST #POINTS_LEVEL_COMPLETE = 1000

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
DIM levelSpeed
DIM hoverFfwd
DIM replaceFrame
DIM isReplacing

DIM #lastTileNameIndex

DIM flowAnimTemp
DIM flowAnimBuffer(8)
DIM silentFrame

DIM scoreCurrentOffset(5)
DIM scoreDesiredOffset(5)

SIGNED scoreCurrentOffset, scoreDesiredOffset

DIM savedNav
DIM spillSpriteId

CONST SLIDE_MODE = 1


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

DIM progressCount

progressTick: PROCEDURE
	VPOKE #addr, 31 : #addr = #addr + 1
	IF ((progressCount - 1) % 7) = 0 THEN
		FILL_BUFFER(" ")
		pun = RANDOM(LOADING_STRING_COUNT)
		DEFINE VRAM #VDP_NAME_TAB1 + 22 * 32 + 12, 20, VARPTR loadingStrings(pun * LOADING_STRING_LEN)
	END IF
	progressCount = progressCount + 1
	END



' ==========================================
' ACTUAL ENTRY POINT
' ------------------------------------------
main:
	vdpR1Flags = $02
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

	FILL_BUFFER(" ")
	#addr = #VDP_NAME_TAB1
	FOR I = 0 TO 23
		DEFINE VRAM #addr, 32, VARPTR rowBuffer(0)
		#addr = #addr + 32
	NEXT I

	SPRITE FLICKER OFF	' the CVB sprite flicker routine messes with things. turn it off

'	VDP_DISABLE_INT

	DEFINE CHAR PLETTER 64, 32, font1Pletter
	DEFINE CHAR PLETTER 32, 32, font0Pletter
	
	FOR I = 32 TO 127
		DEFINE COLOR I, 1, fontColor
	NEXT I

    DEFINE CHAR PLETTER 0, 24, logoTopPletter
	DEFINE VRAM #VDP_NAME_TAB1 + 22*32, 12, logoNamesTop
	DEFINE VRAM #VDP_NAME_TAB1 + 23*32, 12, logoNamesBottom
	DEFINE CHAR 31, 1, tilePiece	' remaining pipes
	DEFINE COLOR 31, 1, tilePieceColor

#if SHOW_TITLE
	GOSUB titleScreen
#endif

    VDP_ENABLE_INT

	#addr = #VDP_NAME_TAB1 + (23 * 32) + 12
	DEFINE CHAR 31, 1, tilePiece	' remaining pipes

#if SHOW_TITLE
	FOR I = 0 TO 254
		DEFINE COLOR I, 1, defaultColor
	NEXT I
	DEFINE COLOR 31, 1, tilePieceColor

	GOSUB progressTick
	DEFINE CHAR PLETTER 64, 32, font1Pletter
	GOSUB progressTick
	DEFINE CHAR PLETTER 32, 32, font0Pletter
	GOSUB progressTick
	DEFINE CHAR PLETTER 96, 32, font2Pletter
	GOSUB progressTick

	FOR I = 24 TO 30
		DEFINE COLOR I, 1, fontColor
	NEXT I

	FOR I = 128 TO 254
		DEFINE COLOR I, 1, defaultColor
	NEXT I

	GOSUB progressTick
#endif



	' title / logo patterns

    DEFINE CHAR PLETTER 128, 30, gridPletter

	GOSUB progressTick

    DEFINE COLOR PLETTER 128, 18, gridColorPletter

	GOSUB progressTick

	' tile patterns and colors
	FOR I = 137 TO 175
	    DEFINE COLOR I, 1, baseColor
	NEXT I

	GOSUB progressTick

    DEFINE CHAR PLETTER 158, 10, pipesPletter	' empty pipes

	GOSUB progressTick

    DEFINE CHAR PLETTER 168, 10, pipesPletter	' full pipes

	GOSUB progressTick

	FOR I = 158 TO 167
	    DEFINE COLOR I, 1, pipeColor
	NEXT I
	GOSUB progressTick

	FOR I = 168 TO 177
	    DEFINE COLOR I, 1, pipeColorGreen
	NEXT I
	GOSUB progressTick

	' score patterns (dynamic rolling digits)
	FOR I = 0 TO 4
		scoreCurrentOffset(I) = 0
		DEFINE VRAM #VDP_PATT_TAB1 + ((24 + I) * 8), 8, VARPTR digits(0)
		'DEFINE COLOR 24 + I, 1, digitColor
	NEXT I
	GOSUB progressTick


	' gamefield patterns
    DEFINE CHAR PLETTER 178, 7, bordersPletter

	' set up the name table
	' ------------------------------
	DEFINE VRAM NAME_TAB_XY(0, 0), 12, logoNamesTop
	DEFINE VRAM NAME_TAB_XY(0, 1), 12, logoNamesBottom

	GOSUB progressTick

	CONST CHUTE_BOTTOM = PLAYFIELD_Y + CHUTE_SIZE * 3

	' vertical left chute and border
	FOR I = PLAYFIELD_Y TO CHUTE_BOTTOM - 1
		DEFINE VRAM NAME_TAB_XY(0, I), 5, chuteNames
	NEXT I

	GOSUB progressTick

	FOR I = CHUTE_BOTTOM + 1 TO 23
		PUT_XY(4, I), 183
	NEXT I

	GOSUB progressTick

	' sprite patterns
	DEFINE SPRITE PLETTER CURSOR_SPRITE_PATT_ID, CURSOR_SPRITE_COUNT, cursorSpritesPletter
	GOSUB progressTick
	DEFINE SPRITE PLETTER SPILL_SPRITE_PATT_ID, SPILL_SPRITE_COUNT, spillPattPletter
	GOSUB progressTick
	DEFINE SPRITE PLETTER CRACK_SPRITE_PATT_ID, CRACK_SPRITE_COUNT, crackPattPletter
	GOSUB progressTick
	DEFINE SPRITE PLETTER EXPLODE_SPRITE_PATT_ID, EXPLODE_SPRITE_COUNT, explodePattPletter
	GOSUB progressTick

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

	hoverFfwd = 0

	currentSpeed = 8
	J = currentLevel / 3
	WHILE J
		currentSpeed = currentSpeed / 2
		J = J - 1
	WEND	
	IF currentSpeed < 2 THEN currentSpeed = 2
	currentSpeed = currentSpeed - 1	
	levelSpeed = currentSpeed

	' horizontal top border
	FILL_BUFFER(184)
	DEFINE VRAM NAME_TAB_XY(0, 2), 31, VARPTR rowBuffer(0)

	GOSUB renderFfwdButton
	GOSUB updateCursorPos


	SPRITE FLOW_SPRITE_ID, 0, 0, FLOW_SPRITE_PATT_ID * 4, VDP_TRANSPARENT

	' render chute bottom
	DEFINE VRAM NAME_TAB_XY(0, PLAYFIELD_Y + CHUTE_SIZE * 3), 5, chuteBottomNames

	' clear dynamic flow sprite patterns
	FILL_BUFFER(0)
	DEFINE VRAM #VDP_SPRITE_PATT + FLOW_SPRITE_PATT_ID * 32, 32, VARPTR rowBuffer(0)

	FOR I = 0 TO CHUTE_SIZE - 1
		chute(I) = RANDOM(7) + 2
		'WAIT
	NEXT I
	chute(CHUTE_SIZE) = CELL_CLEAR

	PRINT AT XY(20,0), "LEVEL: ", currentLevel
	PRINT AT XY(20,1), "SCORE: \24\25\26\27\28"
	GOSUB updateScore

	chuteOffset = 20

	IF SLIDE_MODE THEN
		FOR I = 0 TO PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH - 1
			game(I) = RANDOM(7) + 2
		NEXT I
	ELSE
		FOR I = 0 TO PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH - 1
			game(I) = CELL_GRID
		NEXT I
	END IF

	' start tile position
	currentTileX = RANDOM(PLAYFIELD_WIDTH - 3) + 2
	currentTileY = RANDOM(PLAYFIELD_HEIGHT - 3) + 2
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

	IF SLIDE_MODE THEN
		emptyIndex = currentIndex + offsetForFlow2(I)
		game(emptyIndex) = CELL_GRID
	END IF

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
	spillSpriteId = SPILL_SPRITE_PATT_ID
	currentStartDelay = GAME_START_DELAY_SECONDS - currentLevel
	IF SLIDE_MODE THEN currentStartDelay = currentStartDelay * 4

	IF currentStartDelay < 5 THEN currentStartDelay = 5

	NAME_TABLE0

	' main game loop
	WHILE 1
		WAIT

		if gameFrame = silentFrame THEN SOUND 3,,0

		IF gameState = GAME_STATE_FLOWING THEN
			GOSUB flowTick
		ELSEIF gameSeconds = currentStartDelay THEN
			gameState = GAME_STATE_FLOWING
			FOR J = 0 TO 5 : rowBuffer(J) = J + FFWD_PATT_ID : NEXT J
			DEFINE VRAM NAME_TAB_XY(1, CHUTE_BOTTOM + 1), 3, VARPTR rowBuffer(0)
			DEFINE VRAM NAME_TAB_XY(1, CHUTE_BOTTOM + 2), 3, VARPTR rowBuffer(3)
		ELSEIF gameState = GAME_STATE_ENDED THEN
			IF gameSeconds < 2 THEN
				chuteOffset = chuteOffset - 1
				IF remainingPipes THEN
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
		IF isReplacing THEN GOSUB replaceTick
		
		gameFrame = gameFrame + 1 ' not using FRAME to ensure consistency in case of skipped frames
		IF (gameFrame AND $3f) = 0 THEN	' very rough seconds. 64 ticks so will be slow at 50FPS
			gameSeconds = gameSeconds + 1
		END IF
	WEND

	' copy screen to name table 1
	#addr = 0
	FOR I = 0 TO 23
		DEFINE VRAM READ #VDP_NAME_TAB + #addr, 32, VARPTR rowBuffer(0)
		DEFINE VRAM #VDP_NAME_TAB1 + #addr, 32, VARPTR rowBuffer(0)
		#addr = #addr + 32
	NEXT I
	
	NAME_TABLE1
	END

levelEnd: PROCEDURE
	gameState = GAME_STATE_ENDED
	gameSeconds = 0
	IF remainingPipes = 0 THEN
		#score = #score + #POINTS_LEVEL_COMPLETE
		GOSUB updateScore
	END IF
	END

replaceTick: PROCEDURE

	ticks = gameFrame - replaceFrame

	IF ticks < 24 THEN
		SPRITE CRACK_SPRITE_ID, spriteY + 4, spriteX + 4, (CRACK_SPRITE_PATT_ID + ticks / 6) * 4, VDP_GREY
		SPRITE CRACK_SPRITE_ID, spriteY + 4, spriteX + 4, (CRACK_SPRITE_PATT_ID + ticks / 6) * 4, VDP_GREY
		xOff = 0
		yOff = 0
	END IF
	IF gameState <> GAME_STATE_ENDED THEN

		IF ticks >= 24 THEN
			IF (ticks AND 3) = 0 THEN
				xOff = xOff + 3
				yOff = yOff + 2
			END IF
			sprOff = (ticks - 24) AND $fc
			SPRITE CRACK_SPRITE_ID, spriteY + yOff, spriteX + 4 + xOff, EXPLODE_SPRITE_PATT_ID * 4 + sprOff, VDP_DK_BLUE
			SPRITE EXPLODE_SPRITE_ID, spriteY + yOff, spriteX + 4 - xOff, EXPLODE_SPRITE_PATT_ID * 4 + sprOff, VDP_DK_BLUE
		END IF
		IF ticks = 32 THEN
			g_type = 0
			GOSUB renderGameCell
		ELSEIF ticks = 40 THEN
			isReplacing = FALSE
			tileId = 0
			GOSUB placeTile
			isReplacing = TRUE
		END IF
	END IF
	IF ticks = 48 THEN
		isReplacing = FALSE
		SPRITE CRACK_SPRITE_ID, $d0, 0, CRACK_SPRITE_PATT_ID * 4, VDP_TRANSPARENT
		SPRITE EXPLODE_SPRITE_ID, $d0, 0, CRACK_SPRITE_PATT_ID * 4, VDP_TRANSPARENT
	END IF	
	END

' ==========================================
' Handle liquid spill animation
' ------------------------------------------
spillTick: PROCEDURE
	IF (gameFrame AND 7) OR (spillSpriteId >= SPILL_SPRITE_PATT_ID + SPILL_SPRITE_COUNT - 1) THEN RETURN

	spillSpriteId = spillSpriteId + 1

	SPRITE SPILL_SPRITE_ID, lastAnimSprY - .offsetY(lastFlowDir), lastAnimSprX - .offsetX(lastFlowDir), spillSpriteId * 4, FLOW_COLOR
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
			GOSUB levelEnd
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
			GOSUB levelEnd
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

		DEFINE VRAM #VDP_SPRITE_PATT + FLOW_SPRITE_PATT_ID * 32, 8, VARPTR flowAnimBuffer(0)
		SPRITE FLOW_SPRITE_ID, animSprY - 1, animSprX, FLOW_SPRITE_PATT_ID * 4, VDP_TRANSPARENT
	ELSE
		animSprX = (animNameX + (currentSubTile AND 3)) * 8
		animSprY = (animNameY + (currentSubTile / 32)) * 8

		DEFINE VRAM #VDP_SPRITE_PATT + FLOW_SPRITE_PATT_ID * 32, 8, VARPTR flowAnimBuffer(0)
		SPRITE FLOW_SPRITE_ID, animSprY - 1, animSprX, FLOW_SPRITE_PATT_ID * 4, FLOW_COLOR
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

	IF isReplacing THEN RETURN

	' get user input
	GOSUB updateNavInput
	savedNav = savedNav OR g_nav

	' when a button is pressed, we delay some frames before triggering
	' it again. unless the user releases all buttons, then we skip the delay
	IF g_nav > 0 AND delayFrames > 0 THEN
		delayFrames = delayFrames - 1
		J = RANDOM(g_nav)	' help randomize
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
			IF currentSpeed THEN
				currentSpeed = 0
			ELSE
				currentSpeed = levelSpeed
			END IF
			hoverFfwd = FALSE
			GOSUB renderFfwdButton
		END IF
	ELSEIF NAV(NAV_OK) AND gameState <> GAME_STATE_ENDED THEN
		IF SLIDE_MODE THEN
			GOSUB slideTile			
		ELSE
			tileId = game(cursorIndex)
			IF (tileId AND CELL_LOCKED_FLAG) = 0 THEN
				GOSUB placeTile
			END IF
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
			J = RANDOM(cursorY + cursorX)
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

slideTile: PROCEDURE
	IF NOT isValid THEN RETURN

	temp = game(cursorIndex)
	game(cursorIndex) = game(emptyIndex)
	game(emptyIndex) = temp
	g_cell = emptyIndex
	g_type = game(emptyIndex)
	GOSUB renderGameCell
	emptyIndex = cursorIndex
	g_cell = cursorIndex
	g_type = game(cursorIndex)
	GOSUB renderGameCell
	END

' ==========================================
' Place a tile - render it to screen
'   INPUTS: tileId, cursorIndex
' ------------------------------------------
placeTile: PROCEDURE
	tileId = tileId AND CELL_TILE_MASK
	IF tileId > 0 THEN
		#score = #score - (POINTS_REPLACE_DEDUCT + POINTS_BUILD)
		
		' test going negative
		IF #score > 65485 then #score = 0

		isReplacing = TRUE
		replaceFrame = gameFrame

		g_type = chute(0)
		g_cell = cursorIndex
		game(cursorIndex) = g_type

		RETURN
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

	IF SLIDE_MODE THEN
		isValid = FALSE
		IF color <> VDP_MED_RED THEN
			cursorX = cursorIndex % PLAYFIELD_WIDTH
			cursorY = cursorIndex / PLAYFIELD_WIDTH
			FOR I = 0 TO 3
				tempIndex = cursorIndex + offsetForFlow2(I)			
				tempIndexX = tempIndex % PLAYFIELD_WIDTH
				tempIndexY = tempIndex / PLAYFIELD_WIDTH
				IF NOT (tempIndexX <> cursorX AND tempIndexY <> cursorY) THEN
					IF game(tempIndex) = CELL_GRID THEN isValid = TRUE
				END IF
			NEXT I
			IF isValid = FALSE THEN color = VDP_MED_RED
		END IF
	END IF

	IF (gameState = GAME_STATE_ENDED) OR hoverFfwd THEN
		 color = VDP_TRANSPARENT
		 spriteY = -24
	END IF

	SPRITE CURSOR_SPRITE_ID + 0, spriteY, spriteX, CURSOR_SPRITE_PATT_ID + 0 * 4, color
	SPRITE CURSOR_SPRITE_ID + 1, spriteY + CURSOR_SPREAD, spriteX, CURSOR_SPRITE_PATT_ID + 1 * 4, color
	SPRITE CURSOR_SPRITE_ID + 2, spriteY, spriteX + CURSOR_SPREAD, CURSOR_SPRITE_PATT_ID + 2 * 4, color
	SPRITE CURSOR_SPRITE_ID + 3, spriteY + CURSOR_SPREAD, spriteX + CURSOR_SPREAD, CURSOR_SPRITE_PATT_ID + 3 * 4, color
	END

' ==========================================
' Render the fast forward button
' ------------------------------------------
renderFfwdButton: PROCEDURE
	IF hoverFfwd THEN
		DEFINE VRAM PLETTER #VDP_PATT_TAB3 + (FFWD_PATT_ID * 8), 6 * 8, ffwdPattHoverPletter
		DEFINE VRAM PLETTER #VDP_COLOR_TAB3 + (FFWD_PATT_ID * 8), 6 * 8, ffwdColorHoverPletter
	ELSE
		DEFINE VRAM PLETTER #VDP_PATT_TAB3 + (FFWD_PATT_ID * 8), 6 * 8, ffwdPattPletter
		DEFINE VRAM PLETTER #VDP_COLOR_TAB3 + (FFWD_PATT_ID * 8), 6 * 8, ffwdColorPletter
	END IF
	GOSUB updateCursorPos
	END

loadingStrings:
	DATA BYTE "    UNCLOGGING LOGIC"
	DATA BYTE " ROUTING PIPE DREAMS"
	DATA BYTE "      SIPHONING BITS"
	DATA BYTE "     ALIGNING ELBOWS"
	DATA BYTE "       HYDRATING RAM"
	DATA BYTE "         VALVE CHECK"
	DATA BYTE "       FLOW IMMINENT"
	DATA BYTE "  PARSING PIPE LOGIC"
	DATA BYTE " PRESSURIZING PIXELS"
	DATA BYTE "CONFIGURING COUPLERS"


#if SHOW_TITLE
include "title.bas"
#endif

include "font.pletter.bas"
include "logo.pletter.bas"
include "sprites.pletter.bas"
include "tiles.pletter.bas"
include "patterns.bas"
include "lookups.bas"

