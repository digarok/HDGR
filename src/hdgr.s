                lst   off
                org   $2000                 ; start at $2000 (all ProDOS8 system files)
                typ   $ff                   ; set P8 type ($ff = "SYS") for output file
                dsk   hdgr.system
                put   ../../applerom/applerom.s
                clc
                xce
                sep   #$30

Main
                jsr   DLRON
                * jsr DL_SetDLRMode
                lda   #$38
                jsr   DL_Clear
                lda   #$A6
                sta   $401
                sta   $455
:looopo         jsr   HDGRA_Blit
                jsr   HDGR

                jsr   WaitKey
                * sta CLR80COL

                sta   $c055
                * sta SET80COL
                inc   $c034
                jsr   WaitKey
                * sta CLR80COL

                sta   $c054
                * sta SET80COL

                inc   $c034
                bra   :looopo


WaitKey16       sep   $30
                jsr   WaitKey
                rep   $30
                rts
                mx    %11


WaitKey         lda   KEY
                bpl   WaitKey
                sta   STROBE
                rts


                * ^showlores          $C056
                * ^showfull           C052
                * ^showgraphics       C050
                * ^showpage1          C054
                * ^ena80  = 0       C07E
                * ^show80 = 0      C00D
                * ^an3on              C05e
LoLineTable     da    Lo01,Lo02,Lo03,Lo04,Lo05,Lo06
                da    Lo07,Lo08,Lo09,Lo10,Lo11,Lo12
                da    Lo13,Lo14,Lo15,Lo16,Lo17,Lo18
                da    Lo19,Lo20,Lo21,Lo22,Lo23,Lo24
HDGR_DataPtr    =     $22
HDGR_DestPtr    =     $26
HDGR_PageOffset =     $2A
HDGR_CurLine    dw    0
HDGRA_Blit      sta   $c054
                rep   $30
*
                jsr   WaitKey16

                stz   HDGR_PageOffset
                stz   HDGR_CurLine
                stz   HDGR_DestPtr+2        ; destbank
                stz   HDGR_DataPtr+2        ; bank
                lda   #HDGRA_P1_MAIN
                sta   HDGR_DataPtr          ; 22
                jsr   HDGR_Blit

                jsr   WaitKey16


                stz   HDGR_PageOffset
                stz   HDGR_CurLine
                lda   #$e1
                sta   HDGR_DestPtr+2        ; destbank
                stz   HDGR_DataPtr+2        ; bank
                lda   #HDGRA_P1_AUX
                sta   HDGR_DataPtr          ; 22
                jsr   HDGR_Blit

                jsr   WaitKey16
                sep   $30
                sta   $c055
                rep   #$30
                ldx   #0
                lda   #$0000
:clr            stal  $e10800,x
                inx
                inx
                cpx   #$400

                bne   :clr

                lda   #$400
                sta   HDGR_PageOffset
                stz   HDGR_CurLine
                 lda   #$e0
                sta   HDGR_DestPtr+2        ; destbank
                stz   HDGR_DataPtr+2        ; bank
                lda   #HDGRA_P2_MAIN
                sta   HDGR_DataPtr          ; 22
                jsr   HDGR_Blit

                jsr   WaitKey16

                lda   #$400
                sta   HDGR_PageOffset
                stz   HDGR_CurLine
                lda   #$e1
                sta   HDGR_DestPtr+2        ; destbank
                stz   HDGR_DataPtr+2        ; bank
                lda   #HDGRA_P2_AUX
                sta   HDGR_DataPtr          ; 22
                jsr   HDGR_Blit

                jsr   WaitKey16


                sep   $30
                rts

HDGR_Blit       mx    %00
:line
                lda   HDGR_CurLine
                asl
                tax
                lda   LoLineTable,x
                clc
                adc   HDGR_PageOffset
                sta   HDGR_DestPtr
                ldy   #0
:copy           lda   [HDGR_DataPtr],y
                sta   [HDGR_DestPtr],y
                iny
                iny
                cpy   #40
                bne   :copy
                inc   HDGR_CurLine
                lda   HDGR_CurLine
                cmp   #24
                beq   :done
                lda   HDGR_DataPtr
                clc
                adc   #40
                sta   HDGR_DataPtr
                bra   :line

:done
                rts
                mx    %11

_nextLine       =     $20
HDGR
:frameloop      lda   #1
                sta   _nextLine
                _WAITSCBA
                sta   $c054
                bra   :skip1
:fliploop       _WAITSCBA
                sta   $c054
:skip1          inc   _nextLine
                inc   _nextLine
                lda   _nextLine
                _WAITSCBA
                sta   $c055
                inc   _nextLine
                inc   _nextLine
                lda   _nextLine
                cmp   #192
                bcc   :fliploop


                * jsr WaitVBLStart
                bra   :frameloop





* NTSC 9bit vertcnt range $FA through $1FF (250 through 511)
WaitSCB         _WAITSCB
                rts
_WAITSCB        MAC
                sta   __smc+1
__w             lda   $C02F
                asl   A                     ;VA is now in the Carry flag
                lda   $C02E
                rol   A
__smc           cmp   #0                    ;SMC
                bcc   __w
                EOM


WaitSCBIs       _WAITSCBIS
                rts
_WAITSCBIS      MAC
                sta   __smc+1
__w             lda   >$C02F
                asl   A                     ;VA is now in the Carry flag
                lda   $C02E
                rol   A
__smc           cmp   #0                    ;SMC
                bne   __w
                EOM

_WAITSCBA       MAC
                sta   __smc+1
