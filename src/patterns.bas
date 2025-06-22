grid:   ' empty grid (128)
    DATA BYTE $ff, $80, $80, $80, $80, $80, $80, $80
    DATA BYTE $ff, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $fe, $01, $01, $01, $01, $01, $01, $01
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $80
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $ff
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $ff
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $ff    

base: ' filled base (137)
    DATA BYTE $49, $92, $24, $49, $92, $24, $49, $92
    DATA BYTE $24, $49, $92, $24, $49, $92, $24, $49
    DATA BYTE $93, $25, $49, $93, $25, $49, $93, $25
    DATA BYTE $24, $49, $92, $24, $49, $92, $24, $49
    DATA BYTE $92, $24, $49, $92, $24, $49, $92, $24
    DATA BYTE $49, $93, $25, $49, $93, $25, $49, $93
    DATA BYTE $92, $24, $49, $92, $24, $49, $92, $FF
    DATA BYTE $49, $92, $24, $49, $92, $24, $49, $FF
    DATA BYTE $25, $49, $93, $25, $49, $93, $25, $FE

    ' corners when pipes around (146)
baseCornersTL:
    DATA BYTE $49, $92, $24, $49, $92, $24, $49, $F2     ' H
    DATA BYTE $49, $93, $25, $49, $92, $24, $49, $92     ' V
    DATA BYTE $49, $93, $25, $49, $92, $24, $49, $F2     ' X
baseCornersTR:  ' (149)
    DATA BYTE $93, $25, $49, $93, $25, $49, $93, $27     ' H
    DATA BYTE $93, $A5, $C9, $93, $25, $49, $93, $25     ' V
    DATA BYTE $93, $A5, $C9, $93, $25, $49, $93, $27     ' X
baseCornersBL:  ' (152)
    DATA BYTE $F2, $24, $49, $92, $24, $49, $92, $FF     ' H
    DATA BYTE $92, $24, $49, $92, $24, $49, $93, $FF     ' V
    DATA BYTE $F2, $24, $49, $92, $24, $49, $93, $FF     ' X
baseCornersBR:  ' (155)
    DATA BYTE $27, $49, $93, $25, $49, $93, $25, $FE     ' H
    DATA BYTE $25, $49, $93, $25, $49, $93, $A5, $FE     ' V
    DATA BYTE $27, $49, $93, $25, $49, $93, $A5, $FE     ' X

pipes:  ' empty (158) and filled (168)
    DATA BYTE $FF, $00, $00, $00, $00, $00, $00, $FF    ' H
    DATA BYTE $3F, $00, $00, $00, $00, $00, $00, $3F    ' L
    DATA BYTE $FC, $00, $00, $00, $00, $00, $00, $FC    ' R
    DATA BYTE $81, $81, $81, $81, $81, $81, $81, $81    ' V
    DATA BYTE $00, $00, $81, $81, $81, $81, $81, $81    ' T
    DATA BYTE $81, $81, $81, $81, $81, $81, $00, $00    ' B
    ' corners (164) and filled (174)
    DATA BYTE $FF, $07, $03, $01, $01, $01, $01, $01    ' DL
    DATA BYTE $FF, $E0, $C0, $80, $80, $80, $80, $80    ' DR
    DATA BYTE $80, $80, $80, $80, $80, $C0, $E0, $FF    ' UR
    DATA BYTE $01, $01, $01, $01, $01, $03, $07, $FF    ' UL

logo:
    DATA BYTE $0F, $3F, $7F, $7F, $F8, $F0, $F1, $F3     
    DATA BYTE $80, $C0, $E0, $F0, $F0, $F1, $F3, $F3     
    DATA BYTE $00, $00, $00, $00, $7C, $FE, $FF, $C7     
    DATA BYTE $3C, $3C, $3C, $3C, $3F, $3F, $3F, $3F     
    DATA BYTE $00, $00, $00, $00, $0E, $3F, $3F, $7F     
    DATA BYTE $00, $00, $00, $00, $07, $9F, $BF, $3F     
    DATA BYTE $00, $00, $01, $01, $83, $E3, $F3, $F3     
    DATA BYTE $3C, $FF, $FF, $FF, $E3, $C3, $C7, $CF     
    DATA BYTE $1E, $1E, $9E, $DE, $DE, $DE, $DE, $DE     
    DATA BYTE $00, $C3, $E3, $F7, $F7, $F7, $F7, $F7     
    DATA BYTE $FC, $FC, $FC, $FC, $80, $80, $FC, $FC     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $F7, $F7, $F7, $F7, $F3, $F3, $F1, $F1     
    DATA BYTE $E7, $C7, $C7, $C7, $E7, $E3, $F1, $F0     
    DATA BYTE $87, $9F, $9F, $C0, $F0, $FF, $FE, $7C     
    DATA BYTE $BC, $BC, $3E, $3F, $1F, $1F, $0F, $07     
    DATA BYTE $79, $78, $78, $78, $78, $78, $78, $78     
    DATA BYTE $7C, $78, $78, $7C, $3F, $3F, $1F, $07     
    DATA BYTE $FB, $7B, $7B, $FB, $F3, $F3, $E3, $83     
    DATA BYTE $DF, $DE, $DC, $C0, $C0, $C0, $C0, $C0     
    DATA BYTE $9E, $1E, $1E, $1E, $1E, $1E, $1E, $1E     
    DATA BYTE $F7, $F7, $F7, $F0, $F0, $F0, $F0, $F0     
    DATA BYTE $E7, $87, $07, $07, $07, $03, $03, $00     
    DATA BYTE $FC, $FC, $80, $80, $FC, $FC, $FC, $FC     


