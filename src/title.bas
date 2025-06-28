
titleScreen: PROCEDURE
	DEFINE CHAR 96, 39, titlePipePatt
	DEFINE COLOR 96, 39, titlePipeColor
	
    DEFINE CHAR 136, 96, titleLogo

    ' set the background colors of the title text
    FOR I = 136 to 232 STEP 4
        DEFINE COLOR I, 2, titleLogoRow0Color
    NEXT I

	DEFINE VRAM NAME_TAB_XY(0,3), 320, titlePipeNames

    #addr = #VDP_COLOR_TAB2 + 32 * 8
    FOR I = 0 to 63
        DEFINE VRAM #addr + I * 8, 8, visealmColor
    NEXT I

    'DEFINE SPRITE 0, 1, pipeVert


    'I = 0
    'FOR Y = 32 to 80 STEP 16
    '    SPRITE I, Y, 24, 0, 1
    '    SPRITE I + 1, Y, 230, 0, 1
    '    I = I + 2
    'NEXT Y

    I = 136
    FOR X = 4 TO 27
        #addr = NAME_TAB_XY(X, 6)
        FOR Y = 6 TO 9
            VPOKE #addr, I
            I = I + 1
            #addr = #addr + 32
        NEXT Y
    NEXT X

    PRINT AT XY(9, 14), "VISREALM  2025"

    'PRINT AT XY(9, 19), "BEGIN PLUMBING"
    PRINT AT XY(10, 19), "LET'S PLUMB!"

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
	WEND

	VDP_DISABLE_INT_DISP_OFF

'    FOR I = 0 TO 7
 '       SPRITE I,$d0,0,0,0
  '  NEXT I

	END

titleLogoTick: PROCEDURE
	' only move the wave every 4 frames
	logoOffset = FRAME / 4

	' every frame however, we render a quarter of the new wave
	logoOffset = (logoOffset AND $1f) + 24
	logoStart = (FRAME AND 3) * 6

    #addr = #VDP_COLOR_TAB2 + 136 * 8

	' update the color defs of three tiles
	FOR I = logoStart TO logoStart + 5
		DEFINE VRAM #addr + I * 32 + 16, 16, VARPTR titleLogoColorWhiteGreen(titleSine(logoOffset - I))
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

