  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring

True = $01
False = $00

;;;;;;;;;;;;;;;
  include "ppu.inc"
  include "charmap.inc"

 .rsset $0000  ;;start variables at ram location 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Entity Header Section - Include All Entity Header files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                        ;
  include "Player/PlayerHeader.inc"
  include "Score/ScoreHeader.inc"
  include "Bullet/BulletHeader.inc"
;                                                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
POS_X_HIGH    .rs 1  ; ball horizontal position
POS_X_LOW     .rs 1  ; ball horizontal position
POS_Y_HIGH    .rs 1  ; ball horizontal position
POS_Y_LOW     .rs 1  ; ball horizontal position
SCREEN_OFFSET_HIGH .rs 1  ; offset into nametable
SCREEN_OFFSET_LOW .rs 1  ; offset into nametable
CHAR_1        .rs 1
CHAR_2        .rs 1
CHAR_3        .rs 1
CHAR_4        .rs 1
CHAR_5        .rs 1
CHAR_6        .rs 1
CHAR_7        .rs 1
CHAR_8        .rs 1
CHAR_9        .rs 1
CHAR_10       .rs 1
CHAR_11       .rs 1
CHAR_12       .rs 1
CHAR_13       .rs 1
TIMER_1       .rs 1
BUTTONS_PRESSED .rs 1
BUTTONS_RELEASED .rs 1
drawDone   .rs 1
CAN_INCREMENT .rs 1

THIS = $FB


  .bank 0
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX PPU_CONTROL_REG    ; disable NMI
  STX PPU_MASK_REG    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT PPU_STATUS_REG
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x
  STA $0300, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT PPU_STATUS_REG
  BPL vblankwait2


LoadPalettes:
  LDA PPU_STATUS_REG             ; read PPU status to reset the high/low latch
  LDA #HIGH(BG_COLOR)
  STA PPU_ADDRESS_REG             ; write the high byte of $3F00 address
  LDA #LOW(BG_COLOR)
  STA PPU_ADDRESS_REG             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  STA PPU_DATA_REG             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down
; Initialize variables
  LDA #02
  STA POS_X_LOW
  LDA #02
  STA POS_Y_LOW
  LDA #$00
  STA POS_X_HIGH
  STA POS_Y_HIGH
  STA SCREEN_OFFSET_LOW
  STA SCREEN_OFFSET_HIGH
  STA TIMER_1
  LDA #$01
  STA drawDone
  LDA #True
  STA CAN_INCREMENT

  LDX #$00
  LDA hello_world, x
  STA CHAR_1
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x
  INX
  LDA hello_world, x
  STA CHAR_1, x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init Code Section - Call Entity Init Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                        ;
  JSR InitPlayer
  JSR InitScore
  JSR InitBullet
;                                                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadSprites:
  LDX #$00              ; start at 0
LoadSpritesLoop:
  LDA PlayerSpriteData, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$1C              ; Compare X to hex $10, decimal 16
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going down
              
  JSR PrintString
  JSR PrintScoreString

LoadAttribute:
  LDA PPU_STATUS_REG             ; read PPU status to reset the high/low latch
  LDA #HIGH(ATTRIBUTE_TABLE_A)
  STA PPU_ADDRESS_REG             ; write the high byte of $23C0 address
  LDA #LOW(ATTRIBUTE_TABLE_A)
  STA PPU_ADDRESS_REG             ; write the low byte of $23C0 address
  LDX #$00              ; start out at 0
LoadAttributeLoop:
  LDA attribute, x      ; load data from address (attribute + the value in x)
  STA PPU_DATA_REG             ; write to PPU
  INX                   ; X = X + 1
  CPX #$08              ; Compare X to hex $08, decimal 8 - copying 8 bytes
  BNE LoadAttributeLoop  ; Branch to LoadAttributeLoop if compare was Not Equal to zero
                        ; if compare was equal to 128, keep going down

  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA PPU_CONTROL_REG

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA PPU_MASK_REG

GameLoop:
  JSR WaitDrawCompleted
  JSR Read_Buttons_Pressed
  JSR ReadA
;  JSR ReadB
;  JSR ReadSelect
;  JSR ReadStart
  JSR ReadUp
  JSR ReadDown
  JSR ReadLeft
  JSR ReadRight
  JMP GameLoop     ;jump back to Forever, infinite loop
  
 

