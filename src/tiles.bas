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
