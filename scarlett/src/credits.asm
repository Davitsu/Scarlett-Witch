; Davitsu (David Giron) 2015
; Scarlett Witch

INCLUDE "hardware.inc"
INCLUDE "header.inc"

;o-----------------------------------o
;|            CREDITS INIT           |
;o-----------------------------------o

SECTION "Credits", HOME

Credits:
    di      ; Deshabilito interrupciones, no hacen falta durante la partida

    ld      a, 0            ; escribimos 0 en los registros de scroll X e Y
    ld      [rSCX], a       ; con lo que posicionamos la pantalla visible
    ld      [rSCY], a       ; al inicio (arriba a la izq) del fondo.

    call    apaga_LCD       ; llamamos a la rutina que apaga el LCD

    ; cargamos los tiles en la memoria de tiles

    ld      hl, CreditsTiles       ; cargamos en HL la direcciÃ³n de nuestro tile
    ld      de, _VRAM           ; en DE direcciÃ³n de la memoria de video
    ld      bc, EndCreditsTiles-CreditsTiles  ; numero de bytes a copiar

    call    CopiaMemoria

    ld      hl, CreditsMap
    ld      de, _SCRN0
    ld      bc, 32*32
    call    CopiaMemoriaMapa
 
    ; bien, tenemos todo el mapa de tiles cargado
    ; ahora limpiamos la memoria de sprites
    ld      de, _OAMRAM     ; memoria de atributos de sprites
    ld      bc, 40*4        ; 40 sprites x 4 bytes cada uno
    ld      l, 0                ; lo vamos a poner todo a cero, asi los sprites
    call    RellenaMemoria  ; no usados quedan fuera de pantalla

    ld      de, sw_oam_table     ; memoria de atributos de sprites
    ld      bc, 40*4        ; 40 sprites x 4 bytes cada uno
    ld      l, 0                ; lo vamos a poner todo a cero, asi los sprites
    call    RellenaMemoria  ; no usados quedan fuera de pantalla

    call    refresh_OAM

    ; configuramos y activamos el display
    ld      a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJON;|LCDCF_WIN9C00
    ld      [rLCDC], a

;o-----------------------------------o
;|           CREDITS LOOP            |
;o-----------------------------------o

credits_loop:
    halt
    nop
   
.wait:
    ld      a, [rLY] ; Comprueba si esta en el intervalo vertical (145)
    cp      145
    jr      nz, .wait 

    call    gbt_update ; Update player

    jr      credits_loop