titleLogo:
    DATA BYTE $00, $03, $07, $0f, $1f, $3f, $3f, $3f
    DATA BYTE $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f
    DATA BYTE $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f
    DATA BYTE $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f
    DATA BYTE $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $f1, $e0, $e0, $e0, $e0, $e1, $e3, $e3
    DATA BYTE $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e3
    DATA BYTE $e3, $e3, $e3, $e1, $e1, $e0, $e0, $e0
    DATA BYTE $c0, $f8, $fc, $fe, $fe, $ff, $ff, $ff
    DATA BYTE $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $fe, $fc, $fc, $fc, $fc, $fc, $fe, $fe
    DATA BYTE $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $80
    DATA BYTE $80, $80, $80, $83, $87, $8f, $0f, $1f
    DATA BYTE $1f, $3f, $3f, $3f, $3f, $3f, $3f, $3f
    DATA BYTE $1f, $1f, $0f, $8f, $87, $c3, $c0, $c0
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $1f, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $f8, $f0, $e7, $e7, $e7, $e7, $e0, $f0
    DATA BYTE $f8, $ff, $ff, $ff, $ff, $ff, $ff, $1f
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $c0, $f8, $fe, $ff, $ff, $ff, $ff
    DATA BYTE $7f, $3f, $ff, $ff, $ff, $ff, $00, $00
    DATA BYTE $00, $e0, $ff, $ff, $ff, $fe, $fc, $e0
    DATA BYTE $07, $07, $07, $07, $07, $07, $07, $07
    DATA BYTE $07, $07, $07, $07, $07, $87, $87, $c7
    DATA BYTE $c7, $e7, $e7, $e7, $c7, $87, $07, $07
    DATA BYTE $03, $03, $81, $81, $00, $00, $00, $00
    DATA BYTE $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
    DATA BYTE $fc, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $ff, $fc, $fc, $fc, $fc, $fc, $fe, $ff
    DATA BYTE $ff, $ff, $ff, $ff, $ff, $7f, $1f, $07
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $c0, $c0, $c1, $c3, $c7, $c7, $c7
    DATA BYTE $cf, $0f, $0f, $0f, $0f, $0f, $0f, $8f
    DATA BYTE $8f, $8f, $8f, $8f, $8f, $8f, $8f, $8f
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $3f, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $ff, $ff, $ff, $fe, $fa, $f8, $f8, $f8
    DATA BYTE $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f8
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $c0, $e1, $e7, $c7, $cf, $9f
    DATA BYTE $9f, $3f, $3f, $3f, $3f, $3f, $3f, $3f
    DATA BYTE $1f, $1f, $0f, $07, $03, $01, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $1f, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $ff, $f8, $f0, $e0, $e0, $e0, $f0, $f8
    DATA BYTE $ff, $ff, $ff, $ff, $ff, $ff, $ff, $1f
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $c0, $f8, $fc, $ff, $ff, $ff, $ff
    DATA BYTE $ff, $ff, $7f, $3f, $3f, $3f, $7f, $ff
    DATA BYTE $ff, $ff, $ff, $ff, $fe, $fc, $f8, $c0
    DATA BYTE $00, $00, $00, $00, $01, $03, $03, $03
    DATA BYTE $07, $07, $07, $07, $07, $07, $87, $c7
    DATA BYTE $c7, $e7, $e7, $e7, $e7, $e7, $e7, $e7
    DATA BYTE $c7, $c7, $87, $07, $07, $07, $07, $07
    DATA BYTE $0f, $3f, $7f, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $ff, $fe, $fe, $fe, $fe, $fe, $fe, $fe
    DATA BYTE $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe
    DATA BYTE $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe
    DATA BYTE $fc, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $1f, $0f, $0f, $0f, $0f, $1f, $3f, $3f
    DATA BYTE $7f, $7f, $7f, $7f, $7c, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $01, $81, $c1, $e1, $e1, $f1, $f1, $f9
    DATA BYTE $f9, $f9, $f9, $f9, $f9, $f9, $f1, $f1
    DATA BYTE $e1, $e1, $c1, $01, $01, $01, $01, $01
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01
    DATA BYTE $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $80, $80, $81, $83, $87, $8f, $8f, $8f
    DATA BYTE $9f, $9f, $9f, $9f, $9f, $9f, $9f, $9f
    DATA BYTE $9f, $9f, $9f, $9f, $9f, $9f, $9f, $9f
    DATA BYTE $9f, $9f, $9f, $9f, $9f, $9f, $9f, $9f
    DATA BYTE $3f, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $fc, $f8, $f8, $f8, $f8, $f8, $f8, $f8
    DATA BYTE $f9, $f9, $f9, $f9, $f9, $f8, $f8, $f8
    DATA BYTE $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f8
    DATA BYTE $f0, $fe, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $7f, $3f, $3f, $3f, $3f, $7f, $ff, $ff
    DATA BYTE $ff, $ff, $ff, $fc, $f0, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $81, $83, $c3, $c7, $e7
    DATA BYTE $e7, $e7, $e7, $e7, $e7, $e7, $c7, $c7
    DATA BYTE $87, $87, $07, $07, $07, $07, $07, $07
    DATA BYTE $07, $07, $03, $03, $01, $00, $00, $00
    DATA BYTE $1f, $7f, $ff, $ff, $ff, $ff, $ff, $ff
    DATA BYTE $ff, $fc, $fc, $fc, $ff, $ff, $ff, $ff
    DATA BYTE $ff, $ff, $ff, $fc, $fc, $fc, $fc, $ff
    DATA BYTE $ff, $ff, $ff, $ff, $ff, $ff, $7f, $1f
    DATA BYTE $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe
    DATA BYTE $fe, $00, $00, $00, $fc, $fc, $fc, $fc
    DATA BYTE $fc, $fc, $fc, $00, $00, $00, $00, $fe
    DATA BYTE $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe



