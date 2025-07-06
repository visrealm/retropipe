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


titleScreen: PROCEDURE
	
    DEFINE CHAR PLETTER 96, 39, titlePipePattPletter
    DEFINE COLOR PLETTER 96, 39, titlePipeColorPletter
    DEFINE CHAR PLETTER 136, 96, titleLogoPletter

    ' set the background colors of the title text first two rows
    #addr = #VDP_COLOR_TAB1 + (136 * 8)
    FOR I = 0 TO 23
        DEFINE VRAM #addr, 16, titleLogoRow0Color
        #addr = #addr + 32
    NEXT I

    DEFINE VRAM PLETTER NAME_TAB_XY(0,3), 320, titlePipeNamesPletter

    #addr = #VDP_COLOR_TAB1 + 32 * 8
    FOR I = 0 to 63
        DEFINE VRAM #addr + I * 8, 8, visealmColor
    NEXT I

    I = 136
    FOR X = 4 TO 27
        #addr = NAME_TAB_XY(X, 6)
        FOR Y = 6 TO 9
            VPOKE #addr, I
            I = I + 1
            #addr = #addr + 32
        NEXT Y
    NEXT X

    PRINT AT XY(9, 3), "VISREALM  2025"

    PRINT AT XY(10, 19), "LET'S PLUMB!"

    NAME_TABLE0
	VDP_ENABLE_INT

	WHILE 1
	    WAIT
        IF (FRAME AND $7) = 0 THEN
            IF (FRAME AND $8) THEN
                PRINT AT XY(8, 19), ">"
                PRINT AT XY(23, 19), "<"
            ELSE
                PRINT AT XY(8, 19), " "
                PRINT AT XY(23, 19), " "
            END IF
        END IF
        GOSUB titleLogoTick
    	GOSUB updateNavInput
        IF g_nav THEN EXIT WHILE
        I = RANDOM(255)
        gameFrame = gameFrame + 1
	WEND

	NAME_TABLE1
	VDP_DISABLE_INT

	END

titleLogoTick: PROCEDURE
	' only move the wave every 4 frames
	logoOffset = gameFrame / 4

	' every frame however, we render a quarter of the new wave
	logoStart = (gameFrame AND 3) * 6
	logoOffset = (logoOffset AND $1f) + 24 - logoStart

    #addr = #VDP_COLOR_TAB2 + (138 * 8)
    #addr = #addr + (logoStart * 32)

	' update the color defs of three tiles
	FOR I = 0 TO 5
		DEFINE VRAM #addr, 16, VARPTR titleLogoColorWhiteGreen(titleSine(logoOffset - I))
        #addr = #addr + 32
	NEXT I
	END

titleSine:
	DATA BYTE 8, 9, 11, 12, 13, 14, 14, 15, 15, 15, 14, 14, 13, 12, 11, 9, 8, 7, 5, 4, 3, 2, 2, 1, 1, 1, 2, 2, 3, 4, 5, 7, 8, 9, 11, 12, 13, 14, 14, 15, 15, 15, 14, 14, 13, 12, 11, 9, 8, 7, 5, 4, 3, 2, 2, 1, 1, 1, 2, 2, 3, 4, 5, 7, 8, 9

pipeVert:
    DATA BYTE $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0
    DATA BYTE $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00

titleLogoRow0Color:
    DATA BYTE $f5, $f5, $f5, $f5, $f5, $f5, $f5, $f5
titleLogoRow1Color:
    DATA BYTE $f5, $f5, $f5, $f5, $f5, $f5, $f5, $f5

visealmColor:
    DATA BYTE $50, $50, $50, $50, $50, $50, $50, $50

include "title.pletter.bas"
