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

DEF FN FLOW1(D)			= ((D * 16) OR D)
DEF FN FLOW2(D1, D2)    = ((D1 * 16) OR D2)

CONST ANIM_FLOW_NONE       = 0
CONST ANIM_FLOW_RIGHT      = FLOW1(FLOW_RIGHT)
CONST ANIM_FLOW_DOWN       = FLOW1(FLOW_DOWN)
CONST ANIM_FLOW_LEFT       = FLOW1(FLOW_LEFT)
CONST ANIM_FLOW_UP         = FLOW1(FLOW_UP)
CONST ANIM_FLOW_RIGHT_UP   = FLOW2(FLOW_RIGHT, FLOW_UP)
CONST ANIM_FLOW_RIGHT_DOWN = FLOW2(FLOW_RIGHT, FLOW_DOWN)
CONST ANIM_FLOW_DOWN_LEFT  = FLOW2(FLOW_DOWN, FLOW_LEFT)
CONST ANIM_FLOW_DOWN_RIGHT = FLOW2(FLOW_DOWN, FLOW_RIGHT)
CONST ANIM_FLOW_LEFT_UP    = FLOW2(FLOW_LEFT, FLOW_UP)
CONST ANIM_FLOW_LEFT_DOWN  = FLOW2(FLOW_LEFT, FLOW_DOWN)
CONST ANIM_FLOW_UP_LEFT    = FLOW2(FLOW_UP, FLOW_LEFT)
CONST ANIM_FLOW_UP_RIGHT   = FLOW2(FLOW_UP, FLOW_RIGHT)
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

CONST GAME_STATE_BUILDING   = 0
CONST GAME_STATE_FLOWING    = 1
CONST GAME_STATE_ENDED      = 2
CONST GAME_STATE_NEXT_LEVEL = 4

CONST GAME_START_DELAY_SECONDS = 15

' sprite indexes (sprite attribute table)
CONST CURSOR_SPRITE_ID         = 0
CONST FLOW_SPRITE_ID           = 4
CONST SPILL_SPRITE_ID          = FLOW_SPRITE_ID
CONST CRACK_SPRITE_ID          = 5
CONST EXPLODE_SPRITE_ID        = 6
CONST EXPLODE2_SPRITE_ID       = CRACK_SPRITE_ID
CONST EXPLODE_SPRITE_ID_CNT    = 4

' sprite pattern indexes (sprite pattern table)
' these will be multiplied by 4 to get the real pattern index
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

' tile pattern ids
CONST SCORE_PATT_ID            = 24 ' 24 - 28
CONST FFWD_PATT_ID             = 96    ' fast forward button
CONST FFWD_PATT_COUNT          = 12
CONST PIPES_PATT_ID            = 158   ' inner pipe tiles
CONST PIPES_PATT_COUNT         = 10
CONST PIPES_FILLED_PATT_ID     = PIPES_PATT_ID + PIPES_PATT_COUNT
CONST CHUTE_BORDERS_PATT_ID    = 178   ' chute ui tiles
CONST CHUTE_BORDERS_COUNT      = 7

CONST LOADING_STRING_COUNT     = 10
CONST LOADING_STRING_LEN       = 20

CONST POINTS_BUILD             = 100
CONST POINTS_REPLACE_DEDUCT    = 50
CONST POINTS_FLOW_TILE         = 100
CONST #POINTS_LEVEL_COMPLETE   = 1000

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
DIM currentAnimStep  ' 0 to 23
DIM #currentIndexAddr
DIM currentIndexPattId
DIM currentSpeed' 0, 1, 3, 7, 15 (inverse speed. actually frame delay)
DIM levelSpeed
DIM hoverFfwd
DIM replaceFrame
DIM isReplacing

DIM #lastTileNameIndex

DIM flowAnimTemp
DIM flowAnimBuffer(16)
DIM silentFrame

DIM scoreCurrentOffset(5)
DIM scoreDesiredOffset(5)