titlePipePatt:
    DATA BYTE $03, $03, $03, $03, $03, $03, $03, $03     ' pat96
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $80     
    DATA BYTE $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0     
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $80     
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $80     
    DATA BYTE $80, $80, $80, $80, $80, $FF, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $01, $01, $01, $01, $01, $FF, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $01, $01, $01     
    DATA BYTE $00, $00, $00, $00, $00, $FF, $00, $00     
    DATA BYTE $FF, $FF, $6F, $FF, $FF, $FF, $FF, $FF     
    DATA BYTE $00, $00, $00, $00, $00, $80, $80, $80     
    DATA BYTE $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0     
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01     
    DATA BYTE $00, $00, $00, $C0, $C0, $C0, $C0, $C0     
    DATA BYTE $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0     
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01     
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $FF, $FF, $FF, $80, $80, $80, $80, $80     
    DATA BYTE $FF, $FF, $FF, $01, $01, $01, $01, $01     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $00, $00, $00     
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $80     
    DATA BYTE $01, $01, $01, $00, $00, $00, $00, $00     
    DATA BYTE $80, $80, $80, $00, $00, $00, $00, $00     
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01     
    DATA BYTE $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0     
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $80     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $C0, $C0, $C0, $C0, $C0, $00, $00, $00     
    DATA BYTE $00, $00, $03, $03, $03, $03, $03, $03     
    DATA BYTE $03, $03, $03, $03, $03, $03, $03, $03     
    DATA BYTE $03, $03, $03, $03, $03, $03, $03, $03     
    DATA BYTE $03, $03, $03, $03, $03, $03, $03, $03     
    DATA BYTE $03, $03, $03, $03, $03, $01, $01, $01     
    DATA BYTE $00, $00, $00, $00, $00, $C0, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $03, $00, $00     

titlePipeColor:
    DATA BYTE $10, $10, $10, $10, $10, $10, $10, $10     ' col96
    DATA BYTE $F4, $F4, $F4, $F4, $F4, $F4, $F4, $F4     
    DATA BYTE $10, $10, $10, $10, $10, $10, $10, $10     
    DATA BYTE $FE, $FE, $FE, $F5, $F5, $F5, $F5, $F5     
    DATA BYTE $FF, $FF, $0E, $0E, $0E, $F5, $F5, $F5     
    DATA BYTE $F5, $F5, $F5, $F5, $F5, $F5, $F5, $F5     
    DATA BYTE $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1     
    DATA BYTE $F1, $F1, $F1, $F1, $F1, $F1, $41, $41     
    DATA BYTE $F4, $F4, $F4, $F4, $F1, $F1, $F1, $F1     
    DATA BYTE $F1, $F1, $F1, $F1, $F1, $F1, $41, $41     
    DATA BYTE $41, $41, $41, $41, $41, $F1, $F1, $F1     
    DATA BYTE $41, $41, $41, $41, $41, $F1, $41, $41     
    DATA BYTE $44, $44, $44, $40, $45, $40, $45, $40     
    DATA BYTE $41, $41, $41, $41, $41, $F1, $F1, $F1     
    DATA BYTE $15, $15, $15, $15, $15, $15, $15, $15     
    DATA BYTE $F1, $F1, $F1, $F1, $F1, $F1, $F1, $F1     
    DATA BYTE $11, $11, $1F, $17, $17, $1E, $1E, $1E     
    DATA BYTE $1F, $1F, $1E, $1E, $1E, $15, $15, $15     
    DATA BYTE $F4, $F4, $F4, $F4, $F4, $F4, $F4, $F4     
    DATA BYTE $F5, $F5, $F5, $F5, $F5, $F5, $F5, $F5     
    DATA BYTE $E5, $E5, $E5, $E5, $E5, $E5, $E5, $E5     
    DATA BYTE $17, $17, $F7, $F7, $F7, $F7, $F7, $F7     
    DATA BYTE $17, $17, $F7, $F7, $F7, $F7, $F7, $F7     
    DATA BYTE $10, $10, $F0, $70, $70, $7E, $7E, $7E     
    DATA BYTE $F7, $F7, $F7, $FE, $FE, $FE, $FF, $FF     
    DATA BYTE $F7, $F7, $F7, $4E, $4E, $4E, $4F, $4F     
    DATA BYTE $F7, $F7, $F7, $4E, $4E, $4E, $4F, $4F     
    DATA BYTE $F7, $F7, $F7, $FE, $FE, $FE, $FF, $FF     
    DATA BYTE $14, $14, $14, $14, $14, $14, $14, $14     
    DATA BYTE $FE, $FE, $FE, $F5, $F5, $F5, $F5, $F5     
    DATA BYTE $EE, $EE, $EE, $E5, $E5, $E5, $E5, $E5     
    DATA BYTE $14, $14, $14, $14, $11, $41, $41, $41     
    DATA BYTE $51, $51, $FF, $17, $17, $1E, $1E, $1E     
    DATA BYTE $1F, $1F, $1E, $1E, $1E, $15, $15, $15     
    DATA BYTE $15, $15, $15, $15, $15, $15, $15, $15     
    DATA BYTE $14, $14, $14, $14, $14, $14, $14, $14     
    DATA BYTE $14, $14, $14, $14, $11, $11, $11, $11     
    DATA BYTE $11, $11, $11, $11, $11, $1F, $11, $11     
    DATA BYTE $11, $11, $11, $11, $11, $1F, $11, $11     



