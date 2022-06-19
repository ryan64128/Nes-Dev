InitPlayer:
    LDA #$00
    STA THIS
    LDA #$03
    STA THIS+1
    LDY #$00
    LDA #pSprSize
    STA [THIS], y
    LDY #playerX+1
    LDA #$44
    STA [THIS], y
    LDY #playerY+1
    LDA #$44
    STA [THIS], y
    LDY #playerSpeed+1
    LDA #$01
    STA [THIS], y
    LDY #pSprTopLeft+1
    LDA #$15
    STA [THIS], y
    LDY #pSprTopRight+1
    LDA #$16
    STA [THIS], y
    LDY #pSprBottomLeft+1
    LDA #$17
    STA [THIS], y
    LDY #pSprBottomRight+1
    LDA #$18
    STA [THIS], y
    LDY #playerDir+1
    LDA LEFT
    STA [THIS], y
    rts

MovePlayerLeft:
    LDA px1
    SEC 
    SBC #$01
    STA px1
    LDA px2
    SEC 
    SBC #$01
    STA px2
    LDA px3
    SEC 
    SBC #$01
    STA px3
    LDA px4
    SEC 
    SBC #$01
    STA px4
    RTS

MovePlayerRight:
    LDA px1
    CLC
    ADC #$01
    STA px1
    LDA px2
    CLC
    ADC #$01
    STA px2
    LDA px3
    CLC
    ADC #$01
    STA px3
    LDA px4
    CLC
    ADC #$01
    STA px4
    RTS

MovePlayerUp:
    LDA py1
    SEC 
    SBC #$01
    STA py1
    LDA py2
    SEC 
    SBC #$01
    STA py2
    LDA py3
    SEC 
    SBC #$01
    STA py3
    LDA py4
    SEC 
    SBC #$01
    STA py4
    RTS

MovePlayerDown:
    LDA py1
    CLC
    ADC #$01
    STA py1
    LDA py2
    CLC
    ADC #$01
    STA py2
    LDA py3
    CLC
    ADC #$01
    STA py3
    LDA py4
    CLC
    ADC #$01
    STA py4
    RTS
