; Davitsu (David Giron) 2015
; Scarlett Witch

INCLUDE "hardware.inc"
INCLUDE "header.inc"

_SPR0_Y     EQU     _OAMRAM ; la Y del sprite 0, es el inicio de la mem de sprites
_SPR0_X     EQU     _OAMRAM+1
_SPR0_NUM   EQU     _OAMRAM+2
_SPR0_ATT   EQU     _OAMRAM+3

_SPR1_Y     EQU     _OAMRAM+4
_SPR1_X     EQU     _OAMRAM+5
_SPR1_NUM   EQU     _OAMRAM+6
_SPR1_ATT   EQU     _OAMRAM+7

SECTION "SW_VAR_1", WRAM0

sw_playmode: DS 1               ; Modo actual
sw_palette_background: DS 1     ; Paleta de fondo (para efectos)

SECTION "Game", HOME ; Comienza el programa

Game:
    ld      a, %11100100    ; Colores de paleta desde el mas oscuro al mas claro, 11 10 01 00
    ld      [rBGP], a       ; escribimos esto en el registro de paleta de fondo
    ld      [sw_palette_background], a

    ld      a, %11010010
    ld      [rOBP0], a      ; y en la paleta 0 de sprites

    ld      a, 0            ; escribimos 0 en los registros de scroll X e Y
    ld      [rSCX], a       ; con lo que posicionamos la pantalla visible
    ld      [rSCY], a       ; al inicio (arriba a la izq) del fondo.

    call    apaga_LCD       ; llamamos a la rutina que apaga el LCD

    ; cargamos los tiles en la memoria de tiles

    ld      hl, GameTiles       ; cargamos en HL la direcciÃ³n de nuestro tile
    ld      de, _VRAM           ; en DE direcciÃ³n de la memoria de video
    ld      bc, EndGameTiles-GameTiles  ; numero de bytes a copiar

    call    CopiaMemoria
 
    ; cargamos el mapa
    ld      hl, GameMap
    ld      de, _SCRN0      ; mapa 0
    ld      bc, 32*32
    call    CopiaMemoriaMapa

    ; cargamos el mapa
    ld      hl, GameMap2
    ld      de, _SCRN1      ; mapa 1
    ld      bc, 32*32
    call    CopiaMemoriaMapa
 
    ; bien, tenemos todo el mapa de tiles cargado
    ; ahora limpiamos la memoria de sprites
    ld      de, _OAMRAM     ; memoria de atributos de sprites
    ld      bc, 40*4        ; 40 sprites x 4 bytes cada uno
    ld      l, 0                ; lo vamos a poner todo a cero, asi los sprites
    call    RellenaMemoria  ; no usados quedan fuera de pantalla

    ; ahora vamos a crear los sprite.

    ld      a, 74
    ld      [_SPR0_Y], a    ; posición Y del sprite     
    ld      a, 90
    ld      [_SPR0_X], a    ; posición X del sprite
    ld      a, 0
    ld      [_SPR0_NUM], a  ; número de tile en la tabla de tiles que usaremos
    ld      a, 0
    ld      [_SPR0_ATT], a  ; atributos especiales, de momento nada.

    ld      a, [_SPR0_Y]
    ld      [_SPR1_Y], a    ; posición Y del sprite     
    ld      a, [_SPR0_X]
    add     a, 8
    ld      [_SPR1_X], a    ; posición X del sprite
    ld      a, 2
    ld      [_SPR1_NUM], a  ; número de tile en la tabla de tiles que usaremos
    ld      a, 0
    ld      [_SPR1_ATT], a  ; atributos especiales, de momento nada.

    ; reseteamos el modo de juego, por defecto es modo aereo
    ld      a, 0
    ld      [sw_playmode], a

    ; configuramos y activamos el display
    ld      a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJON
    ld      [rLCDC], a

game_loop:
    halt
    nop
    ; leemos el pad
    call    lee_pad
    ; lo primero, esperamos por el VBlank, ya que no podemos modificar
    ; la VRAM fuera de Ã©l, o pasarÃ¡n cosas raras
.wait:
    ld      a, [rLY] ; Comprueba si esta en el intervalo vertical (145)
    cp      145
    jr      nz, .wait

    call switch_playmode
    call player_move
    call update_sprites

    call    gbt_update ; Update player

    ;call retardo
    jr      game_loop

switch_playmode:
    ; Compruebo si estoy cambiando
    ld      a, [sw_playmode]    ; Si esta cambiando, continuamos el efecto -> xxxx xxx1
    and     %00000001           ; Si no estaba cambiando, seguimos...      -> xxxx xxx0
    jr      nz, .switch_playmode_continue

    ld      a, [sw_pad]
    and     PADF_SELECT         ; Si se ha pulsado Select, seguimos...
    ret     z

    ld      a, [sw_playmode]
    or      %01110001           ; Avisamos de que estamos cambiando:
    ld      [sw_playmode], a    ; x111 xxx1

.switch_playmode_continue:

    ld      a, [sw_playmode]    ; Usamos 3 bits como contador
    swap    a                   ; Para que el fade sea mas lento
    and     %00000111           
    jr      nz, .switch_playmode_wait

    ld      a, [sw_playmode]
    and     %00000100           
    jr      z, .switch_playmode_fadeout

    jr      .switch_playmode_fadein

    ret

