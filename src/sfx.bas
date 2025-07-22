' SOUND EFFECTS
#sfx:
DATA 0  ' easiest way to have offset of 0 mean stop

#if PSG_SN76489
#sfxPlace:

DATA 1023,  2, 7, 12
DATA 940,   1, 6, 10
DATA 170,   0, 6, 8
DATA 170,   0, 4, 6
DATA 170,   0, 5, 4
DATA 170,   0, 4, 2
DATA 0,     0, 0, 0

#elif PSG_AY38910

#sfxPlace:
DATA 1023,  2, 7, 12
DATA 940,   1, 6, 10
DATA 170,   0, 6, 8
DATA 170,   0, 4, 6
DATA 170,   0, 5, 4
DATA 170,   0, 4, 2
DATA 0,     0, 0, 0

#endif


DIM #sfxIndex

DEF FN PLAY_SFX(addr) = #sfxIndex = (((VARPTR addr(0)) - (VARPTR #sfx(0))) / 2)

ON FRAME GOSUB audioTick

' every frame
audioTick: PROCEDURE
  IF #sfxIndex = 0 THEN RETURN

  IF (FRAME AND 1) THEN RETURN
  
  #ch2 = #sfx(#sfxIndex)
  ch2Vol = #sfx(#sfxIndex + 1)
  ch3 = #sfx(#sfxIndex + 2)
  ch3Vol = #sfx(#sfxIndex + 3)

#if PSG_SN76489
  SOUND 0, #ch2, ch2Vol
  SOUND 3, ch3, ch3Vol
#elif PSG_AY38910
  SOUND 5, #ch2, ch2Vol
  SOUND 9, ch3, ch3Vol
#endif

  IF #ch2 = 0 THEN
    #sfxIndex = 0
  ELSE
    #sfxIndex = #sfxIndex + 4
  END IF

  END