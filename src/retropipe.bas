GOTO main

include "vdp-utils.bas"

#fontTable:
    DATA $0100, $0900, $1100, $0500, $0D00, $1500

main:
    ' what are we working with?
    GOSUB vdpDetect

	FOR I = 0 TO 5
        DEFINE VRAM PLETTER #fontTable(I), $300, font
    NEXT I

	VDP_ENABLE_INT

	PRINT AT XY(0,0), "RetroPIPE!"
	
end:
	GOTO end


include "font.bas"