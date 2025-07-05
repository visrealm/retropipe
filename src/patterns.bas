'
' Project: retropipe
'
' Pattern definitions
'
' Copyright (c) 2025 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/retropipe

' TILE PATTERNS

grid:   ' empty grid (128)
    DATA BYTE $ff, $80, $80, $80, $80, $80, $80, $80    ' TL
    DATA BYTE $ff, $00, $00, $00, $00, $00, $00, $00    ' TC
    DATA BYTE $fe, $01, $01, $01, $01, $01, $01, $01    ' TR
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $80    ' ML
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00    ' MC
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01    ' MR
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $ff    ' BL
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $ff    ' BC
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $ff    ' BR

base: ' filled base (137)
    DATA BYTE $49, $92, $24, $49, $92, $24, $49, $92    ' TL
    DATA BYTE $24, $49, $92, $24, $49, $92, $24, $49    ' TC
    DATA BYTE $93, $25, $49, $93, $25, $49, $93, $25    ' TR
    DATA BYTE $24, $49, $92, $24, $49, $92, $24, $49    ' ML
    DATA BYTE $92, $24, $49, $92, $24, $49, $92, $24    ' MC
    DATA BYTE $49, $93, $25, $49, $93, $25, $49, $93    ' MR
    DATA BYTE $92, $24, $49, $92, $24, $49, $92, $FF    ' BL
    DATA BYTE $49, $92, $24, $49, $92, $24, $49, $FF    ' BC
    DATA BYTE $25, $49, $93, $25, $49, $93, $25, $FE    ' BR

    ' base corners when pipes around (146)
baseCornersTL:
    DATA BYTE $49, $92, $24, $49, $92, $24, $49, $F2    ' H
    DATA BYTE $49, $93, $25, $49, $92, $24, $49, $92    ' V
    DATA BYTE $49, $93, $25, $49, $92, $24, $49, $F2    ' X
baseCornersTR:  ' (149)
    DATA BYTE $93, $25, $49, $93, $25, $49, $93, $27    ' H
    DATA BYTE $93, $A5, $C9, $93, $25, $49, $93, $25    ' V
    DATA BYTE $93, $A5, $C9, $93, $25, $49, $93, $27    ' X
baseCornersBL:  ' (152)
    DATA BYTE $F2, $24, $49, $92, $24, $49, $92, $FF    ' H
    DATA BYTE $92, $24, $49, $92, $24, $49, $93, $FF    ' V
    DATA BYTE $F2, $24, $49, $92, $24, $49, $93, $FF    ' X
baseCornersBR:  ' (155)
    DATA BYTE $27, $49, $93, $25, $49, $93, $25, $FE    ' H
    DATA BYTE $25, $49, $93, $25, $49, $93, $A5, $FE    ' V
    DATA BYTE $27, $49, $93, $25, $49, $93, $A5, $FE    ' X

pipes:  ' empty (158) and filled (168)
    DATA BYTE $FF, $00, $00, $00, $00, $00, $00, $FF    ' H (MC)
    DATA BYTE $3F, $00, $00, $00, $00, $00, $00, $3F    ' L (ML)
    DATA BYTE $FC, $00, $00, $00, $00, $00, $00, $FC    ' R (MR)
    DATA BYTE $81, $81, $81, $81, $81, $81, $81, $81    ' V (MC)
    DATA BYTE $00, $00, $81, $81, $81, $81, $81, $81    ' T (TC)
    DATA BYTE $81, $81, $81, $81, $81, $81, $00, $00    ' B (BC)
    ' corner pipes (164) and filled (174)
    DATA BYTE $FF, $07, $03, $01, $01, $01, $01, $01    ' DL (MC)
    DATA BYTE $FF, $E0, $C0, $80, $80, $80, $80, $80    ' DR (MC)
    DATA BYTE $80, $80, $80, $80, $80, $C0, $E0, $FF    ' UR (MC)
    DATA BYTE $01, $01, $01, $01, $01, $03, $07, $FF    ' UL (MC)

borders:  ' edges and such (178)
    DATA BYTE $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1    ' chute R
    DATA BYTE $06, $06, $06, $06, $06, $06, $06, $06    ' chute L
    DATA BYTE $FF, $FF, $00, $00, $00, $00, $00, $00    ' chute B
    DATA BYTE $07, $03, $00, $00, $00, $00, $00, $00    ' chute BL
    DATA BYTE $C1, $81, $01, $01, $01, $01, $01, $01    ' chute BR
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01    ' map L
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $FF    ' map T

digits:
    DATA BYTE $7C, $CE, $DE, $F6, $E6, $C6, $7C, $00 ' 0
    DATA BYTE $18, $38, $18, $18, $18, $18, $7E, $00 ' 1
    DATA BYTE $7C, $C6, $06, $7C, $C0, $C0, $FE, $00 ' 2
    DATA BYTE $FC, $06, $06, $3C, $06, $06, $FC, $00 ' 3
    DATA BYTE $0C, $CC, $CC, $CC, $FE, $0C, $0C, $00 ' 4
    DATA BYTE $FE, $C0, $FC, $06, $06, $C6, $7C, $00 ' 5
    DATA BYTE $7C, $C0, $C0, $FC, $C6, $C6, $7C, $00 ' 6
    DATA BYTE $FE, $06, $06, $0C, $18, $30, $30, $00 ' 7
    DATA BYTE $7C, $C6, $C6, $7C, $C6, $C6, $7C, $00 ' 8
    DATA BYTE $7C, $C6, $C6, $7E, $06, $06, $7C, $00 ' 9
    DATA BYTE $7C, $CE, $DE, $F6, $E6, $C6, $7C, $00 ' 0

