'
' Project: retropipe
'
' Sprite patterns
'
' Copyright (c) 2025 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/retropipe

spillPatt:
    DATA BYTE $00, $00, $00, $00, $00, $01, $03, $03     
    DATA BYTE $03, $03, $01, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $80, $C0, $E0     
    DATA BYTE $E0, $C0, $C0, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $03, $03, $0F, $0F     
    DATA BYTE $07, $07, $07, $03, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $C0, $E0, $E0, $F0     
    DATA BYTE $E0, $C0, $C0, $80, $00, $00, $00, $00     
    DATA BYTE $00, $00, $03, $07, $0F, $0F, $1F, $1F     
    DATA BYTE $1F, $1F, $0F, $0F, $04, $00, $00, $00     
    DATA BYTE $00, $00, $00, $F0, $F8, $F8, $F8, $F8     
    DATA BYTE $F8, $F0, $F0, $E0, $40, $00, $00, $00     
    DATA BYTE $00, $04, $07, $0F, $1F, $3F, $3F, $3F     
    DATA BYTE $1F, $0F, $0F, $1F, $1F, $0F, $0C, $00     
    DATA BYTE $00, $00, $C0, $E0, $F8, $F8, $FC, $FC     
    DATA BYTE $F8, $F8, $F0, $E0, $C0, $C0, $00, $00     
    DATA BYTE $00, $1F, $1F, $1F, $3F, $3F, $7F, $7F     
    DATA BYTE $7F, $7F, $7F, $7F, $1F, $0F, $0F, $00     
    DATA BYTE $00, $80, $C0, $F0, $FC, $FE, $FE, $FC     
    DATA BYTE $FC, $FC, $FC, $FC, $FC, $F0, $C0, $00     
    DATA BYTE $1F, $3F, $3F, $3F, $3F, $3F, $7F, $FF     
    DATA BYTE $FF, $FF, $FF, $FF, $7F, $1F, $0F, $0F     
    DATA BYTE $00, $80, $F0, $FE, $FF, $FF, $FF, $FF     
    DATA BYTE $FC, $FC, $FE, $FE, $FE, $FC, $E0, $C0     

cursorSprites:
    DATA BYTE $ff, $ff, $c0, $c0, $c0, $c0, $c0, $c0     ' select TL
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $c0, $c0, $c0, $c0, $c0, $c0, $ff, $ff     ' select BL
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $ff, $ff, $03, $03, $03, $03, $03, $03     ' select TR
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $03, $03, $03, $03, $03, $03, $ff, $ff     ' select BR
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00

crackPatt:
    DATA BYTE $00, $00, $00, $00, $00, $00, $04, $03     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $80     
    DATA BYTE $40, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $08, $04, $04, $03     
    DATA BYTE $02, $04, $04, $08, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $80     
    DATA BYTE $60, $10, $10, $08, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $30, $08, $04, $04, $03     
    DATA BYTE $02, $04, $04, $18, $20, $40, $00, $00     
    DATA BYTE $00, $00, $00, $00, $04, $04, $08, $90     
    DATA BYTE $60, $10, $10, $08, $08, $14, $20, $40     
    DATA BYTE $82, $41, $40, $30, $08, $04, $04, $03     
    DATA BYTE $02, $04, $04, $18, $24, $42, $42, $80     
    DATA BYTE $00, $80, $40, $23, $24, $44, $48, $90     
    DATA BYTE $60, $10, $10, $08, $08, $14, $22, $41     

explodePatt: ' 6 x sprites for explosion / dust
    DATA BYTE $00,$00,$00,$00,$00,$00,$00,$01
    DATA BYTE $00,$02,$00,$00,$00,$00,$00,$00
    DATA BYTE $00,$00,$00,$00,$00,$00,$40,$00
    DATA BYTE $00,$80,$00,$00,$00,$00,$00,$00
    DATA BYTE $00,$00,$00,$00,$00,$00,$02,$00
    DATA BYTE $01,$00,$05,$00,$00,$00,$00,$00
    DATA BYTE $00,$00,$00,$00,$00,$20,$00,$40
    DATA BYTE $00,$00,$40,$00,$00,$00,$00,$00
    DATA BYTE $00,$00,$00,$00,$01,$00,$0A,$00
    DATA BYTE $09,$00,$09,$00,$00,$00,$00,$00
    DATA BYTE $00,$00,$00,$00,$00,$20,$00,$48
    DATA BYTE $20,$04,$40,$10,$80,$00,$00,$00
    DATA BYTE $00,$00,$01,$00,$01,$04,$10,$42
    DATA BYTE $10,$00,$20,$0A,$00,$24,$00,$00
    DATA BYTE $00,$00,$00,$10,$00,$24,$00,$48
    DATA BYTE $20,$04,$40,$10,$84,$00,$20,$00
    DATA BYTE $00,$02,$00,$12,$00,$00,$14,$40
    DATA BYTE $00,$00,$20,$00,$00,$04,$41,$00
    DATA BYTE $00,$00,$08,$00,$12,$00,$00,$08
    DATA BYTE $00,$00,$02,$08,$20,$02,$00,$10
    DATA BYTE $04,$00,$20,$00,$40,$00,$00,$00
    DATA BYTE $80,$00,$00,$40,$00,$00,$00,$02
    DATA BYTE $00,$04,$00,$01,$00,$00,$00,$00
    DATA BYTE $00,$00,$00,$01,$00,$00,$40,$00
