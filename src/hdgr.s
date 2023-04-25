**************************
*     __ _____  ________  ************************
*    / // / _ \/ ___/ _ \  * HDGR by Digarok      *
*   / _  / // / (_ / , _/  *  a new graphics mode  *
*  /_//_/____/\___/_/|_|   *   for Apple II ;)     *
*                         *    80x96 at 16-colors *
**************************************************
   
                org   $2000                 ; start at $2000 (all ProDOS8 system files)
                typ   $ff                   ; set P8 type ($ff = "SYS") for output file
                dsk   hdgr.system

                jsr   HELP                  ; Show intro message
                clc
                xce                         ; 65816-land (native modep)
                sep   #$30

Main            jsr   DLRON                 ; Turn on "regular" DGR (aka DLR, aka Double Lo-Res) 80x48

:picloop
                jsr   HDGRA_Blit            ; copy pic A
                jsr   HDGR_ShowMode         ; show pic A
                jsr   HDGRB_Blit            ; copy pic B
                jsr   HDGR_ShowMode         ; show pic B
                jsr   HDGRC_Blit            ; etc...
                jsr   HDGR_ShowMode
                jsr   HDGRD_Blit
                jsr   HDGR_ShowMode
                jsr   HDGRE_Blit
                jsr   HDGR_ShowMode

                bra   :picloop              ; There is no escape! ;)


WaitKey16       sep   $30
                jsr   WaitKey
                rep   $30
                rts
                mx    %11


WaitKey         lda   KEY
                bpl   WaitKey
                sta   STROBE
                rts


** These could just be a macro, or a function pointing to a table of parameters if many images
** ... but for the PoC I'm leaving it as a simple set of functions for each image
HDGRA_Blit      rep   $30
                lda   #HDGRA_P1_MAIN
                jsr   HGDR_BLIT_P1_MAIN
                lda   #HDGRA_P1_AUX
                jsr   HGDR_BLIT_P1_AUX
                lda   #HDGRA_P2_MAIN
                jsr   HGDR_BLIT_P2_MAIN
                lda   #HDGRA_P2_AUX
                jsr   HGDR_BLIT_P2_AUX
                sep   $30
                rts

HDGRB_Blit      rep   $30
                lda   #HDGRB_P1_MAIN
                jsr   HGDR_BLIT_P1_MAIN
                lda   #HDGRB_P1_AUX
                jsr   HGDR_BLIT_P1_AUX
                lda   #HDGRB_P2_MAIN
                jsr   HGDR_BLIT_P2_MAIN
                lda   #HDGRB_P2_AUX
                jsr   HGDR_BLIT_P2_AUX
                sep   $30
                rts

HDGRC_Blit      rep   $30
                lda   #HDGRC_P1_MAIN
                jsr   HGDR_BLIT_P1_MAIN
                lda   #HDGRC_P1_AUX
                jsr   HGDR_BLIT_P1_AUX
                lda   #HDGRC_P2_MAIN
                jsr   HGDR_BLIT_P2_MAIN
                lda   #HDGRC_P2_AUX
                jsr   HGDR_BLIT_P2_AUX
                sep   $30
                rts

HDGRD_Blit      rep   $30
                lda   #HDGRD_P1_MAIN
                jsr   HGDR_BLIT_P1_MAIN
                lda   #HDGRD_P1_AUX
                jsr   HGDR_BLIT_P1_AUX
                lda   #HDGRD_P2_MAIN
                jsr   HGDR_BLIT_P2_MAIN
                lda   #HDGRD_P2_AUX
                jsr   HGDR_BLIT_P2_AUX
                sep   $30
                rts

HDGRE_Blit      rep   $30
                lda   #HDGRE_P1_MAIN
                jsr   HGDR_BLIT_P1_MAIN
                lda   #HDGRE_P1_AUX
                jsr   HGDR_BLIT_P1_AUX
                lda   #HDGRE_P2_MAIN
                jsr   HGDR_BLIT_P2_MAIN
                lda   #HDGRE_P2_AUX
                jsr   HGDR_BLIT_P2_AUX
                sep   $30
                rts


** 4 different blit functions depending on which page/bank we're writing to
** Could replace with traditional aux/main writing functions for 8-bit Apple II
HGDR_BLIT_P1_MAIN mx  %00
                stz   HDGR_DataPtr+2        ; data bank
                sta   HDGR_DataPtr          ; data ptr
                stz   HDGR_PageOffset       ; $000
                stz   HDGR_DestPtr+2        ; destbank = 00
                jmp   HDGR_Blit

HGDR_BLIT_P1_AUX mx   %00
                stz   HDGR_DataPtr+2        ; data bank
                sta   HDGR_DataPtr          ; data ptr
                stz   HDGR_PageOffset       ; $000
                lda   #$e1
                sta   HDGR_DestPtr+2        ; destbank = e1
                jmp   HDGR_Blit

