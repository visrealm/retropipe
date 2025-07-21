'
' Project: retropipe
'
' UI patterns
'
' Copyright (c) 2025 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/retropipe

uiTiles:
  DATA BYTE $E0, $C0, $80, $0F, $1F, $1C, $18, $18 ' TL
  DATA BYTE $00, $00, $00, $FF, $FF, $00, $00, $00 ' TC
  DATA BYTE $07, $03, $01, $F0, $F8, $38, $18, $18 ' TR
  DATA BYTE $18, $18, $18, $18, $18, $18, $18, $18 ' ML
  DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00 ' MC
  DATA BYTE $18, $18, $18, $18, $18, $18, $18, $18 ' MR
  DATA BYTE $18, $1C, $1F, $0F, $80, $C0, $E0, $F0 ' BL
  DATA BYTE $00, $00, $FF, $FF, $00, $00, $00, $00 ' BC
  DATA BYTE $18, $38, $F8, $F0, $01, $03, $07, $0F ' BR
  DATA BYTE $18, $18, $1C, $1F, $1F, $1C, $18, $18 ' LH
  DATA BYTE $18, $18, $38, $F8, $F8, $38, $18, $18 ' RH

uiTilesColor:
  DATA BYTE $54, $54, $54, $74, $74, $74, $74, $74
  DATA BYTE $74, $14, $14, $74, $74, $14, $14, $14
  DATA BYTE $54, $54, $54, $74, $74, $74, $74, $74
  DATA BYTE $74, $74, $74, $74, $74, $74, $74, $74
  DATA BYTE $14, $14, $14, $14, $14, $14, $14, $14
  DATA BYTE $74, $74, $74, $74, $74, $74, $74, $74
  DATA BYTE $74, $74, $74, $74, $54, $54, $54, $51
  DATA BYTE $14, $14, $74, $74, $74, $14, $14, $41
  DATA BYTE $74, $74, $74, $74, $54, $54, $54, $51
  DATA BYTE $74, $74, $74, $74, $74, $74, $74, $74
  DATA BYTE $74, $74, $74, $74, $74, $74, $74, $74