NMI:
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  STA OAM_ADDRESS       ; set the low byte (00) of the RAM address
  LDA #$02
  STA OAM_DMA_REG       ; set the high byte (02) of the RAM address, start the transfer

  JSR TimerRotate

  ;;This is the PPU clean up section, so rendering the next frame starts properly.
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA PPU_CONTROL_REG
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA PPU_MASK_REG
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA PPU_SCROLL_REG
  STA PPU_SCROLL_REG
  LDA #$01
  STA drawDone
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTI             ; return from interrupt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WaitDrawCompleted:
WaitDrawCompletedLoop:
  LDA drawDone
  CMP #$01
  BNE WaitDrawCompletedLoop
  LDA #$00
  STA drawDone
  RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReadA:
  LDA BUTTONS_PRESSED       ; player 1 - A
  AND #%10000000
  BEQ TurnOnIncrement       ; if (!a_button pressed) then skip
  LDA CAN_INCREMENT
  BEQ ReadADone       ; if (CAN_INCREMENT == False) then skip
  LDA #False                ;   else if True, then set to False
  STA CAN_INCREMENT         ;     this allows only increment per button hit
  JSR IncrementCounter
  JSR CreateBullet
  JMP ReadADone
TurnOnIncrement:
  LDA #$01
  STA CAN_INCREMENT
ReadADone:
  NOP
  NOP
  NOP
  RTS

ReadUp: 
  LDA BUTTONS_PRESSED       ; player 1 - B
  AND #%00001000  ; only look at bit 0
  BEQ ReadUpDone   ; branch to ReadBDone if button is NOT pressed (0)
  JSR MovePlayerUp
  LDA POS_Y_LOW
  SEC
  SBC #$01
  CMP #$00
  BEQ ReadUpDone
  STA POS_Y_LOW
ReadUpDone:        ; handling this button is done
  RTS

ReadDown: 
  LDA BUTTONS_PRESSED       ; player 1 - A
  AND #%00000100  ; only look at bit 0
  BEQ ReadDownDone   ; branch to ReadADone if button is NOT pressed (0)
  JSR MovePlayerDown
  LDA POS_Y_LOW
  CLC
  ADC #$01
  CMP #$1D
  BEQ ReadDownDone
  STA POS_Y_LOW
ReadDownDone:        ; handling this button is done
  RTS

ReadLeft: 
  LDA BUTTONS_PRESSED       ; player 1 - B
  AND #%00000010  ; only look at bit 0
  BEQ ReadLeftDone   ; branch to ReadBDone if button is NOT pressed (0)
  JSR MovePlayerLeft
  LDA POS_X_LOW
  SEC
  SBC #$01
  CMP #$FF
  BEQ ReadLeftDone
  STA POS_X_LOW
ReadLeftDone:        ; handling this button is done
  RTS

ReadRight: 
  LDA BUTTONS_PRESSED       ; player 1 - A
  AND #%00000001  ; only look at bit 0
  BEQ ReadRightDone   ; branch to ReadADone if button is NOT pressed (0)
  JSR MovePlayerRight
  LDA POS_X_LOW
  CLC
  ADC #$01
  CMP #$0A
  BEQ ReadRightDone
  STA POS_X_LOW
ReadRightDone:        ; handling this button is done
  RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Read_Buttons_Pressed:
  LDA #$01                   ; Latch both controllers
  STA Controller_1_Reg
  LDA #$00
  STA Controller_1_Reg       ; tell both the controllers to latch buttons
Check_A:
  LDA Controller_1_Reg       ; read 1 - A
  AND #%00000001
  BEQ A_Not_Pressed
  LDA BUTTONS_PRESSED
  ORA #%10000000
  STA BUTTONS_PRESSED
  JMP Check_B
A_Not_Pressed:
  LDA BUTTONS_PRESSED
  AND #%01111111
  STA BUTTONS_PRESSED
Check_B:
  LDA Controller_1_Reg       ; read 1 - B
  AND #%00000001
  BEQ B_Not_Pressed
  LDA BUTTONS_PRESSED
  ORA #%01000000
  STA BUTTONS_PRESSED
  JMP Check_Select
B_Not_Pressed:
  LDA BUTTONS_PRESSED
  AND #%10111111
  STA BUTTONS_PRESSED
Check_Select:
  LDA Controller_1_Reg       ; read 1 - SELECT
  AND #%00000001
  BEQ Select_Not_Pressed
  LDA BUTTONS_PRESSED
  ORA #%00100000
  STA BUTTONS_PRESSED
  JMP Check_Start