titlePipeNames:
    DATA BYTE $60, $75, $76, $62, $20, $20, $20, $20     ' name
    DATA BYTE $20, $20, $20, $20, $20, $20, $20, $20     
    DATA BYTE $20, $20, $20, $20, $20, $20, $20, $20     
    DATA BYTE $20, $20, $20, $20, $60, $75, $76, $62

    DATA BYTE $60, $78, $79, $70, $77, $77, $77, $77     
    DATA BYTE $77, $77, $77, $77, $77, $77, $77, $77     
    DATA BYTE $77, $77, $77, $77, $77, $77, $77, $77     
    DATA BYTE $77, $77, $77, $77, $80, $7A, $7B, $62     

    DATA BYTE $60, $7D, $7E, $71, $64, $64, $64, $64     
    DATA BYTE $64, $64, $64, $64, $64, $64, $64, $64     
    DATA BYTE $64, $64, $64, $64, $64, $64, $64, $64     
    DATA BYTE $64, $64, $64, $64, $81, $7E, $63, $62     

    DATA BYTE $60, $65, $74, $6E, $74, $74, $74, $74     
    DATA BYTE $74, $74, $74, $74, $74, $74, $74, $74     
    DATA BYTE $74, $74, $74, $74, $74, $74, $74, $74     
    DATA BYTE $74, $74, $74, $74, $82, $74, $73, $62     

    DATA BYTE $60, $65, $74, $6E, $74, $74, $74, $74     
    DATA BYTE $74, $74, $74, $74, $74, $74, $74, $74     
    DATA BYTE $74, $74, $74, $74, $74, $74, $74, $74     
    DATA BYTE $74, $74, $74, $74, $82, $74, $73, $62     

    DATA BYTE $60, $61, $6C, $7C, $6C, $6C, $6C, $6C     
    DATA BYTE $6C, $6C, $6C, $6C, $6C, $6C, $6C, $6C     
    DATA BYTE $6C, $6C, $6C, $6C, $6C, $6C, $6C, $6C     
    DATA BYTE $6C, $6C, $6C, $6C, $83, $6C, $72, $62     
    DATA BYTE $60, $61, $6C, $7C, $6C, $6C, $6C, $6C     
    DATA BYTE $6C, $6C, $6C, $6C, $6C, $6C, $6C, $6C     
    DATA BYTE $6C, $6C, $6C, $6C, $6C, $6C, $6C, $6C     
    DATA BYTE $6C, $6C, $6C, $6C, $83, $6C, $72, $62     
    DATA BYTE $60, $61, $6C, $7F, $68, $68, $68, $68     
    DATA BYTE $68, $68, $68, $68, $68, $68, $68, $68     
    DATA BYTE $68, $68, $68, $68, $68, $68, $68, $68     
    DATA BYTE $68, $68, $68, $68, $84, $6C, $72, $62     
    DATA BYTE $60, $66, $6A, $6B, $6B, $6B, $6B, $6B     
    DATA BYTE $6B, $6B, $6B, $6B, $6B, $6B, $6B, $6B     
    DATA BYTE $6B, $6B, $6B, $6B, $6B, $6B, $6B, $6B     
    DATA BYTE $6B, $6B, $6B, $6B, $6B, $6D, $6F, $62     
    DATA BYTE $60, $67, $69, $62, $20, $20, $20, $20     
    DATA BYTE $20, $20, $20, $20, $20, $20, $20, $20     
    DATA BYTE $20, $20, $20, $20, $20, $20, $20, $20     
    DATA BYTE $20, $20, $20, $20, $60, $67, $69, $62     
