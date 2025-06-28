
titleScreen: PROCEDURE
	DEFINE CHAR 96, 32, titlePipePatt
	DEFINE COLOR 96, 32, titlePipeColor
	
    DEFINE CHAR 128, 96, titleLogo
    FOR I = 128 to 224 STEP 4
        DEFINE COLOR I, 1, titleLogoTopColor
    NEXT I

	DEFINE VRAM NAME_TAB_XY(0,3), 320, titlePipeNames

    #addr = #VDP_COLOR_TAB2 + 32 * 8
    FOR I = 0 to 63
        DEFINE VRAM #addr + I * 8, 8, visealmColor
    NEXT I

    DEFINE SPRITE 0, 1, pipeVert


    I = 0
    FOR Y = 32 to 80 STEP 16
        SPRITE I, Y, 24, 0, 1
        SPRITE I + 1, Y, 230, 0, 1
        I = I + 2
    NEXT Y

    I = 128
    FOR X = 4 TO 27
        #addr = NAME_TAB_XY(X, 6)
        FOR Y = 6 TO 9
            VPOKE #addr, I
            I = I + 1
            #addr = #addr + 32
        NEXT Y
    NEXT X

    PRINT AT XY(9, 13), "VISREALM  2025"

    PRINT AT XY(7, 19), "> BEGIN PLUMBING <"

	VDP_ENABLE_INT

	WHILE 1
	    WAIT
        GOSUB titleLogoTick
    	GOSUB updateNavInput
        IF g_nav THEN EXIT WHILE
	WEND

	VDP_DISABLE_INT_DISP_OFF

    FOR I = 0 TO 7
        SPRITE I,$d0,0,0,0
    NEXT I

	END

titleLogoTick: PROCEDURE
	' only move the wave every 4 frames
	logoOffset = FRAME / 4

	' every frame however, we render a quarter of the new wave
	logoOffset = (logoOffset AND $1f) + 24
	logoStart = (FRAME AND 3) * 6

    #addr = #VDP_COLOR_TAB2 + 1024'128 * 8

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

titleLogoTopColor:
    DATA BYTE $fe, $fe, $fe, $f5, $f5, $f5, $f5, $f0

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
    DATA BYTE $03, $03, $03, $03, $03, $03, $03, $03    'pat 96
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF     
    DATA BYTE $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF     
    DATA BYTE $FF, $FF, $AA, $09, $40, $15, $FF, $55     
    DATA BYTE $FF, $FF, $55, $54, $FF, $25, $FF, $55     
    DATA BYTE $65, $6A, $92, $49, $FF, $48, $FF, $FF     
    DATA BYTE $95, $AA, $4A, $20, $0A, $20, $FF, $FF     
    DATA BYTE $55, $FF, $55, $FF, $FF, $49, $FF, $FF     
    DATA BYTE $FF, $FF, $FF, $22, $94, $55, $55, $08     
    DATA BYTE $FF, $FF, $55, $0A, $40, $12, $FF, $5A     
    DATA BYTE $FF, $FF, $55, $A8, $02, $48, $FF, $55     
    DATA BYTE $DD, $B7, $6A, $FF, $DB, $FF, $B6, $FF     
    DATA BYTE $FF, $FF, $FF, $22, $94, $52, $A5, $10     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF     
    DATA BYTE $52, $52, $55, $05, $50, $FF, $FF, $FF     
    DATA BYTE $53, $53, $52, $09, $44, $10, $FF, $FF     
    DATA BYTE $BB, $FF, $FF, $77, $DD, $AA, $01, $90     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $4A, $21     
    DATA BYTE $52, $00, $00, $04, $91, $4A, $FF, $24     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $92, $FF, $FF     
    DATA BYTE $A2, $FF, $FF, $FF, $FF, $FF, $FF, $FF     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $92     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $52, $08     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $29, $44     
    DATA BYTE $A1, $FF, $FF, $FF, $FF, $FF, $FF, $FF     
    DATA BYTE $04, $FF, $FF, $FF, $FF, $FF, $FF, $FF     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $24     
    DATA BYTE $FF, $FF, $FF, $FF, $80, $24, $FF, $FF     
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $49     

