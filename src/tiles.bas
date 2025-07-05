'
' Project: retropipe
'
' Game tile name table definitions
'
' Copyright (c) 2025 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/retropipe

CONST CELL_GRID      = 0
CONST CELL_BASE      = 1
CONST CELL_PIPE_H    = 2
CONST CELL_PIPE_V    = 3
CONST CELL_PIPE_X    = 4
CONST CELL_PIPE_DR   = 5
CONST CELL_PIPE_DL   = 6
CONST CELL_PIPE_UR   = 7
CONST CELL_PIPE_UL   = 8
CONST CELL_PIPE_ST   = 9

CONST CELL_CLEAR     = 13

CONST CELL_LOCKED_FLAG = $80
CONST CELL_TILE_MASK   = $0f

' the location of these is computed from the CELL_ constants above
' cellNames + CELL_XXXX * 9
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

    ' start (flow right)
    DATA BYTE 146, 138, 149
    DATA BYTE "S", 158, 160
    DATA BYTE 152, 144, 155            

    ' start (down down)
    DATA BYTE 147, "S", 150
    DATA BYTE 140, 161, 142
    DATA BYTE 153, 163, 156        

    ' start (flow left)
    DATA BYTE 146, 138, 149
    DATA BYTE 159, 158, "S"
    DATA BYTE 152, 144, 155            

    ' start (flow up)
    DATA BYTE 147, 162, 150
    DATA BYTE 140, 161, 142
    DATA BYTE 153, "S", 156        

    ' clear
    DATA BYTE 32, 32, 32
    DATA BYTE 32, 32, 32
    DATA BYTE 32, 32, 32    
