InitBullet:
  LDA #$03
  STA MAX_BULLETS
  LDA #$05
  STA BULLET_DAMAGE
  LDA #$39
  STA BULLET_SPRITE
  RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Input: A holds bullet direction based on player direction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CreateBullet:
  ; create bullet object
  JSR FindFirstObjectSlot   ; location returned in x
  LDA #bulletSize
  STA $0300, x
  INX
  LDA px1
  STA $0300, x
  INX
  LDA py1
  STA $0300, x
  INX
  LDY playerDir
  LDA $0300, y
  STA $0300, x
  INX
  LDA #$05
  STA $0300, X
  INX
  LDA #$37
  STA $0300, X
  INX
  LDA #$02
  STA $0300, X

  ; create bullet sprite
  JSR FindFirstSpriteSlot    ; location returned in X
  LDA py1
  STA $0200, x
  INX
  LDA BULLET_SPRITE
  STA $0200, x
  INX
  LDA #$00
  STA $0200, x
  INX
  LDA px1
  STA $0200, x
  RTS

MoveBullet:

  RTS