SIGNED scoreCurrentOffset, scoreDesiredOffset

DIM savedNav
DIM spillSpriteId

CONST SLIDE_MODE = 0

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


' since we have a non-ideal (not pow2) playfield area size
' added lookup tables for various operations on it

divNine: ' I / 9 (up to I = 63)
  DATA BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0
  DATA BYTE 1, 1, 1, 1, 1, 1, 1, 1, 1
  DATA BYTE 2, 2, 2, 2, 2, 2, 2, 2, 2
  DATA BYTE 3, 3, 3, 3, 3, 3, 3, 3, 3
  DATA BYTE 4, 4, 4, 4, 4, 4, 4, 4, 4
  DATA BYTE 5, 5, 5, 5, 5, 5, 5, 5, 5
  DATA BYTE 6, 6, 6, 6, 6, 6, 6, 6, 6

modNine:  ' I % 9 (up to I = 63)
  DATA BYTE 0, 1, 2, 3, 4, 5, 6, 7, 8
  DATA BYTE 0, 1, 2, 3, 4, 5, 6, 7, 8
  DATA BYTE 0, 1, 2, 3, 4, 5, 6, 7, 8
  DATA BYTE 0, 1, 2, 3, 4, 5, 6, 7, 8
  DATA BYTE 0, 1, 2, 3, 4, 5, 6, 7, 8
  DATA BYTE 0, 1, 2, 3, 4, 5, 6, 7, 8
  DATA BYTE 0, 1, 2, 3, 4, 5, 6, 7, 8

mulThree:  ' I * 3 (up to I = 31)
  DATA BYTE 0, 3, 6, 9, 12, 15, 18, 21
  DATA BYTE 24, 27, 30, 33, 36, 39, 42, 45
  DATA BYTE 48, 51, 54, 57, 60, 63, 66, 69
  DATA BYTE 72, 75, 78, 81, 84, 87, 90, 93

DEF FN TIMES_NINE(X) = ((X) * 8) + (X)  ' instead of times nine


CONST #SCORE_VRAM_ADDR    = #VDP_FREE_START

CONST FLOW_COLOR = VDP_MED_GREEN

DIM #progressCount
DIM #progressBarAddr

progressInit: PROCEDURE
  #progressCount = 0
  flowAnimTemp = 0
  #progressBarAddr = NAME_TAB1_XY(12, 23)
  FILL_BUFFER(30)
  DEFINE VRAM #progressBarAddr, 32-12, VARPTR rowBuffer(0)
  #baseAddr = #VDP_COLOR_TAB3
  DEFINE VRAM PLETTER $1F00, LOADING_STRING_LEN * LOADING_STRING_COUNT, loadingStringsPletter
  GOSUB progressLogoTick
  END

progressLogoTick: PROCEDURE
  FOR J = 0 TO 3
    GOSUB logoTick
    gameFrame = gameFrame + 1
  NEXT J
  END