titlePipeColor:
    DATA BYTE $14, $14, $14, $14, $14, $14, $14, $14     'col96
    DATA BYTE $10, $10, $70, $70, $70, $70, $70, $70     
    DATA BYTE $14, $14, $14, $14, $14, $14, $14, $14     
    DATA BYTE $40, $40, $40, $40, $40, $40, $40, $40     
    DATA BYTE $70, $70, $47, $45, $45, $45, $50, $E5     
    DATA BYTE $70, $70, $74, $45, $50, $45, $50, $E5     
    DATA BYTE $14, $41, $41, $41, $10, $41, $10, $10     
    DATA BYTE $14, $14, $41, $41, $41, $41, $10, $10     
    DATA BYTE $45, $50, $45, $50, $50, $E5, $E0, $E0     
    DATA BYTE $40, $40, $40, $14, $14, $41, $41, $41     
    DATA BYTE $70, $70, $47, $45, $45, $45, $50, $5E     
    DATA BYTE $70, $70, $47, $45, $45, $45, $50, $E5     
    DATA BYTE $54, $54, $54, $40, $45, $40, $45, $40     
    DATA BYTE $40, $40, $40, $14, $14, $14, $41, $41     
    DATA BYTE $40, $40, $40, $40, $40, $40, $40, $40     
    DATA BYTE $10, $10, $10, $10, $10, $10, $10, $10     
    DATA BYTE $14, $41, $14, $41, $41, $10, $10, $10     
    DATA BYTE $41, $14, $41, $41, $41, $41, $10, $10     
    DATA BYTE $E5, $E0, $E5, $E5, $E5, $E5, $45, $45     
    DATA BYTE $40, $40, $40, $40, $40, $40, $14, $14     
    DATA BYTE $5E, $EE, $5E, $5E, $5E, $5E, $50, $45     
    DATA BYTE $E0, $E0, $E0, $E0, $50, $45, $50, $40     
    DATA BYTE $41, $10, $10, $10, $10, $10, $10, $10     
    DATA BYTE $10, $10, $70, $70, $70, $70, $70, $47     
    DATA BYTE $40, $40, $40, $40, $40, $40, $14, $14     
    DATA BYTE $40, $40, $40, $40, $40, $40, $14, $14     
    DATA BYTE $41, $10, $10, $10, $10, $10, $10, $10     
    DATA BYTE $41, $10, $10, $10, $10, $10, $10, $10     
    DATA BYTE $70, $70, $70, $70, $70, $70, $70, $70     
    DATA BYTE $10, $10, $70, $70, $70, $70, $70, $47     
    DATA BYTE $E0, $E0, $E0, $E0, $E5, $45, $50, $40     
    DATA BYTE $10, $10, $70, $70, $70, $70, $70, $47     


titlePipeNames:
    DATA BYTE $60, $61, $61, $62, $63, $63, $63, $63     'name
    DATA BYTE $63, $63, $63, $63, $63, $63, $63, $63     
    DATA BYTE $63, $63, $63, $63, $63, $63, $63, $63     
    DATA BYTE $63, $63, $63, $63, $60, $61, $61, $62     
    DATA BYTE $60, $64, $65, $77, $77, $77, $77, $77     
    DATA BYTE $77, $77, $77, $77, $77, $77, $77, $77     
    DATA BYTE $77, $77, $77, $77, $77, $77, $77, $77     
    DATA BYTE $77, $77, $77, $77, $77, $6A, $6B, $62     
    DATA BYTE $60, $74, $72, $68, $68, $68, $68, $68     
    DATA BYTE $68, $68, $68, $68, $68, $68, $68, $68     
    DATA BYTE $68, $68, $68, $68, $68, $68, $68, $68     
    DATA BYTE $68, $68, $68, $68, $68, $74, $72, $62     
    DATA BYTE $60, $6C, $6C, $75, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $75, $6C, $6C, $62     
    DATA BYTE $60, $6E, $6E, $6E, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6E, $6E, $6E, $62     
    DATA BYTE $60, $6E, $6E, $6E, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6E, $6E, $6E, $62     
    DATA BYTE $60, $73, $73, $6E, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F     
    DATA BYTE $6F, $6F, $6F, $6F, $6E, $73, $73, $62     
    DATA BYTE $60, $70, $71, $6D, $69, $69, $69, $69     
    DATA BYTE $69, $69, $69, $69, $69, $69, $69, $69     
    DATA BYTE $69, $69, $69, $69, $69, $69, $69, $69     
    DATA BYTE $69, $69, $69, $69, $69, $67, $66, $62     
    DATA BYTE $60, $6F, $6F, $76, $76, $76, $76, $76     
    DATA BYTE $76, $76, $76, $76, $76, $76, $76, $76     
    DATA BYTE $76, $76, $76, $76, $76, $76, $76, $76     
    DATA BYTE $76, $76, $76, $76, $76, $6F, $6F, $62     
    DATA BYTE $60, $6F, $6F, $62, $63, $63, $63, $63     
    DATA BYTE $63, $63, $63, $63, $63, $63, $63, $63     
    DATA BYTE $63, $63, $63, $63, $63, $63, $63, $63     
    DATA BYTE $63, $63, $63, $63, $60, $6F, $6F, $62     