HGDR_BLIT_P2_MAIN mx  %00
                stz   HDGR_DataPtr+2        ; data bank
                sta   HDGR_DataPtr          ; data ptr
                lda   #$400
                sta   HDGR_PageOffset       ; $400
                lda   #$e0
                sta   HDGR_DestPtr+2        ; destbank = $e0
                jmp   HDGR_Blit

HGDR_BLIT_P2_AUX mx   %00
                stz   HDGR_DataPtr+2        ; data bank
                sta   HDGR_DataPtr          ; data ptr
                lda   #$400
                sta   HDGR_PageOffset       ; $400
                lda   #$e1
                sta   HDGR_DestPtr+2        ; destbank = e1
                jmp   HDGR_Blit

** Actual Blit routine - IIgs DP long indirect addressing
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
:done           rts

** Dispatch to reguler or glitchy display mode, toggle with "S"
HDGR_ShowMode   mx    %11
                lda   HDGR_Mode
                bne   :glitchy
:normal         jsr   HDGR2
                bra   :handle_key
:glitchy        jsr   HDGR
:handle_key     cmp   #"s"
                beq   :switch
                cmp   #"S"
                beq   :switch
                                            ; <<- Handle any other keys here ...
                rts
:switch         lda   HDGR_Mode
                bne   :set0
:set1           inc   HDGR_Mode
                bra   HDGR_ShowMode
:set0           stz   HDGR_Mode
                bra   HDGR_ShowMode

** This uses a scanline perfect check
HDGR
:frameloop      sei
                lda   #1
                sta   HDGR_NextLine
                _WAITSCBA
                sta   $c054
                bra   :skip1
:fliploop       _WAITSCBA
                sta   $c054
:skip1          inc   HDGR_NextLine
                inc   HDGR_NextLine
                lda   HDGR_NextLine
                _WAITSCBA
                sta   $c055
                inc   HDGR_NextLine
                inc   HDGR_NextLine
                lda   HDGR_NextLine
                cmp   #192
                bcc   :fliploop
                cli
                lda   KEY
                bpl   :frameloop
                sta   STROBE
                rts                         ; always return the key pressed

** This only checks every other scanline, is easier and faster, but
** for reasons unrelated, I can't use it with some emulators.
HDGR2
:frameloop      sei
                lda   #$7F                  ; Start Line
                sta   HDGR_NextLine
                _WAITSCB2
                sta   $c054
                bra   :skip1
:fliploop       _WAITSCB2
                sta   $c054
:skip1          inc   HDGR_NextLine
                lda   HDGR_NextLine
                _WAITSCB2
                sta   $c055
                inc   HDGR_NextLine
                lda   HDGR_NextLine
                cmp   #$e0
                bcc   :fliploop
                cli
                lda   KEY
                bpl   :frameloop
                sta   STROBE
                rts                         ; always return the key pressed
                bra   :frameloop


HDGR_NextLine   =     $20
HDGR_DataPtr    =     $22
HDGR_DestPtr    =     $26
HDGR_PageOffset =     $2A
HDGR_CurLine    =     $2C
HDGR_Mode       db    0                     ; 0 = normal hardware; 1 = glitchy emulators

** wait for scanline in A
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

** wait for scanline/2 in A
_WAITSCB2       MAC
                sta   __smc+1               ;set scanline
__w             lda   $C02E
__smc           cmp   #0                    ;SMC
                bne   __w
                EOM


DLRON           lda   LORES                 ;$C056 - Show Low-Resolution
                lda   CLRMIX                ;$C052 - Clear Mixed Mode (No 4 lines of text at the bottom)
                lda   TXTCLR                ;$C050 - Switch in Graphics (Not Text)
                lda   TXTPAGE1              ;$C054 - Switch in Text Page 1 as default
                sta   SETIOUDIS             ;$C07E - Enable DHIRES & disable $C058-5F (W)
                sta   SET80VID              ;$C00D - Enable 80-column firmware
                lda   CLRAN3                ;$C053 - Clear Annunciator 3 - (In 80-Column Mode: Double Width Graphics)
                rts


**** APPLE ROM LOCATIONS ****
KEY             =     $C000
STROBE          =     $C010
HOME            =     $FC58
CROUT           =     $FD8E
COUT            =     $FDED
***** DLR RELATED STUFF *****
LORES = $C056
CLRMIX = $C052
TXTCLR = $C050
TXTPAGE1 = $C054
TXTPAGE2 = $C055
SETIOUDIS = $C07E 
SET80VID = $C00D 
CLRAN3 = $C05E

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


** Message for users at the beginning... works on my machine! *shrug*
HELP            jsr   HOME                  ; clear screen
                LUP   8
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

