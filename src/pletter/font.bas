'
' Project: retropipe
'
' Standard (visrealm) font
'
' Copyright (c) 2025 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/retropipe

font0:
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $00 ' <SPACE$
    DATA BYTE $18, $18, $18, $18, $18, $00, $18, $00 ' !
    DATA BYTE $6C, $6C, $6C, $00, $00, $00, $00, $00 ' "
    DATA BYTE $6C, $6C, $FE, $6C, $FE, $6C, $6C, $00 ' #
    DATA BYTE $18, $7E, $C0, $7C, $06, $FC, $18, $00 ' $
    DATA BYTE $00, $C6, $CC, $18, $30, $66, $C6, $00 ' %
    DATA BYTE $38, $6C, $38, $76, $DC, $CC, $76, $00 ' &
    DATA BYTE $30, $30, $60, $00, $00, $00, $00, $00 ' '
    DATA BYTE $0C, $18, $30, $30, $30, $18, $0C, $00 ' (
    DATA BYTE $30, $18, $0C, $0C, $0C, $18, $30, $00 ' )
    DATA BYTE $00, $66, $3C, $FF, $3C, $66, $00, $00 ' *
    DATA BYTE $00, $18, $18, $7E, $18, $18, $00, $00 ' +
    DATA BYTE $00, $00, $00, $00, $00, $18, $18, $30 ' ,
    DATA BYTE $00, $00, $00, $7E, $00, $00, $00, $00 ' -
    DATA BYTE $00, $00, $00, $00, $00, $18, $18, $00 ' .
    DATA BYTE $06, $0C, $18, $30, $60, $C0, $80, $00 ' /
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
    DATA BYTE $00, $18, $18, $00, $00, $18, $18, $00 ' :
    DATA BYTE $00, $18, $18, $00, $00, $18, $18, $30 ' ;
    DATA BYTE $0C, $18, $30, $60, $30, $18, $0C, $00 ' <
    DATA BYTE $00, $00, $7E, $00, $7E, $00, $00, $00 ' =
    DATA BYTE $30, $18, $0C, $06, $0C, $18, $30, $00 ' >
    DATA BYTE $3C, $66, $0C, $18, $18, $00, $18, $00 ' ?
font1:    
    DATA BYTE $7C, $C6, $DE, $DE, $DE, $C0, $7E, $00 ' @
    DATA BYTE $38, $6C, $C6, $C6, $FE, $C6, $C6, $00 ' A
    DATA BYTE $FC, $C6, $C6, $FC, $C6, $C6, $FC, $00 ' B
    DATA BYTE $7C, $C6, $C0, $C0, $C0, $C6, $7C, $00 ' C
    DATA BYTE $F8, $CC, $C6, $C6, $C6, $CC, $F8, $00 ' D
    DATA BYTE $FE, $C0, $C0, $F8, $C0, $C0, $FE, $00 ' E
    DATA BYTE $FE, $C0, $C0, $F8, $C0, $C0, $C0, $00 ' F
    DATA BYTE $7C, $C6, $C0, $C0, $CE, $C6, $7C, $00 ' G
    DATA BYTE $C6, $C6, $C6, $FE, $C6, $C6, $C6, $00 ' H
    DATA BYTE $7E, $18, $18, $18, $18, $18, $7E, $00 ' I
    DATA BYTE $06, $06, $06, $06, $06, $C6, $7C, $00 ' J
    DATA BYTE $C6, $CC, $D8, $F0, $D8, $CC, $C6, $00 ' K
    DATA BYTE $C0, $C0, $C0, $C0, $C0, $C0, $FE, $00 ' L
    DATA BYTE $C6, $EE, $FE, $FE, $D6, $C6, $C6, $00 ' M
    DATA BYTE $C6, $E6, $F6, $DE, $CE, $C6, $C6, $00 ' N
    DATA BYTE $7C, $C6, $C6, $C6, $C6, $C6, $7C, $00 ' O
    DATA BYTE $FC, $C6, $C6, $FC, $C0, $C0, $C0, $00 ' P
    DATA BYTE $7C, $C6, $C6, $C6, $D6, $DE, $7C, $06 ' Q
    DATA BYTE $FC, $C6, $C6, $FC, $D8, $CC, $C6, $00 ' R
    DATA BYTE $7C, $C6, $C0, $7C, $06, $C6, $7C, $00 ' S
    DATA BYTE $FF, $18, $18, $18, $18, $18, $18, $00 ' T
    DATA BYTE $C6, $C6, $C6, $C6, $C6, $C6, $FE, $00 ' U
    DATA BYTE $C6, $C6, $C6, $C6, $C6, $7C, $38, $00 ' V
    DATA BYTE $C6, $C6, $C6, $C6, $D6, $FE, $6C, $00 ' W
    DATA BYTE $C6, $C6, $6C, $38, $6C, $C6, $C6, $00 ' X
    DATA BYTE $C6, $C6, $C6, $7C, $18, $30, $E0, $00 ' Y
    DATA BYTE $FE, $06, $0C, $18, $30, $60, $FE, $00 ' Z
    DATA BYTE $3F, $60, $CF, $D8, $D8, $CF, $60, $3F
    DATA BYTE $C0, $60, $30, $18, $0C, $06, $02, $00 ' \
    DATA BYTE $C0, $60, $30, $30, $30, $30, $60, $C0
    DATA BYTE $10, $38, $6C, $C6, $00, $00, $00, $00 ' ^
    DATA BYTE $00, $00, $00, $00, $00, $00, $00, $FF ' _
