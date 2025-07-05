'
' Project: retropipe
'
' Common (visrealm) input handling
'
' Copyright (c) 2025 Troy Schrapel
'
' This code is licensed under the MIT license
'
' https://github.com/visrealm/retropipe

CONST NAV_NONE = 0
CONST NAV_DOWN = 1
CONST NAV_UP = 2
CONST NAV_LEFT = 4
CONST NAV_RIGHT = 8
CONST NAV_OK = 16
CONST NAV_CANCEL = 32

DEF FN NAV(v) = (g_nav AND (v))

' -----------------------------------------------------------------------------
' centralised navigation handling for kb and joystick
' -----------------------------------------------------------------------------
updateNavInput: PROCEDURE
    g_nav = NAV_NONE
    g_key = CONT1.key

    IF g_key >= 48 AND g_key <= 57 THEN 
        g_key = g_key - 48
    ELSEIF g_key >= 65 AND g_key <= 90 THEN 
        g_key = g_key - 55
    ELSEIF g_key > 9 THEN
        g_key = 0
    END IF

    ' <DOWN> or <X>
    IF CONT.DOWN OR (CONT1.KEY = "X") THEN g_nav = g_nav OR NAV_DOWN

    ' <UP> or <E>
    IF CONT.UP OR (CONT1.KEY = "E") THEN g_nav = g_nav OR NAV_UP

    ' <RIGHT> or <D> or (<.> [>])
    IF CONT.RIGHT OR (CONT1.KEY = "D") OR (CONT1.KEY = ".") THEN g_nav = g_nav OR NAV_RIGHT

    ' <LEFT> or <S> or (<,> [<])
    IF CONT.LEFT OR (CONT1.KEY = "S") OR (CONT1.KEY = ",") THEN g_nav = g_nav OR NAV_LEFT

    ' <LBUTTON> or <SPACE> OR <ENTER>
    IF CONT.BUTTON OR CONT.BUTTON2 OR (CONT1.KEY = " ") OR (CONT1.KEY = 11) THEN g_nav = g_nav OR NAV_OK

    END


waitForInput: PROCEDURE
    WHILE 1
        WAIT

        GOSUB updateNavInput

        IF (g_nav) THEN EXIT WHILE
    WEND
    END

' -----------------------------------------------------------------------------
' delay between user input (2/15th second)
' -----------------------------------------------------------------------------
delay: PROCEDURE
    VDP_ENABLE_INT
    FOR del = 1 TO 6
        WAIT
        GOSUB updateNavInput
        IF g_nav = 0 THEN EXIT FOR
    NEXT del
    END