__w             rep   $30
                lda   $C02E
                xba
                sep   $30
                asl   A                     ;VA is now in the Carry flag
                xba
                rol   A
__smc           cmp   #0                    ;SMC
                bne   __w
                EOM



WaitVBLStart    lda   $c019
                bpl   WaitVBLStart
                rts
WaitVBLEnd      lda   $c019
                bmi   WaitVBLEnd
                rts

WaitSCB1        sta   :scbval+1
                rep   #$30


:wait           ldal  $E0C02E               ; get full word in one update
                sep   $10
                tay
                asl
                tya
                rol
                and   #$00FF
:scbval         cmp   #$0000
                bne   :wait
                sep   $30
                rts
                mx    %11
WaitEvenSCB                                 ;mx    %10
:wait           cmp   >$E0C02E
                bcc   :wait
                rts

WaitEvenSCB2                                ;mx    %10
                phd
                pea   #$C000
                pld
:wait           cmp   $2E
                bne   :wait
                pld
                rts

DLRON           lda   $C056
                lda   $C052
                lda   $C050
                LDA   $C054
                sta   $C07E
                sta   $c00D
                lda   $C05e
                rts

DL_SetDLRMode   lda   LORES                 ;set lores
                lda   SETAN3                ;enables DLR
                sta   SET80VID

                sta   C80STOREON            ; enable aux/page1,2 mapping
                sta   MIXCLR                ;make sure graphics-only mode
                rts

DL_SetDLRMixMode lda  LORES                 ;set lores
                lda   SETAN3                ;enables DLR
                sta   SET80VID

                sta   C80STOREON            ; enable aux/page1,2 mapping
                sta   MIXSET                ;turn on mixed text/graphics mode
                rts

DL_MixClearText sta   TXTPAGE1
                ldx   #40
:loop           dex
                sta   Lo24,x
                sta   Lo23,x
                sta   Lo22,x
                sta   Lo21,x
                bne   :loop
                sta   TXTPAGE2
                ldx   #40
:loop2          dex
                sta   Lo24,x
                sta   Lo23,x
                sta   Lo22,x
                sta   Lo21,x
                bne   :loop2
                rts


** A = lo-res color byte
DL_Clear        sta   TXTPAGE1
                ldx   #40
:loop           dex
                sta   Lo01,x
                sta   Lo02,x
                sta   Lo03,x
                sta   Lo04,x
                sta   Lo05,x
                sta   Lo06,x
                sta   Lo07,x
                sta   Lo08,x
                sta   Lo09,x
                sta   Lo10,x
                sta   Lo11,x
                sta   Lo12,x
                sta   Lo13,x
                sta   Lo14,x
                sta   Lo15,x
                sta   Lo16,x
                sta   Lo17,x
                sta   Lo18,x
                sta   Lo19,x
                sta   Lo20,x
                sta   Lo21,x
                sta   Lo22,x
                sta   Lo23,x
                sta   Lo24,x
                bne   :loop
                tax                         ; get aux color value
                lda   MainAuxMap,x
                sta   TXTPAGE2              ; turn on p2
                ldx   #40
:loop2          dex
                sta   Lo01,x
                sta   Lo02,x
                sta   Lo03,x
                sta   Lo04,x
                sta   Lo05,x
                sta   Lo06,x
                sta   Lo07,x
                sta   Lo08,x
                sta   Lo09,x
                sta   Lo10,x
                sta   Lo11,x
                sta   Lo12,x
                sta   Lo13,x
                sta   Lo14,x
                sta   Lo15,x
                sta   Lo16,x
                sta   Lo17,x
                sta   Lo18,x
                sta   Lo19,x
                sta   Lo20,x
                sta   Lo21,x
                sta   Lo22,x
                sta   Lo23,x
                sta   Lo24,x
                bne   :loop2
                rts



MainAuxMap
                hex   00,08,01,09,02,0A,03,0B,04,0C,05,0D,06,0E,07,0F
                hex   80,88,81,89,82,8A,83,8B,84,8C,85,8D,86,8E,87,8F
                hex   10,18,11,19,12,1A,13,1B,14,1C,15,1D,16,1E,17,1F
                hex   90,98,91,99,92,9A,93,9B,94,9C,95,9D,96,9E,97,9F
                hex   20,28,21,29,22,2A,23,2B,24,2C,25,2D,26,2E,27,2F
                hex   A0,A8,A1,A9,A2,AA,A3,AB,A4,AC,A5,AD,A6,AE,A7,AF
                hex   30,38,31,39,32,3A,33,3B,34,3C,35,3D,36,3E,37,3F
                hex   B0,B8,B1,B9,B2,BA,B3,BB,B4,BC,B5,BD,B6,BE,B7,BF
                hex   40,48,41,49,42,4A,43,4B,44,4C,45,4D,46,4E,47,4F
                hex   C0,C8,C1,C9,C2,CA,C3,CB,C4,CC,C5,CD,C6,CE,C7,CF
                hex   50,58,51,59,52,5A,53,5B,54,5C,55,5D,56,5E,57,5F
                hex   D0,D8,D1,D9,D2,DA,D3,DB,D4,DC,D5,DD,D6,DE,D7,DF
                hex   60,68,61,69,62,6A,63,6B,64,6C,65,6D,66,6E,67,6F
                hex   E0,E8,E1,E9,E2,EA,E3,EB,E4,EC,E5,ED,E6,EE,E7,EF
                hex   70,78,71,79,72,7A,73,7B,74,7C,75,7D,76,7E,77,7F
                hex   F0,F8,F1,F9,F2,FA,F3,FB,F4,FC,F5,FD,F6,FE,F7,FF

                put   testimages.s