' TILE COLORS

fontColor:
    DATA BYTE $f0, $f0, $f0, $f0, $f0, $f0, $f0, $00

gridColor:
    DATA BYTE $45, $45, $45, $45, $45, $45, $45, $45
    DATA BYTE $45, $15, $15, $15, $15, $15, $15, $15
    DATA BYTE $47, $75, $75, $75, $75, $75, $75, $75
    DATA BYTE $45, $45, $45, $45, $45, $45, $45, $45
    DATA BYTE $15, $15, $15, $15, $15, $15, $15, $15
    DATA BYTE $75, $75, $75, $75, $75, $75, $75, $75
    DATA BYTE $45, $45, $45, $45, $45, $45, $45, $74
    DATA BYTE $15, $15, $15, $15, $15, $15, $15, $75
    DATA BYTE $75, $75, $75, $75, $75, $75, $75, $75

'digitColor:
'    DATA BYTE $31, $31, $31, $31, $31, $31, $31, $31

baseColor:
    DATA BYTE $45, $45, $45, $45, $45, $45, $45, $45

pipeColor:
    DATA BYTE $41, $41, $41, $41, $41, $41, $41, $41

pipeColorGreen:
    DATA BYTE $42, $42, $42, $42, $42, $42, $42, $42

defaultColor:
titleLogoColorWhiteGreen:
    DATA BYTE $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
logoColorWhiteGreen:    
    DATA BYTE $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
    DATA BYTE $30, $20, $c0, $c0, $c0, $c0, $c0, $c0
    DATA BYTE $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0

    DATA BYTE $74, $54, $24, $24, $24, $24, $54, $74

tilePiece:
    DATA BYTE $7F, $1C, $41, $7F, $7F, $41, $1C, $FF
'    DATA BYTE $FF, $3C, $81, $FF, $FF, $81, $3C, $FF
'    DATA BYTE $1C, $41, $7F, $7F, $41, $1C, $00, $FF
'    DATA BYTE $7F, $41, $7F, $7F, $41, $7F, $00, $FF
tilePieceColor:
    DATA BYTE $74, $54, $24, $24, $24, $24, $54, $f4
'    DATA BYTE $74, $54, $24, $24, $24, $24, $54, $74
'    DATA BYTE $54, $24, $24, $24, $24, $54, $74, $74
'    DATA BYTE $74, $24, $24, $24, $24, $74, $74, $f4


' SPRITE PATTERNS

emptyTile:    ' this is part of selSprites, but used for 8 empty bytes
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     

cursorSprites:
    DATA BYTE $ff, $ff, $c0, $c0, $c0, $c0, $c0, $c0     ' select TL
    DATA BYTE $c0, $c0, $c0, $c0, $c0, $c0, $ff, $ff     ' select BL
    DATA BYTE $ff, $ff, $03, $03, $03, $03, $03, $03     ' select TR
    DATA BYTE $03, $03, $03, $03, $03, $03, $ff, $ff     ' select BR

' corner flow animation patterns - 7 steps for each
cornerFlowLeftUp:
    DATA BYTE $01, $01, $01, $01, $01, $01, $03, $00
    DATA BYTE $01, $01, $01, $03, $03, $07, $0F, $00
    DATA BYTE $01, $01, $01, $03, $03, $37, $1F, $00
    DATA BYTE $01, $01, $01, $03, $67, $3F, $1F, $00
    DATA BYTE $01, $01, $01, $63, $7F, $3F, $1F, $00
    DATA BYTE $01, $03, $77, $7F, $7F, $3F, $1F, $00
    DATA BYTE $03, $67, $7F, $7F, $7F, $3F, $1F, $00

cornerFlowDownLeft:
    DATA BYTE $FE, $02, $00, $00, $00, $00, $00, $00
    DATA BYTE $FE, $1E, $06, $02, $00, $00, $00, $00
    DATA BYTE $FE, $1E, $06, $02, $06, $04, $00, $00
    DATA BYTE $FE, $1E, $0E, $06, $06, $0C, $08, $00
    DATA BYTE $FE, $1E, $0E, $0E, $0E, $1C, $18, $00
    DATA BYTE $FE, $7E, $3E, $1E, $3E, $3C, $38, $00
    DATA BYTE $FE, $FE, $7E, $3E, $3E, $7C, $78, $00

' NAME TABLE MAPS

logoNamesTop:
    DATA BYTE $00, $01, $02, $03, $04, $05, $06, $07, $08, $00, $09, $0A
logoNamesBottom:
    DATA BYTE $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17

chuteNames:  ' edges and such (178)
    DATA BYTE 179, 32, 32, 32, 178
chuteBottomNames:
    DATA BYTE 181, 180, 180, 180, 182
