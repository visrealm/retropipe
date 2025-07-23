' SOUND EFFECTS
#sfx:
DATA 0  ' easiest way to have offset of 0 mean stop

#sfxPlace:
DATA 1023,  1, 6, 12
DATA 940,   1, 5, 10
DATA 170,   1, 5, 8
DATA 170,   1, 4, 6
DATA 170,   1, 5, 4
DATA 170,   1, 4, 2
DATA 0,     0, 0, 0

#sfxBreak:
DATA 170,   0, 6, 12
DATA 170,   0, 5, 10
DATA 170,   0, 5, 0
DATA 170,   0, 6, 12
DATA 170,   0, 5, 10
DATA 170,   0, 5, 0
DATA 170,   0, 5, 12
DATA 170,   0, 4, 10
DATA 170,   0, 4, 0
DATA 0,     0, 0, 0

#sfxFall:
DATA 900,  10, 4, 12
DATA 960,  7, 5, 6
DATA 1023, 4, 6, 2
DATA 0,     0, 0, 0

#sfxWin:
DATA 120,  10, 0, 0
DATA 100,  8, 0, 0
DATA 80,   7, 0, 0
DATA 70,   6, 0, 0
DATA 120,  0, 0, 0
DATA 120,  0, 4, 4
DATA 0,    0, 0, 0

#sfxGlug:
DATA 500,  2, 0, 0
DATA 650,  4, 0, 0
DATA 800,  6, 0, 0
DATA 120,  0, 5, 5
DATA 0,    0, 0, 0

#sfxSpill:
DATA 500,  2, 0, 0
DATA 650,  4, 0, 0
DATA 800,  6, 0, 0
DATA 120,  0, 5, 5
DATA 600,  2, 0, 0
DATA 750,  4, 0, 0
DATA 900,  6, 0, 0
DATA 120,  0, 6, 5
DATA 700,  2, 0, 0
DATA 950,  4, 0, 0
DATA 1000, 6, 0, 0
DATA 120,  0, 6, 5
DATA 0,    0, 0, 0


DIM #sfxIndex

DEF FN PLAY_SFX(addr) = #sfxIndex = (((VARPTR addr(0)) - (VARPTR #sfx(0))) / 2)

ON FRAME GOSUB audioTick

' every frame
audioTick: PROCEDURE
  IF #sfxIndex = 0 THEN RETURN

  IF (FRAME AND 1) THEN RETURN
  
  #ch2 = #sfx(#sfxIndex)
  ch2Vol = #sfx(#sfxIndex + 1) and $F
  ch3 = #sfx(#sfxIndex + 2)
  ch3Vol = #sfx(#sfxIndex + 3) and $F

#if PSG_SN76489
  #info "SN76489"
  SOUND 0, #ch2, ch2Vol
  SOUND 3, ch3, ch3Vol
#else'if PSG_AY38910
  #info "AY-3-8910"
  SOUND 5, #ch2, ch2Vol
  SOUND 7, 0,   ch3Vol
  SOUND 9, ch3, $DE
#endif

  IF #ch2 = 0 THEN
    #sfxIndex = 0
#if PSG_AY38910
    SOUND 9,, $38
#endif
  ELSE
    #sfxIndex = #sfxIndex + 4
  END IF

  END