Select_Not_Pressed:
  LDA BUTTONS_PRESSED
  AND #%11011111
  STA BUTTONS_PRESSED
Check_Start:
  LDA Controller_1_Reg       ; read 1 - START
  AND #%00000001
  BEQ Start_Not_Pressed
  LDA BUTTONS_PRESSED
  ORA #%00010000
  STA BUTTONS_PRESSED
  JMP Check_Up
Start_Not_Pressed:
  LDA BUTTONS_PRESSED
  AND #%11101111
  STA BUTTONS_PRESSED
Check_Up:
  LDA Controller_1_Reg       ; read 1 - UP
  AND #%00000001
  BEQ Up_Not_Pressed
  LDA BUTTONS_PRESSED
  ORA #%00001000
  STA BUTTONS_PRESSED
  JMP Check_Down
Up_Not_Pressed:
  LDA BUTTONS_PRESSED
  AND #%11110111
  STA BUTTONS_PRESSED
Check_Down:
  LDA Controller_1_Reg       ; read 1 - DOWN
  AND #%00000001
  BEQ Down_Not_Pressed
  LDA BUTTONS_PRESSED
  ORA #%00000100
  STA BUTTONS_PRESSED
  JMP Check_Left
Down_Not_Pressed:
  LDA BUTTONS_PRESSED
  AND #%11111011
  STA BUTTONS_PRESSED
Check_Left:
  LDA Controller_1_Reg       ; read 1 - LEFT
  AND #%00000001
  BEQ Left_Not_Pressed
  LDA BUTTONS_PRESSED
  ORA #%00000010
  STA BUTTONS_PRESSED
  JMP Check_Right
Left_Not_Pressed:
  LDA BUTTONS_PRESSED
  AND #%11111101
  STA BUTTONS_PRESSED
Check_Right:
  LDA Controller_1_Reg       ; read 1 - RIGHT
  AND #%00000001
  BEQ Right_Not_Pressed
  LDA BUTTONS_PRESSED
  ORA #%00000001
  STA BUTTONS_PRESSED
  JMP Check_Done
Right_Not_Pressed:
  LDA BUTTONS_PRESSED
  AND #%11111110
  STA BUTTONS_PRESSED
Check_Done:
  RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to calculate index into nametable from x, y input
;;   - INPUT: POS_X, POS_Y
;;   - OUTPUT: SCREEN_OFFSET
;;   returns 32 * POS_Y + POS_X + $2000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Calc_Screen_Pos:
  ; multiply y by 32 (or 2^5)
  LDA POS_Y_LOW
  STA SCREEN_OFFSET_LOW
  LDA POS_Y_HIGH
  STA SCREEN_OFFSET_HIGH
  ASL SCREEN_OFFSET_LOW
  ROL SCREEN_OFFSET_HIGH
  ASL SCREEN_OFFSET_LOW
  ROL SCREEN_OFFSET_HIGH
  ASL SCREEN_OFFSET_LOW
  ROL SCREEN_OFFSET_HIGH
  ASL SCREEN_OFFSET_LOW
  ROL SCREEN_OFFSET_HIGH
  ASL SCREEN_OFFSET_LOW
  ROL SCREEN_OFFSET_HIGH
  

  ; add $2000 to above result
  CLC
  LDA SCREEN_OFFSET_HIGH
  ADC #$20
  STA SCREEN_OFFSET_HIGH

  ; add x to above result
  CLC
  LDA SCREEN_OFFSET_LOW
  ADC POS_X_LOW
  STA SCREEN_OFFSET_LOW
  LDA SCREEN_OFFSET_HIGH
  ADC POS_X_HIGH
  STA SCREEN_OFFSET_HIGH

  RTS
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to print a string at location x,y
;;   - INPUT: POS_X, POS_Y
;;   - OUTPUT: SCREEN_OFFSET
;;   returns 32 * POS_Y + POS_X + $2000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintString
  JSR ClearText
  JSR Calc_Screen_Pos
  LDA PPU_STATUS_REG             ; read PPU status to reset the high/low latch
  LDA SCREEN_OFFSET_HIGH
  STA PPU_ADDRESS_REG             ; write the high byte of $2000 address
  LDA SCREEN_OFFSET_LOW
  STA PPU_ADDRESS_REG             ; write the low byte of $2000 address
  LDX #$00              ; start out at 0
