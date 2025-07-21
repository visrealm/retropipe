'
' Project: retropipe
'
' Pattern definitions (uncompressed)
'
' Copyright (c) 2025 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/retropipe

' TILE PATTERNS

digits: ' uncompressed
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

'fontColor:
'defaultColor:
'titleLogoColorWhiteGreen:
'    DATA BYTE $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
'logoColorWhiteGreen:    
'    DATA BYTE $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
  
  'YELLOW
'    DATA BYTE $b0, $a0, $a0, $a0, $a0, $a0, $a0, $a0
'    DATA BYTE $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0

' GREEN    
'   DATA BYTE $30, $20, $c0, $c0, $c0, $c0, $c0, $c0
'   DATA BYTE $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0
' RED
'   DATA BYTE $90, $80, $60, $60, $60, $60, $60, $60
'   DATA BYTE $60, $60, $60, $60, $60, $60, $60, $60

tilePiece:
    DATA BYTE $FF, $3C, $7e, $00, $00, $7e, $3C, $FF

tilePieceColor:
    DATA BYTE $74, $54, $41, $41, $41, $41, $54, $f4


' SPRITE PATTERNS

' corner flow animation patterns - 7 steps for each
' uncompressed because we want direct access to generate flow patterns
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
chuteNames:  ' edges and such (178)
    DATA BYTE 179, 32, 32, 32, 178
chuteBottomNames:
    DATA BYTE 181, 180, 180, 180, 182