font2:
    DATA BYTE $18, $24, $24, $18, $00, $00, $00, $00 ' ` 
    DATA BYTE $00, $00, $7C, $06, $7E, $C6, $7E, $00 ' a
    DATA BYTE $C0, $C0, $C0, $FC, $C6, $C6, $FC, $00 ' b
    DATA BYTE $00, $00, $7C, $C6, $C0, $C6, $7C, $00 ' c
    DATA BYTE $06, $06, $06, $7E, $C6, $C6, $7E, $00 ' d
    DATA BYTE $00, $00, $7C, $C6, $FE, $C0, $7C, $00 ' e
    DATA BYTE $1C, $36, $30, $78, $30, $30, $78, $00 ' f
    DATA BYTE $00, $00, $7E, $C6, $C6, $7E, $06, $FC ' g
    DATA BYTE $C0, $C0, $FC, $C6, $C6, $C6, $C6, $00 ' h
    DATA BYTE $18, $00, $38, $18, $18, $18, $3C, $00 ' i
    DATA BYTE $06, $00, $06, $06, $06, $06, $C6, $7C ' j
    DATA BYTE $C0, $C0, $CC, $D8, $F8, $CC, $C6, $00 ' k
    DATA BYTE $38, $18, $18, $18, $18, $18, $3C, $00 ' l
    DATA BYTE $00, $00, $CC, $FE, $FE, $D6, $D6, $00 ' m
    DATA BYTE $00, $00, $FC, $C6, $C6, $C6, $C6, $00 ' n
    DATA BYTE $00, $00, $7C, $C6, $C6, $C6, $7C, $00 ' o
    DATA BYTE $00, $00, $FC, $C6, $C6, $FC, $C0, $C0 ' p
    DATA BYTE $00, $00, $7E, $C6, $C6, $7E, $06, $06 ' q
    DATA BYTE $00, $00, $FC, $C6, $C0, $C0, $C0, $00 ' r
    DATA BYTE $00, $00, $7E, $C0, $7C, $06, $FC, $00 ' s
    DATA BYTE $18, $18, $7E, $18, $18, $18, $0E, $00 ' t
    DATA BYTE $00, $00, $C6, $C6, $C6, $C6, $7E, $00 ' u
    DATA BYTE $00, $00, $C6, $C6, $C6, $7C, $38, $00 ' v
    DATA BYTE $00, $00, $C6, $C6, $D6, $FE, $6C, $00 ' w
    DATA BYTE $00, $00, $C6, $6C, $38, $6C, $C6, $00 ' x
    DATA BYTE $00, $00, $C6, $C6, $C6, $7E, $06, $FC ' y
    DATA BYTE $00, $00, $FE, $0C, $38, $60, $FE, $00 ' z
    DATA BYTE $3F, $60, $CF, $D8, $D8, $CF, $60, $3F
    DATA BYTE $18, $18, $18, $00, $18, $18, $18, $00 ' |
    DATA BYTE $C0, $60, $30, $30, $30, $30, $60, $C0
    DATA BYTE $76, $DC, $00, $00, $00, $00, $00, $00 ' ~
    DATA BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF '  