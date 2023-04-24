                lst   off
                org   $2000                 ; start at $2000 (all ProDOS8 system files)
                typ   $ff                   ; set P8 type ($ff = "SYS") for output file
                dsk   hdgr.system

                jsr   HELP
                clc
                xce
                sep   #$30

Main            jsr   DLRON

:picloop
                jsr   HDGRA_Blit
                jsr   HDGR_ShowMode
                jsr   HDGRB_Blit
                jsr   HDGR_ShowMode
                jsr   HDGRC_Blit
                jsr   HDGR_ShowMode
                jsr   HDGRD_Blit
                jsr   HDGR_ShowMode

                * jsr   WaitKey
                * inc   $c034
                bra   :picloop


WaitKey16       sep   $30
                jsr   WaitKey
                rep   $30
                rts
                mx    %11


WaitKey         lda   KEY
                bpl   WaitKey
                sta   STROBE
                rts


HDGR_DataPtr    =     $22
HDGR_DestPtr    =     $26
HDGR_PageOffset =     $2A
HDGR_CurLine    dw    0
HDGR_Mode       db    0                     ; 0 = normal hardware; 1 = glitchy emulators

HDGRA_Blit
                rep   $30
                lda   #HDGRA_P1_MAIN
                jsr   _HGDR_BLIT_P1_MAIN
                lda   #HDGRA_P1_AUX
                jsr   _HGDR_BLIT_P1_AUX
                lda   #HDGRA_P2_MAIN
                jsr   _HGDR_BLIT_P2_MAIN
                lda   #HDGRA_P2_AUX
                jsr   _HGDR_BLIT_P2_AUX
                sep   $30
                rts
HDGRB_Blit
                rep   $30
                lda   #HDGRB_P1_MAIN
                jsr   _HGDR_BLIT_P1_MAIN
                lda   #HDGRB_P1_AUX
                jsr   _HGDR_BLIT_P1_AUX
                lda   #HDGRB_P2_MAIN
                jsr   _HGDR_BLIT_P2_MAIN
                lda   #HDGRB_P2_AUX
                jsr   _HGDR_BLIT_P2_AUX
                sep   $30
                rts

HDGRC_Blit
                rep   $30
                lda   #HDGRC_P1_MAIN
                jsr   _HGDR_BLIT_P1_MAIN
                lda   #HDGRC_P1_AUX
                jsr   _HGDR_BLIT_P1_AUX
                lda   #HDGRC_P2_MAIN
                jsr   _HGDR_BLIT_P2_MAIN
                lda   #HDGRC_P2_AUX
                jsr   _HGDR_BLIT_P2_AUX
                sep   $30
                rts

HDGRD_Blit
                rep   $30
                lda   #HDGRD_P1_MAIN
                jsr   _HGDR_BLIT_P1_MAIN
                lda   #HDGRD_P1_AUX
                jsr   _HGDR_BLIT_P1_AUX
                lda   #HDGRD_P2_MAIN
                jsr   _HGDR_BLIT_P2_MAIN
                lda   #HDGRD_P2_AUX
                jsr   _HGDR_BLIT_P2_AUX
                sep   $30
                rts


_HGDR_BLIT_P1_MAIN mx %00
                stz   HDGR_DataPtr+2        ; data bank
                sta   HDGR_DataPtr          ; data ptr
                stz   HDGR_PageOffset       ; $000
                stz   HDGR_DestPtr+2        ; destbank = 00

                jmp   HDGR_Blit

                * jsr   WaitKey16

_HGDR_BLIT_P1_AUX mx  %00
                stz   HDGR_DataPtr+2        ; data bank
                sta   HDGR_DataPtr          ; data ptr
                stz   HDGR_PageOffset       ; $000
                lda   #$e1
                sta   HDGR_DestPtr+2        ; destbank = e1
                jmp   HDGR_Blit

_HGDR_BLIT_P2_MAIN mx %00
                stz   HDGR_DataPtr+2        ; data bank
                sta   HDGR_DataPtr          ; data ptr
                lda   #$400
                sta   HDGR_PageOffset       ; $400
                lda   #$e0
                sta   HDGR_DestPtr+2        ; destbank = $e0
                jmp   HDGR_Blit

_HGDR_BLIT_P2_AUX
                stz   HDGR_DataPtr+2        ; data bank
                sta   HDGR_DataPtr          ; data ptr
                lda   #$400
                sta   HDGR_PageOffset       ; $400
                lda   #$e1
                sta   HDGR_DestPtr+2        ; destbank = e1
                jmp   HDGR_Blit

HDGR_Blit       mx    %00
                stz   HDGR_CurLine
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
HDGR_ShowMode   lda   HDGR_Mode
                bne   :glitchy
:normal         jsr   HDGR2
                bra   :handle_key
:glitchy        jsr   HDGR
:handle_key     cmp   #"s"
                beq   :switch
                cmp   #"S"
                beq   :switch
                rts
:switch         lda   HDGR_Mode
                bne   :set0
:set1           inc   HDGR_Mode
                bra   HDGR_ShowMode
:set0           stz   HDGR_Mode
                bra   HDGR_ShowMode


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

                lda   KEY
                bpl   :frameloop
                sta   STROBE

                rts                         ; always return the key pressed

                bra   :frameloop


HDGR2
:frameloop      lda   #$7F                  ; Start Line
                sta   _nextLine
                _WAITSCB2
                sta   $c054
                bra   :skip1
:fliploop       _WAITSCB2
                sta   $c054
:skip1          inc   _nextLine
                lda   _nextLine
                _WAITSCB2
                sta   $c055
                inc   _nextLine
                lda   _nextLine
                cmp   #$e0
                bcc   :fliploop

                lda   KEY
                bpl   :frameloop
                sta   STROBE
                rts                         ; always return the key pressed

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


_WAITSCBA       MAC
                sta   __smc+1               ;set scanline
__w             rep   $30
                lda   $C02E
                xba
                sep   $30
                asl                         ;VA is now in the Carry flag
                xba
                rol
__smc           cmp   #0                    ;SMC
                bne   __w
                EOM

_WAITSCB2       MAC
                sta   __smc+1               ;set scanline
__w             lda   $C02E
__smc           cmp   #0                    ;SMC
                bne   __w
                EOM

                * ^showlores          $C056
                * ^showfull           C052
                * ^showgraphics       C050
                * ^showpage1          C054
                * ^ena80  = 0       C07E
                * ^show80 = 0      C00D
                * ^an3on              C05e
DLRON           lda   $C056                 ;
                lda   $C052
                lda   $C050
                LDA   $C054
                sta   $C07E
                sta   $c00D
                lda   $C05e
                rts



**** APPLE ROM LOCATIONS ****
KEY             =     $C000
STROBE          =     $C010
HOME            =     $FC58
CROUT           =     $FD8E
COUT            =     $FDED

*************************************
* LORES / DOUBLE LORES / TEXT LINES *
*************************************
Lo01            =     $400
Lo02            =     $480
Lo03            =     $500
Lo04            =     $580
Lo05            =     $600
Lo06            =     $680
Lo07            =     $700
Lo08            =     $780
Lo09            =     $428
Lo10            =     $4a8
Lo11            =     $528
Lo12            =     $5a8
Lo13            =     $628
Lo14            =     $6a8
Lo15            =     $728
Lo16            =     $7a8
Lo17            =     $450
Lo18            =     $4d0
Lo19            =     $550
Lo20            =     $5d0
* the "plus four" lines
Lo21            =     $650
Lo22            =     $6d0
Lo23            =     $750
Lo24            =     $7d0

LoLineTable     da    Lo01,Lo02,Lo03,Lo04,Lo05,Lo06
                da    Lo07,Lo08,Lo09,Lo10,Lo11,Lo12
                da    Lo13,Lo14,Lo15,Lo16,Lo17,Lo18
                da    Lo19,Lo20,Lo21,Lo22,Lo23,Lo24

HELP            jsr   HOME                  ; clear screen
                LUP   6
                jsr   CROUT
                --^
                ldx   #0
:next           lda   _HelpTxt,x
                beq   :help2
                jsr   COUT
                inx
                bra   :next
:help2          jsr   CROUT
                jsr   CROUT
                ldx   #0
:next2          lda   _HelpTxt2,x
                beq   :done
                jsr   COUT
                inx
                bra   :next2
:done           jsr   WaitKey
                rts
_HelpTxt        asc   "   PRESS 'S' IF THE IMAGE IS GARBLED.",00
_HelpTxt2       asc   "      HIT ANY KEY TO CONTINUE...",00
                put   testimages.s

