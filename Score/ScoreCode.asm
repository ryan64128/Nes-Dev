InitScore:
  LDA #$00
  STA ONES_DIGIT
  STA TENS_DIGIT
  STA HUNDREDS_DIGIT
  RTS

IncrementCounter:
  CLC
  LDA ONES_DIGIT
  ADC #$01
  STA ONES_DIGIT
  CMP #$0A
  BNE IncDone
IncTens:
  LDA #$00
  STA ONES_DIGIT
  LDA TENS_DIGIT
  CLC
  ADC #$01
  STA TENS_DIGIT
  CMP #$0A
  BNE IncDone
IncHundreds:
  LDA #$00
  STA TENS_DIGIT
  LDA HUNDREDS_DIGIT
  CLC
  ADC #$01
  STA HUNDREDS_DIGIT
  CMP #$0A
  BNE IncDone
  LDA #$00
  STA HUNDREDS_DIGIT
IncDone:
  JSR PrintCounter
  RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintCounter:             
  LDA HUNDREDS_DIGIT
  CLC
  ADC #$10
  STA ScoreSpr3
  LDA TENS_DIGIT
  CLC
  ADC #$10
  STA ScoreSpr2
  LDA ONES_DIGIT
  CLC
  ADC #$10
  STA ScoreSpr1
  RTS

PrintScoreString:
  LDA PPU_STATUS_REG             ; read PPU status to reset the high/low latch
  LDA #$20
  STA PPU_ADDRESS_REG             ; write the high byte of $2000 address
  LDA #$37
  STA PPU_ADDRESS_REG             ; write the low byte of $2000 address
  LDX #$00              ; start out at 0
PrintScoreStringLoop:
  LDA scoreString, x     ; load data from address (background + the value in x)
  BEQ PrintScoreStringDone
  STA PPU_DATA_REG             ; write to PPU
  INX                   ; X = X + 1
  JMP PrintScoreStringLoop
PrintScoreStringDone:
  RTS