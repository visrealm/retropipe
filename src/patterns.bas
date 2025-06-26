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
 
logo: ' RetroPIPE logo (0)
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
    DATA BYTE $F7, $F7, $F7, $F7, $F3, $F3, $F1, $F1     ' bottom (12)
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

borders:  ' edges and such (178)
    DATA BYTE $C1, $C1, $C1, $C1, $C1, $C1, $C1, $C1    ' chute R
    DATA BYTE $06, $06, $06, $06, $06, $06, $06, $06    ' chute L
    DATA BYTE $FF, $FF, $00, $00, $00, $00, $00, $00    ' chute B
    DATA BYTE $07, $03, $00, $00, $00, $00, $00, $00    ' chute BL
    DATA BYTE $C1, $81, $01, $01, $01, $01, $01, $01    ' chute BR
    DATA BYTE $01, $01, $01, $01, $01, $01, $01, $01    ' map L
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $FF    ' map T

' TILE COLORS

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

logoColorWhiteGreen:
    DATA BYTE $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
    DATA BYTE $30, $20, $c0, $c0, $c0, $c0, $c0, $c0

' SPRITE PATTERNS

selSprites:
    DATA BYTE $ff, $ff, $c0, $c0, $c0, $c0, $c0, $c0     ' select TL
    DATA BYTE $c0, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $7f, $7f, $01, $01, $01, $01, $01, $01     ' select TR
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $80, $80, $80, $80, $80, $80, $80, $80     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $c0, $c0, $c0, $c0, $c0, $c0, $ff     ' select BL
    DATA BYTE $ff, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $01, $01, $01, $01, $01, $01, $7f     ' select BR
    DATA BYTE $7f, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $80, $80, $80, $80, $80, $80, $80     
    DATA BYTE $80, $00, $00, $00, $00, $00, $00, $00     

    DATA BYTE $AA, $00, $80, $00, $80, $00, $80, $00     ' select TL
    DATA BYTE $80, $00, $80, $00, $80, $00, $80, $00     
    DATA BYTE $AA, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $AA, $00, $00, $00, $00, $00, $00, $00     ' select TR
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $80, $00, $80, $00, $80, $00, $80, $00     
    DATA BYTE $80, $00, $80, $00, $80, $00, $80, $00     
    DATA BYTE $80, $00, $80, $00, $80, $00, $80, $00     ' select BL
    DATA BYTE $AA, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $AA, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00     ' select BR
    DATA BYTE $AA, $00, $00, $00, $00, $00, $00, $00     
    DATA BYTE $80, $00, $80, $00, $80, $00, $80, $00     
    DATA BYTE $80, $00, $00, $00, $00, $00, $00, $00     

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

reverseBits:
    DATA BYTE $00, $80, $40, $C0, $20, $A0, $60, $E0, $10, $90, $50, $D0, $30, $B0, $70, $F0
    DATA BYTE $08, $88, $48, $C8, $28, $A8, $68, $E8, $18, $98, $58, $D8, $38, $B8, $78, $F8
    DATA BYTE $04, $84, $44, $C4, $24, $A4, $64, $E4, $14, $94, $54, $D4, $34, $B4, $74, $F4
    DATA BYTE $0C, $8C, $4C, $CC, $2C, $AC, $6C, $EC, $1C, $9C, $5C, $DC, $3C, $BC, $7C, $FC
    DATA BYTE $02, $82, $42, $C2, $22, $A2, $62, $E2, $12, $92, $52, $D2, $32, $B2, $72, $F2
    DATA BYTE $0A, $8A, $4A, $CA, $2A, $AA, $6A, $EA, $1A, $9A, $5A, $DA, $3A, $BA, $7A, $FA
    DATA BYTE $06, $86, $46, $C6, $26, $A6, $66, $E6, $16, $96, $56, $D6, $36, $B6, $76, $F6
    DATA BYTE $0E, $8E, $4E, $CE, $2E, $AE, $6E, $EE, $1E, $9E, $5E, $DE, $3E, $BE, $7E, $FE
    DATA BYTE $01, $81, $41, $C1, $21, $A1, $61, $E1, $11, $91, $51, $D1, $31, $B1, $71, $F1
    DATA BYTE $09, $89, $49, $C9, $29, $A9, $69, $E9, $19, $99, $59, $D9, $39, $B9, $79, $F9
    DATA BYTE $05, $85, $45, $C5, $25, $A5, $65, $E5, $15, $95, $55, $D5, $35, $B5, $75, $F5
    DATA BYTE $0D, $8D, $4D, $CD, $2D, $AD, $6D, $ED, $1D, $9D, $5D, $DD, $3D, $BD, $7D, $FD
    DATA BYTE $03, $83, $43, $C3, $23, $A3, $63, $E3, $13, $93, $53, $D3, $33, $B3, $73, $F3
    DATA BYTE $0B, $8B, $4B, $CB, $2B, $AB, $6B, $EB, $1B, $9B, $5B, $DB, $3B, $BB, $7B, $FB
    DATA BYTE $07, $87, $47, $C7, $27, $A7, $67, $E7, $17, $97, $57, $D7, $37, $B7, $77, $F7
    DATA BYTE $0F, $8F, $4F, $CF, $2F, $AF, $6F, $EF, $1F, $9F, $5F, $DF, $3F, $BF, $7F, $FF

' NAME TABLE MAPS


logoNamesTop:
    DATA BYTE $00, $01, $02, $03, $04, $05, $06, $07, $08, $00, $09, $0A
logoNamesBottom:
    DATA BYTE $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17

chuteNames:  ' edges and such (178)
    DATA BYTE 179, 32, 32, 32, 178
chuteBottomNames:
    DATA BYTE 181, 180, 180, 180, 182

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
    DATA BYTE 148, 162, 151
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
    DATA BYTE 147, 162, 151
    DATA BYTE 140, 166, 160
    DATA BYTE 143, 144, 155        
    ' ul /
    DATA BYTE 148, 162, 150
    DATA BYTE 159, 167, 142
    DATA BYTE 152, 144, 145

    ' start (left)
    DATA BYTE 146, 138, 149
    DATA BYTE 159, 158, "S"
    DATA BYTE 152, 144, 155            

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
    ' clear
    DATA BYTE 32, 32, 32
    DATA BYTE 32, 32, 32
    DATA BYTE 32, 32, 32    