PrintStringLoop:
  LDA CHAR_1, x     ; load data from address (background + the value in x)
  BEQ PrintStringDone
  STA PPU_DATA_REG             ; write to PPU
  LDA #$00
  STA PPU_DATA_REG
  INX                   ; X = X + 1
  JMP PrintStringLoop
PrintStringDone:
  RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearText:
  LDA PPU_STATUS_REG
  LDA SCREEN_OFFSET_HIGH
  STA PPU_ADDRESS_REG
  LDA SCREEN_OFFSET_LOW
  STA PPU_ADDRESS_REG
  LDX #$00
ClearTextLoop:
  LDA hello_world, x     ; load data from address (background + the value in x)
  BEQ ClearTextDone
  LDA #$00
  STA PPU_DATA_REG             ; write to PPU
  STA PPU_DATA_REG             ; write to PPU
  INX                   ; X = X + 1
  JMP ClearTextLoop
ClearTextDone:
  RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RotateRight:
  LDA CHAR_12
  TAX
  LDA CHAR_11
  STA CHAR_12
  LDA CHAR_10
  STA CHAR_11
  LDA CHAR_9
  STA CHAR_10
  LDA CHAR_8
  STA CHAR_9
  LDA CHAR_7
  STA CHAR_8
  LDA CHAR_6
  STA CHAR_7
  LDA CHAR_5
  STA CHAR_6
  LDA CHAR_4
  STA CHAR_5
  LDA CHAR_3
  STA CHAR_4
  LDA CHAR_2
  STA CHAR_3
  LDA CHAR_1
  STA CHAR_2
  TXA
  STA CHAR_1
  RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TimerRotate:
  CLC
  LDA TIMER_1
  ADC #$10
  STA TIMER_1
  BNE SkipRotate
  JSR RotateRight
  JSR PrintString
SkipRotate:
  RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FindFirstSpriteSlot:
  LDX #$00
FindFirstSpriteSlotLoop:
  LDA $0200, x
  CMP #$FE
  BEQ SpriteIndexFound
  INX
  INX
  INX
  INX
  JMP FindFirstSpriteSlotLoop
SpriteIndexFound:
  RTS

FindFirstObjectSlot:
  LDX #$00
FindFirstObjectSlotLoop:
  LDA $0300, x
  CMP #$FE
  BEQ ObjectIndexFound
  INX
  JMP FindFirstObjectSlotLoop
ObjectIndexFound:
  RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Entity Code Section - Include All Entity Code Files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                        ;
  include "Player/PlayerCode.asm"
  include "Score/ScoreCode.asm"
  include "Bullet/BulletCode.asm"
;                                                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .bank 1
  .org $E000
palette:
  .db $0F,$29,$1A,$20,  $0F,$36,$17,$20,  $0F,$30,$21,$20,  $0F,$27,$17,$20   ;;background palette
  .db $0F,$1C,$15,$20,  $0F,$02,$38,$20,  $0F,$1C,$15,$20,  $0F,$02,$38,$20   ;;sprite palette

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite Data Section - Include All Sprites init data files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                        ;
  include "Player/PlayerSpriteData.asm"
  include "Score/ScoreSpriteData.asm"
;                                                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite Strings Section - Include All Sprites String Constants files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                        ;
  include "Score/ScoreStrings.asm"
;                                                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

hello_world:
  .db H, e, l, l, o, SPACE, W, o, r, l, d, EXCLAMATION, 0

background:
  .db $25,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .db $24,$24,$24,$24,$24,$32,$33,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 2
  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky

  .db $24,$24,$24,$24,$45,$34,$35,$24,$45,$45,$45,$45,$45,$45,$24,$24  ;;row 3
  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;;some brick tops

  .db $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24  ;;row 4
  .db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;;brick bottoms

attribute:
  .db %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000

  .db $24,$24,$24,$24, $47,$47,$24,$24 ,$47,$47,$47,$47, $47,$47,$24,$24 ,$24,$24,$24,$24 ,$24,$24,$24,$24, $24,$24,$24,$24, $55,$56,$24,$24  ;;brick bottoms



  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
  
;;;;;;;;;;;;;;  
  
  
  .bank 2
  .org $0000
  .incbin "mario2.chr"   ;includes 8KB graphics file from SMB1
  .org $1000
  .incbin "bg.chr"