.switch_playmode_fadeout:
    ld      a, [rBGP] 
    cp      %00000000    
    call    nz, fade_out_palette ; Si la paleta no es blanca del todo, seguimos el fade

    ld      a, [rBGP] 
    cp      %00000000 
    jr      nz, .switch_playmode_end

    ld      a, [sw_playmode]
    or      %00000100           ; Ha acabado out, empezamos in:
    ld      [sw_playmode], a    ; xxxx x1xx

    ld      a, [rLCDC]          ; Cambiamos al otro mapa
    xor     %00001000
    ld      [rLCDC], a

    jr      .switch_playmode_end

.switch_playmode_fadein:
    ld      a, [rBGP] 
    ld      b, a
    ld      a, [sw_palette_background]
    cp      b
    call    nz, fade_in_palette

    ld      a, [rBGP] 
    ld      b, a
    ld      a, [sw_palette_background]
    cp      b
    jr    nz, .switch_playmode_end

    ld      a, %00000000
    ld      [sw_playmode], a
    
    ret

.switch_playmode_wait:
    ld      a, [sw_playmode]    ; Decrementamos el contador para la siguiente fase del fade
    swap    a
    dec     a
    swap    a
    ld      [sw_playmode], a 

    ret

.switch_playmode_end:
    ld      a, [sw_playmode]    ; Reiniciamos el contador
    or      %01110000
    ld      [sw_playmode], a

    ret


fade_out_palette:       ; Fade out de la paleta de fondo
    ld      d, 4        ; Contador para los 4 colores

    ld      a, [rBGP]   ; Cargamos la paleta en a
    ld      b, a        ; La guardamos en b para operar

.fade_out_palette_loop:
    and     %00000011
    jr      z, .fade_out_palette_continue

    dec     b           ; Si el color no es blanco, lo bajamos un tono

.fade_out_palette_continue:
    rlc     b
    rlc     b
    ld      a, b        ; Rotamos para coger el siguiente color

    dec     d           ; Decrementamos d, si no es 0 seguimos
    jr      nz, .fade_out_palette_loop

    ld      [rBGP], a   ; Cargamos la paleta resultante

    ret

fade_in_palette:        ; Fade out de la paleta de fondo
    ld      d, 4        ; Contador para los 4 colores
    ld      e, %00000000

    ld      a, [rBGP]   ; Cargamos la paleta en a
    ld      b, a        ; La guardamos en b para operar

.fade_in_palette_loop:
    and     %00000011
    cp      e
    jr      z, .fade_in_palette_continue

    inc     b           ; Si el color no es blanco, lo bajamos un tono

.fade_in_palette_continue:
    rrc     b
    rrc     b
    ld      a, b        ; Rotamos para coger el siguiente color

    inc     e
    dec     d           ; Decrementamos d, si no es 0 seguimos
    jr      nz, .fade_in_palette_loop

    ld      [rBGP], a   ; Cargamos la paleta resultante

    ret

player_move:

.player_move_up:
    ld      a, [sw_pad]
    and     PADF_UP
    jr      z, .player_move_down

    ld      a, [_SPR0_Y]
    dec     a
    ld      [_SPR0_Y], a

    ld      a, 8
    ld      [_SPR0_NUM], a
    ld      a, 10
    ld      [_SPR1_NUM], a

    ld      a, [_SPR0_ATT]
    and     %11011111
    ld      [_SPR0_ATT], a

    ld      a, [_SPR1_ATT]
    and     %11011111
    ld      [_SPR1_ATT], a

.player_move_down:
    ld      a, [sw_pad]
    and     PADF_DOWN
    jr      z, .player_move_right

    ld      a, [_SPR0_Y]
    inc     a
    ld      [_SPR0_Y], a

    ld      a, 0
    ld      [_SPR0_NUM], a
    ld      a, 2
    ld      [_SPR1_NUM], a

    ld      a, [_SPR0_ATT]
    and     %11011111
    ld      [_SPR0_ATT], a

    ld      a, [_SPR1_ATT]
    and     %11011111
    ld      [_SPR1_ATT], a

.player_move_right:
    ld      a, [sw_pad]
    and     PADF_RIGHT
    jr      z, .player_move_left

    ld      a, [_SPR0_X]
    inc     a
    ld      [_SPR0_X], a

    ld      a, 4
    ld      [_SPR0_NUM], a
    ld      a, 6
    ld      [_SPR1_NUM], a

    ld      a, [_SPR0_ATT]
    and     %11011111
    ld      [_SPR0_ATT], a

    ld      a, [_SPR1_ATT]
    and     %11011111
    ld      [_SPR1_ATT], a

.player_move_left:
    ld      a, [sw_pad]
    and     PADF_LEFT
    jr      z, .player_move_end

    ld      a, [_SPR0_X]
    dec     a
    ld      [_SPR0_X], a

    ld      a, 6
    ld      [_SPR0_NUM], a
    ld      a, 4
    ld      [_SPR1_NUM], a

    ld      a, [_SPR0_ATT]
    or      %00100000
    ld      [_SPR0_ATT], a

    ld      a, [_SPR1_ATT]
    or      %00100000
    ld      [_SPR1_ATT], a


.player_move_end:      

    ret

update_sprites:
    ld      a, [_SPR0_Y]
    ld      [_SPR1_Y], a    ; posición Y del sprite     
    ld      a, [_SPR0_X]
    add     a, 8
    ld      [_SPR1_X], a    ; posición X del sprite


    ret