'
' Project: retropipe
'
' Title screen
'
' Copyright (c) 2025 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/retropipe


' perhaps an delay/task array. where the task is an index to
' an on x GOSUB. Need to factor in titleLogoTick

CONST #TITLE_TEMP_ADDRESS = #VDP_SPRITE_PATT

titleScreen: PROCEDURE
	
    DEFINE CHAR PLETTER 96, 39, titlePipePattPletter
    DEFINE COLOR PLETTER 96, 39, titlePipeColorPletter
    DEFINE CHAR PLETTER 136, 96, titleLogoPletter

    ' set the background colors of the title text first two rows
    #addr = #VDP_COLOR_TAB1 + (136 * 8)
    FOR I = 0 TO NAME_TABLE_HEIGHT - 1
        DEFINE VRAM #addr, 16, titleLogoRow0Color
        #addr = #addr + 32
    NEXT I

    FILL_BUFFER(" ")
    #addr = #TITLE_TEMP_ADDRESS
    FOR I = 0 TO 20
        DEFINE VRAM #addr, 32, VARPTR rowBuffer(0)
        #addr = #addr + 32
    NEXT I
    DEFINE VRAM PLETTER #TITLE_TEMP_ADDRESS + $20, 320, titlePipeNamesPletter

    #addr = #VDP_COLOR_TAB1 + 32 * 8
    FOR I = 0 to 63
        DEFINE VRAM #addr + I * 8, 8, visealmColor
    NEXT I

    I = 136
    FOR X = 4 TO 27
        #addr = #TITLE_TEMP_ADDRESS + XY(X, 4)
        FOR Y = 6 TO 9
            VPOKE #addr, I
            I = I + 1
            #addr = #addr + 32
        NEXT Y
    NEXT X

    NAME_TABLE0
    VDP_ENABLE_INT

    #baseAddr = #VDP_COLOR_TAB1

    startRow = 11
    endRow = 0
    FOR J = 0 TO 13
        WAIT
        #dest = endRow * 32
        #src = startRow * 32
        FOR Y = 0 TO 10
            IF I + Y < 200 THEN
                DEFINE VRAM READ #TITLE_TEMP_ADDRESS + #src, 32, VARPTR rowBuffer(0)
                DEFINE VRAM #VDP_NAME_TAB + #dest, 32, VARPTR rowBuffer(0)
                #dest = #dest + 32
            END IF
            #src = #src + 32
        NEXT Y
        IF startRow > 0 THEN
            startRow = startRow - 1
        ELSE
            #baseAddr = #VDP_COLOR_TAB2
            endRow = endRow + 1
        END IF
        GOSUB titleLogoTick        
    NEXT J

    FOR J = 0 TO 20 : WAIT : GOSUB titleLogoTick  : NEXT J

    PRINT AT XY(9, 3), "[]2025 VISREALM"

    FOR J = 0 TO 60 : WAIT : GOSUB titleLogoTick  : NEXT J

    PRINT AT XY(10, 19), "LET'S PLUMB!"

    triggered = FALSE


	WHILE 1
    WAIT
    IF (FRAME AND 8) OR triggered THEN
      VPOKE NAME_TAB_XY(8, 19), ">"
      VPOKE NAME_TAB_XY(23, 19), "<"
    ELSE
      VPOKE NAME_TAB_XY(8, 19), " "
      VPOKE NAME_TAB_XY(23, 19), " "
    END IF
    GOSUB titleLogoTick
    GOSUB updateNavInput
    IF g_nav THEN triggered = TRUE
    IF triggered AND (g_nav = 0) THEN EXIT WHILE
    I = RANDOM(FRAME)
	WEND
	END

' ==========================================
' Handle title/logo animation
' ------------------------------------------
titleLogoTick: PROCEDURE
    gameFrame = gameFrame + 1
	' only move the wave every 4 frames
	logoOffset = gameFrame / 4

	' every frame however, we render a quarter of the new wave
	logoStart = mulThree((gameFrame AND 3)) * 2
	logoOffset = (logoOffset AND $1f) + 24 - logoStart

    #addr = #baseAddr + (138 * 8)
    #addr = #addr + (logoStart * 32)

	' update the color defs of three tiles
	FOR I = 0 TO 5
		DEFINE VRAM #addr, 16, VARPTR titleColorBuffer(titleSine(logoOffset - I))
        #addr = #addr + 32
	NEXT I
	END

titleSine:
	DATA BYTE 8, 9, 11, 12, 13, 14, 14, 15, 15, 15, 14, 14, 13, 12, 11, 9, 8, 7, 5, 4, 3, 2, 2, 1, 1, 1, 2, 2, 3, 4, 5, 7, 8, 9, 11, 12, 13, 14, 14, 15, 15, 15, 14, 14, 13, 12, 11, 9, 8, 7, 5, 4, 3, 2, 2, 1, 1, 1, 2, 2, 3, 4, 5, 7, 8, 9

titleLogoRow0Color:
    DATA BYTE $f5, $f5, $f5, $f5, $f5, $f5, $f5, $f5
titleLogoRow1Color:
    DATA BYTE $f5, $f5, $f5, $f5, $f5, $f5, $f5, $f5

visealmColor:
    DATA BYTE $50, $50, $50, $50, $50, $50, $50, $50

include "title.pletter.bas"