progressTick: PROCEDURE
  WAIT
  VPOKE #progressBarAddr, 31 : #progressBarAddr = #progressBarAddr + 1
  WAIT
  GOSUB progressLogoTick
  WAIT

  IF (FRAME - #progressCount) > 25 THEN
    #progressCount = FRAME
    WHILE flowAnimBuffer(quipIndex)
      quipIndex = RANDOM(LOADING_STRING_COUNT)
    WEND
    flowAnimBuffer(quipIndex) = TRUE
    DEFINE VRAM READ $1F00 + quipIndex * LOADING_STRING_LEN, LOADING_STRING_LEN, VARPTR rowBuffer(0)
    DEFINE VRAM NAME_TAB1_XY(12, 22), LOADING_STRING_LEN, VARPTR rowBuffer(0)
    flowAnimTemp = flowAnimTemp + 1
  END IF
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
    DEFINE VRAM #addr, NAME_TABLE_WIDTH, VARPTR rowBuffer(0)
    #addr = #addr + NAME_TABLE_WIDTH
  NEXT I

  SPRITE FLICKER OFF  ' the CVB sprite flicker routine messes with things. turn it off

'  VDP_DISABLE_INT

  DEFINE CHAR PLETTER 64, 32, font1Pletter
  DEFINE CHAR PLETTER 32, 32, font0Pletter
  
  FOR I = 32 TO 127
    DEFINE COLOR I, 1, fontColor
  NEXT I

  DEFINE CHAR PLETTER 0, 24, logoTopPletter
  DEFINE VRAM NAME_TAB1_XY(0, 22), 12, logoNamesTop
  DEFINE VRAM NAME_TAB1_XY(0, 23), 12, logoNamesBottom
  DEFINE CHAR 30, 1, tilePiece
  DEFINE CHAR 31, 1, tilePiece  ' remaining pipes
  DEFINE COLOR 30, 1, tilePieceColorEmpty
  DEFINE COLOR 31, 1, tilePieceColor

#if SHOW_TITLE
  GOSUB titleScreen
#endif

  VDP_ENABLE_INT
  GOSUB progressInit
  WAIT
  NAME_TABLE1

#if SHOW_TITLE
  FOR I = 32 TO 254
    DEFINE COLOR I, 1, defaultColor
  NEXT I
  GOSUB progressTick
  FOR I = 128 TO 254
    DEFINE COLOR I, 1, defaultColor
  NEXT I
  DEFINE COLOR 31, 1, tilePieceColor

  GOSUB progressTick
  DEFINE CHAR PLETTER 64, 32, font1Pletter
  GOSUB progressTick
  DEFINE CHAR PLETTER 32, 32, font0Pletter
  GOSUB progressTick
  'DEFINE CHAR PLETTER 96, 32, font2Pletter
  'GOSUB progressTick
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

    DEFINE CHAR PLETTER PIPES_PATT_ID, PIPES_PATT_COUNT, pipesPletter  ' empty pipes

  GOSUB progressTick

    DEFINE CHAR PLETTER PIPES_FILLED_PATT_ID, PIPES_PATT_COUNT, pipesPletter  ' full pipes

  GOSUB progressTick

  FOR I = PIPES_PATT_ID TO PIPES_PATT_ID + PIPES_PATT_COUNT - 1
      DEFINE COLOR I, 1, pipeColor
  NEXT I
  GOSUB progressTick

  FOR I = PIPES_FILLED_PATT_ID TO PIPES_FILLED_PATT_ID + PIPES_PATT_COUNT - 1
      DEFINE COLOR I, 1, pipeColorGreen
  NEXT I
  GOSUB progressTick

  ' score patterns (dynamic rolling digits)
  FOR I = 0 TO 4
    scoreCurrentOffset(I) = 0
    DEFINE VRAM #VDP_PATT_TAB1 + PATT_OFFSET(SCORE_PATT_ID + I), 8, VARPTR digits(0)
    'DEFINE COLOR 24 + I, 1, digitColor
  NEXT I
  GOSUB progressTick


  ' gamefield patterns
    DEFINE CHAR PLETTER CHUTE_BORDERS_PATT_ID, CHUTE_BORDERS_COUNT, bordersPletter

  GOSUB progressTick

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

  DEFINE VRAM PLETTER #VDP_PATT_TAB3 + (FFWD_PATT_ID * TILE_SIZE), FFWD_PATT_COUNT * TILE_SIZE, ffwdPattPletter
  DEFINE VRAM PLETTER #VDP_COLOR_TAB3 + (FFWD_PATT_ID * TILE_SIZE), FFWD_PATT_COUNT * TILE_SIZE, ffwdColorPletter

  GOSUB progressTick

  currentLevel = 1
  #score = 0

  #baseAddr = #VDP_COLOR_TAB1

  WHILE 1
    GOSUB pipeGame
  WEND

pipeGame: PROCEDURE
  cursorX = 4
  cursorY = 3
  remainingPipes = 13 + currentLevel
  IF remainingPipes > 24 THEN remainingPipes = 24

  hoverFfwd = FALSE

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
    J = 255
    FOR I = 0 TO PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH - 1
      FOR X = 0 TO game(I - 1) : R = RANDOM(255) : NEXT
      DO
        game(I) = RANDOM(7) + 2
      LOOP WHILE game(I) = J
      J = game(I)
    NEXT I
    currentTileX = RANDOM(PLAYFIELD_WIDTH - 6) + 3
    currentTileY = RANDOM(PLAYFIELD_HEIGHT - 6) + 3
  ELSE
    FOR I = 0 TO PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH - 1
      FOR X = 0 TO game(I - 1) : R = RANDOM(255) : NEXT
      game(I) = CELL_GRID
    NEXT I
    currentTileX = RANDOM(PLAYFIELD_WIDTH - 2) + 1
    currentTileY = RANDOM(PLAYFIELD_HEIGHT - 2) + 1
  END IF

  ' start tile position
  currentIndex = currentTileY * PLAYFIELD_WIDTH + currentTileX

  animNameX = PLAYFIELD_X + mulThree(modNine(currentIndex))
  animNameY = PLAYFIELD_Y + mulThree(divNine(currentIndex))
  #currentIndexAddr = #VDP_NAME_TAB + XY(animNameX, animNameY)

  ' generate the start tile
  I = RANDOM(4)
  currentAnim = FLOW1(I)
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

  WAIT
  WAIT
  NAME_TABLE0

  ' main game loop
  WHILE gameState <> GAME_STATE_NEXT_LEVEL
    WAIT

    if gameFrame = silentFrame THEN SOUND 3,,0

    ON gameState FAST GOSUB buildTick, flowTick, endTick

    GOSUB uiTick
    GOSUB logoTick
    GOSUB scoreTick

    IF isReplacing THEN GOSUB replaceTick
    
    gameFrame = gameFrame + 1 ' not using FRAME to ensure consistency in case of skipped frames
    IF (gameFrame AND $3f) = 0 THEN  ' very rough seconds. 64 ticks so will be slow at 50FPS
      gameSeconds = gameSeconds + 1
    END IF
  WEND

  ' copy screen to name table 1
  #addr = 0
  FOR I = 0 TO 23
    DEFINE VRAM READ #VDP_NAME_TAB + #addr, NAME_TABLE_WIDTH, VARPTR rowBuffer(0)
    DEFINE VRAM #VDP_NAME_TAB1 + #addr, NAME_TABLE_WIDTH, VARPTR rowBuffer(0)
    #addr = #addr + NAME_TABLE_WIDTH
  NEXT I
  
  NAME_TABLE1
  END

buildTick: PROCEDURE
  IF gameSeconds = currentStartDelay THEN
    gameState = GAME_STATE_FLOWING
    GOSUB renderFfwdButton
  END IF
  END

endTick: PROCEDURE
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
    gameState = GAME_STATE_NEXT_LEVEL
  END IF
  END

nextLevelTick: PROCEDURE
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
  IF dist > TILES_PX(5) THEN
    speed = -speed
    dist = TILES_PX(10) - dist
  END IF
  
  ' let's go faster if we're further away
  IF dist > 8 THEN
    speed = speed * (dist / 4)
  END IF

  scoreCurrentOffset(I) = scoreCurrentOffset(I) + speed

  IF scoreCurrentOffset(I) < 0 THEN
    scoreCurrentOffset(I) = 10 * TILE_SIZE + scoreCurrentOffset(I)
  ELSEIF scoreCurrentOffset(I) > 10 * TILE_SIZE - 1 THEN
    scoreCurrentOffset(I) = scoreCurrentOffset(I) - 10 * TILE_SIZE
  END IF

  DEFINE VRAM #VDP_PATT_TAB1 + (SCORE_PATT_ID + I) * TILE_SIZE, TILE_SIZE, VARPTR digits(scoreCurrentOffset(I))
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
    scoreDesiredOffset(I) = PATT_OFFSET(scoreDesiredOffset(I) - "0")
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
  logoStart = mulThree((gameFrame AND 3)) + LOGO_ANIM_TILE_ID
  logoOffset = (logoOffset AND $f) + LOGO_ANIM_SINE_OFFSET - logoStart

  ' update the color defs of three tiles
  #addr = #baseAddr + logoStart * TILE_SIZE
  FOR I = 0 TO LOGO_ANIM_TILES_PER_FRAME - 1
    DEFINE VRAM #addr, TILE_SIZE, VARPTR logoColorWhiteGreen(sine(logoOffset - I))
    #addr = #addr + TILE_SIZE
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
  IF animTile = 4 THEN  ' next tile?
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
    animSubStep = 7  ' ensure flow sprite is hidden

    prevTileX = currentTileX
    prevTileY = currentTileY

    currentIndex = currentIndex + offsetForFlow2(currentFlowDir)

    currentTileX = modNine(currentIndex)
    currentTileY = divNine(currentIndex)
    IF prevTileX <> currentTileX AND prevTileY <> currentTileY THEN
      tileId = 0
    ELSE
      animNameX = PLAYFIELD_X + mulThree(currentTileX)
      animNameY = PLAYFIELD_Y + mulThree(currentTileY)
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

  currentIndexPattId = (VPEEK(#currentIndexAddr + currentSubTile) - PIPES_PATT_ID) * TILE_SIZE

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
    animSprX = TILES_PX(animNameX + (currentSubTile AND 3))
    animSprY = TILES_PX(animNameY + (currentSubTile / NAME_TABLE_WIDTH))

    DEFINE VRAM #VDP_SPRITE_PATT + FLOW_SPRITE_PATT_ID * 32, 8, VARPTR flowAnimBuffer(0)
    SPRITE FLOW_SPRITE_ID, animSprY - 1, animSprX, FLOW_SPRITE_PATT_ID * 4, FLOW_COLOR
  END IF

  IF gameState = GAME_STATE_ENDED THEN GOSUB renderCursor

  END

' generate dynamic sprite pattern data for H/V liquid flow
.flowSpriteStraight: PROCEDURE
  CONST #TILE_BASE_ADDR = #VDP_PATT_TAB1 + (PIPES_PATT_ID * TILE_SIZE)
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
  offset = animSubStep * TILE_SIZE
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

subTileForFlow0:  ' first stage - entry subtile
  DATA BYTE SUBTILE_ML, SUBTILE_TC, SUBTILE_MR, SUBTILE_BC
subTileForFlow1:  ' second stage - exit subtile
  DATA BYTE SUBTILE_MR, SUBTILE_BC, SUBTILE_ML, SUBTILE_TC
offsetForFlow2:    ' third stage - offset to next tile
  DATA BYTE 1, PLAYFIELD_WIDTH, -1, -PLAYFIELD_WIDTH

' animation ids for liquid hitting the left, top, right and bottom edges of each tile id
anims:
  DATA BYTE ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,    ANIM_FLOW_INVALID,   ANIM_FLOW_INVALID  ' null
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
    J = RANDOM(g_nav)  ' help randomize
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
  FOR X = 0 TO chute(3) : R = RANDOM(255) : NEXT
  chute(CHUTE_SIZE - 1) = RANDOM(7) + 2
  g_cell = CHUTE_SIZE
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
    g_type = chute(I)
    GOSUB renderChuteCell
    g_cell = g_cell - 1
  NEXT I
  END
  

renderChuteCell: PROCEDURE
  nameX = CHUTE_X
  nameY = (CHUTE_Y + mulThree(g_cell)) - (3 + chuteOffset)
  IF nameY >= NAME_TABLE_HEIGHT OR  nameY < (PLAYFIELD_Y - 2) THEN RETURN

  GOSUB renderCell
  END

' ==========================================
' Render a game cell (in the playfield)
'   INPUTS: g_cell, g_type
' ------------------------------------------
renderGameCell: PROCEDURE
  nameX = PLAYFIELD_X + mulThree(modNine(g_cell))
  nameY = PLAYFIELD_Y + mulThree(divNine(g_cell))

  GOSUB renderCell
  END  

' ==========================================
' Render a game cell (any location)
'   INPUTS: g_type, nameX, nameY
' ------------------------------------------
renderCell: PROCEDURE 
  index = g_type * TILE_SIZE + g_type

  #addr = NAME_TAB_XY(nameX, nameY)

  FOR J = 0 TO 2
    IF nameY >= NAME_TABLE_HEIGHT THEN RETURN
    IF nameY >= PLAYFIELD_Y THEN DEFINE VRAM #addr, 3, VARPTR cellNames(index)
    index = index + 3
    nameY = nameY + 1
    #addr = #addr + NAME_TABLE_WIDTH
  NEXT J
  END

' ==========================================
' Update the cursor position
'   INPUTS: cursorX, cursorY
' ------------------------------------------
updateCursorPos: PROCEDURE
  spriteX = TILES_PX(PLAYFIELD_X + mulThree(cursorX)) - 1
  spriteY = TILES_PX(PLAYFIELD_Y + mulThree(cursorY)) - 2
  
  cursorIndex = TIMES_NINE(cursorY) + cursorX
  END

' ==========================================
' Render the cursor
' ------------------------------------------
renderCursor: PROCEDURE
  CONST CURSOR_SIZE   = 33
  CONST CURSOR_SPREAD = CURSOR_SIZE - 16

  ' flashing cursor
  color = VDP_WHITE
  IF gameFrame AND 8 THEN color = VDP_GREY

  ' over a locked tile?
  IF game(cursorIndex) AND CELL_LOCKED_FLAG THEN color = VDP_MED_RED

  IF SLIDE_MODE THEN
    isValid = FALSE
    IF color <> VDP_MED_RED THEN
      cursorX = modNine(cursorIndex)
      cursorY = divNine(cursorIndex)
      FOR I = 0 TO 3
        tempIndex = cursorIndex + offsetForFlow2(I)      
        tempIndexX = modNine(tempIndex)
        tempIndexY = divNine(tempIndex)
        IF NOT (tempIndexX <> cursorX AND tempIndexY <> cursorY) THEN
          IF game(tempIndex) = CELL_GRID THEN isValid = TRUE
        END IF
      NEXT I
      IF isValid = FALSE THEN color = VDP_MED_RED
    END IF
  END IF

  ' hide cursor if games ends
  IF (gameState = GAME_STATE_ENDED) OR hoverFfwd THEN
     color = VDP_TRANSPARENT
     spriteY = -30
  END IF

  ' render the four cursor corners
  FOR I = 0 TO 3
    SPRITE CURSOR_SPRITE_ID + I, spriteY + .cursorSpread(I), spriteX + .cursorSpread(I / 2), CURSOR_SPRITE_PATT_ID + I * 4, color
  NEXT I
  END

.cursorSpread:
  DATA BYTE 0, CURSOR_SPREAD, 0, CURSOR_SPREAD

' ==========================================
' Render the fast forward button
' ------------------------------------------
renderFfwdButton: PROCEDURE
  FOR J = 0 TO FFWD_PATT_COUNT - 1
    rowBuffer(J) = J + FFWD_PATT_ID + (hoverFfwd AND 6)
  NEXT J
  DEFINE VRAM NAME_TAB_XY(1, CHUTE_BOTTOM + 1), 3, VARPTR rowBuffer(0)
  DEFINE VRAM NAME_TAB_XY(1, CHUTE_BOTTOM + 2), 3, VARPTR rowBuffer(3)
  GOSUB updateCursorPos
  END

#if SHOW_TITLE
include "title.bas"
#endif

include "font.pletter.bas"
include "logo.pletter.bas"
include "sprites.pletter.bas"
include "tiles.pletter.bas"
include "loading.pletter.bas"
include "patterns.bas"
include "lookups.bas"

