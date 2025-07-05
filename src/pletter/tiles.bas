'
' Project: retropipe
'
' Pattern definitions (compressed)
'
' Copyright (c) 2025 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/retropipe
   
' empty grid (128)
grid:
    DATA BYTE $ff, $80, $80, $80, $80, $80, $80, $80    ' TL
    DATA BYTE $ff, $00, $00, $00, $00, $00, $00, $00    ' TC
    DATA BYTE $fe, $01, $01, $01, $01, $01, $01, $01    ' TR
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $80    ' ML
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00    ' MC
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01    ' MR
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $ff    ' BL
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $ff    ' BC
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $ff    ' BR

'base filled base (137)
    DATA BYTE $49, $92, $24, $49, $92, $24, $49, $92    ' TL
    DATA BYTE $24, $49, $92, $24, $49, $92, $24, $49    ' TC
    DATA BYTE $93, $25, $49, $93, $25, $49, $93, $25    ' TR
    DATA BYTE $24, $49, $92, $24, $49, $92, $24, $49    ' ML
    DATA BYTE $92, $24, $49, $92, $24, $49, $92, $24    ' MC
    DATA BYTE $49, $93, $25, $49, $93, $25, $49, $93    ' MR
    DATA BYTE $92, $24, $49, $92, $24, $49, $92, $FF    ' BL
    DATA BYTE $49, $92, $24, $49, $92, $24, $49, $FF    ' BC
    DATA BYTE $25, $49, $93, $25, $49, $93, $25, $FE    ' BR

'base corners when pipes around (146)
'baseCornersTL
    DATA BYTE $49, $92, $24, $49, $92, $24, $49, $F2    ' H
    DATA BYTE $49, $93, $25, $49, $92, $24, $49, $92    ' V
    DATA BYTE $49, $93, $25, $49, $92, $24, $49, $F2    ' X
'baseCornersTR (149)
    DATA BYTE $93, $25, $49, $93, $25, $49, $93, $27    ' H
    DATA BYTE $93, $A5, $C9, $93, $25, $49, $93, $25    ' V
    DATA BYTE $93, $A5, $C9, $93, $25, $49, $93, $27    ' X
'baseCornersBL (152)
    DATA BYTE $F2, $24, $49, $92, $24, $49, $92, $FF    ' H
    DATA BYTE $92, $24, $49, $92, $24, $49, $93, $FF    ' V
    DATA BYTE $F2, $24, $49, $92, $24, $49, $93, $FF    ' X
'baseCornersBR (155)
    DATA BYTE $27, $49, $93, $25, $49, $93, $25, $FE    ' H
    DATA BYTE $25, $49, $93, $25, $49, $93, $A5, $FE    ' V
    DATA BYTE $27, $49, $93, $25, $49, $93, $A5, $FE    ' X

' empty (158) and filled (168)
pipes:
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

' edges and such (178)
borders:  
    DATA BYTE $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1    ' chute R
    DATA BYTE $06, $06, $06, $06, $06, $06, $06, $06    ' chute L
    DATA BYTE $FF, $FF, $00, $00, $00, $00, $00, $00    ' chute B
    DATA BYTE $07, $03, $00, $00, $00, $00, $00, $00    ' chute BL
    DATA BYTE $C1, $81, $01, $01, $01, $01, $01, $01    ' chute BR
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01    ' map L
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $FF    ' map T