logoNamesTop:
    DATA BYTE $00, $01, $02, $03, $04, $05, $06, $07, $08, $00, $09, $0A
logoNamesBottom:
    DATA BYTE $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17



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

baseColor:
    DATA BYTE $45, $45, $45, $45, $45, $45, $45, $45

pipeColor:
    DATA BYTE $41, $41, $41, $41, $41, $41, $41, $41

pipeColorGreen:
    DATA BYTE $42, $42, $42, $42, $42, $42, $42, $42


selSprites:
    DATA BYTE $55, $80, $00, $80, $00, $80, $00, $80     
    DATA BYTE $00, $80, $00, $80, $00, $80, $00, $80     
    DATA BYTE $55, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $55, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $80, $00, $80, $00, $80, $00, $80     
    DATA BYTE $00, $80, $00, $80, $00, $80, $00, $80     
    DATA BYTE $00, $80, $00, $80, $00, $80, $00, $80     
    DATA BYTE $55, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $55, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $55, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $80, $00, $80, $00, $80, $00, $80     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     

    DATA BYTE $AA, $00, $80, $00, $80, $00, $80, $00     
    DATA BYTE $80, $00, $80, $00, $80, $00, $80, $00     
    DATA BYTE $AA, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $AA, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $80, $00, $80, $00, $80, $00, $80, $00     
    DATA BYTE $80, $00, $80, $00, $80, $00, $80, $00     
    DATA BYTE $80, $00, $80, $00, $80, $00, $80, $00     
    DATA BYTE $AA, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $AA, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $AA, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $80, $00, $80, $00, $80, $00, $80, $00     
    DATA BYTE $80, $00, $00, $00, $00, $00, $00, $00     


cellNames:
    ' grid
    DATA BYTE 128, 129, 130
    DATA BYTE 131, 132, 133
    DATA BYTE 134, 135, 136    
    ' base
    DATA BYTE 137, 138, 139
    DATA BYTE 140, 141, 142
    DATA BYTE 143, 144, 145        
    ' h -
    DATA BYTE 146, 138, 149
    DATA BYTE 159, 158, 160
    DATA BYTE 152, 144, 155            
    ' v |
    DATA BYTE 147, 162, 150
    DATA BYTE 140, 161, 142
    DATA BYTE 153, 163, 156        
    ' x +
    DATA BYTE 148, 162, 150
    DATA BYTE 159, 161, 160
    DATA BYTE 154, 163, 157        
    ' dr /
    DATA BYTE 137, 138, 149
    DATA BYTE 140, 165, 160
    DATA BYTE 153, 163, 157       
    ' dl \
    DATA BYTE 146, 138, 139
    DATA BYTE 159, 164, 142
    DATA BYTE 154, 163, 156        
    ' ur \
    DATA BYTE 147, 162, 150
    DATA BYTE 140, 166, 160
    DATA BYTE 143, 144, 155        
    ' ul /
    DATA BYTE 148, 162, 139
    DATA BYTE 159, 167, 142
    DATA BYTE 152, 144, 145        
    ' filled h -
    DATA BYTE 146, 138, 149
    DATA BYTE 169, 168, 170
    DATA BYTE 152, 144, 155            
    ' filled v |
    DATA BYTE 147, 172, 150
    DATA BYTE 140, 171, 142
    DATA BYTE 153, 173, 156        
    ' filled xh +- 
    DATA BYTE 148, 162, 150
    DATA BYTE 169, 161, 170
    DATA BYTE 154, 163, 157        
    ' filled xv +|
    DATA BYTE 148, 172, 150
    DATA BYTE 159, 171, 160
    DATA BYTE 154, 173, 157        
    ' filled xx ++
    DATA BYTE 148, 172, 150
    DATA BYTE 169, 171, 170
    DATA BYTE 154, 173, 157        
    ' filled dr /
    DATA BYTE 137, 138, 149
    DATA BYTE 140, 175, 170
    DATA BYTE 153, 173, 157       
    ' filled dl \
    DATA BYTE 146, 138, 139
    DATA BYTE 169, 174, 142
    DATA BYTE 154, 173, 156        
    ' filled ur \
    DATA BYTE 137, 172, 150
    DATA BYTE 140, 176, 170
    DATA BYTE 143, 144, 155        
    ' filled ul /
    DATA BYTE 148, 172, 139
    DATA BYTE 169, 177, 142
    DATA BYTE 152, 144, 145      
