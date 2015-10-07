; Davitsu (David Giron) 2015
; Scarlett Witch

INCLUDE "hardware.inc"
INCLUDE "header.inc"

_SPR_HEART1_Y       EQU     _RAM        ; Corazon 1
_SPR_HEART1_X       EQU     _RAM+1
_SPR_HEART1_NUM     EQU     _RAM+2
_SPR_HEART1_ATT     EQU     _RAM+3

_SPR_HEART2_Y       EQU     _RAM+4      ; Corazon 2
_SPR_HEART2_X       EQU     _RAM+5
_SPR_HEART2_NUM     EQU     _RAM+6
_SPR_HEART2_ATT     EQU     _RAM+7

_SPR_HEART3_Y       EQU     _RAM+8      ; Corazon 3
_SPR_HEART3_X       EQU     _RAM+9
_SPR_HEART3_NUM     EQU     _RAM+10
_SPR_HEART3_ATT     EQU     _RAM+11

_SPR_PLAYER_L_Y     EQU     _RAM+12     ; Player mitad izquierda
_SPR_PLAYER_L_X     EQU     _RAM+13
_SPR_PLAYER_L_NUM   EQU     _RAM+14
_SPR_PLAYER_L_ATT   EQU     _RAM+15

_SPR_PLAYER_R_Y     EQU     _RAM+16     ; Player mitad derecha
_SPR_PLAYER_R_X     EQU     _RAM+17
_SPR_PLAYER_R_NUM   EQU     _RAM+18
_SPR_PLAYER_R_ATT   EQU     _RAM+19

_SPR_FIREBALL_Y     EQU     _RAM+20     ; Disparo player 1
_SPR_FIREBALL_X     EQU     _RAM+21
_SPR_FIREBALL_NUM   EQU     _RAM+22
_SPR_FIREBALL_ATT   EQU     _RAM+23

_SPR_ENEMY1_L_Y     EQU     _RAM+24     ; Enemy 1 mitad izquierda
_SPR_ENEMY1_L_X     EQU     _RAM+25
_SPR_ENEMY1_L_NUM   EQU     _RAM+26
_SPR_ENEMY1_L_ATT   EQU     _RAM+27

_SPR_ENEMY1_R_Y     EQU     _RAM+28     ; Enemy 1 mitad derecha
_SPR_ENEMY1_R_X     EQU     _RAM+29
_SPR_ENEMY1_R_NUM   EQU     _RAM+30
_SPR_ENEMY1_R_ATT   EQU     _RAM+31

; DEFINITIONS
_SW_POZO            EQU     $0F
_SW_FACE_UP         EQU     8           ; Direccion a la que mira el player (a partir de su numero de tile)
_SW_FACE_DOWN       EQU     0
_SW_FACE_RIGHT      EQU     4
_SW_FACE_LEFT       EQU     6

SECTION "SW_VAR_1", WRAM0

sw_playmode: DS 1               ; Modo actual [0=Aereo, 1=Frontal]
sw_switch_params: DS 1          ; Parametros para el cambio de modo
sw_switch_cont_fade: DS 1       ; Contador para cambio de modo
sw_palette_background: DS 1     ; Paleta de fondo (para efectos)
sw_palette_oam: DS 1            ; Paleta de sprites
sw_palette_gbc_background: DS 8 ; Paleta de fondo (para efectos)
sw_palette_gbc_red: DS 1
sw_palette_gbc_green: DS 1
sw_palette_gbc_blue: DS 1
sw_player_health: DS 1          ; Salud del player
sw_player_inv: DS 1             ; Invencible, se activa al recibir dano
sw_player_pos_y: DS 1           ; Player Y Position
sw_player_pos_x: DS 1           ; Player X Position
sw_player_pos_tile: DS 1        ; [YX] Tile en el que se encuentra player
sw_player_sensor_up: DS 1       ; [YX] Tile del sensor up para colisiones
sw_player_sensor_down: DS 1     ; [YX] Tile del sensor down para colisiones
sw_player_sensor_right: DS 1    ; [YX] Tile del sensor right para colisiones
sw_player_sensor_left: DS 1     ; [YX] Tile del sensor left para colisiones
sw_player_sensor_land_r: DS 1   ; [YX] Tile del sensor right para pisar suelo
sw_player_sensor_land_l: DS 1   ; [YX] Tile del sensor left para pisar suelo
sw_player_lastpos_aereo: DS 1   ; [YX] Tile que tenia antes de cambiar a modo frontal
sw_player_lasth_aereo: DS 1     ; [0H] Altura que tenia al cambiar a modo frontal
sw_player_altura: DS 1          ; [0H] Altura que tiene en el modo Aereo. No confundir con lastpos_aereo
sw_player_altura_especial: DS 1 ; PRUEBA
sw_player_pos_before_jump_y: DS 1 ; Posicion Y antes de saltar/caer
sw_player_pos_before_jump_x: DS 1 ; Posicion Y antes de saltar/caer
sw_player_fall: DS 1            ; Si se ha caido en un pozo o no
sw_player_fall_cont: DS 1       ; Contador para reaparecer arriba
sw_player_room: DS 1            ; Indice de la room del player
sw_change_room_flag: DS 1       ; Estado del cambio de room
sw_current_map: DS 2            ; Direccion de memoria del mapa actual
sw_collision_map_a: DS 256      ; Mapa de colisiones y alturas [Modo Aereo]
sw_collision_map_f: DS 256      ; Mapa de colisiones y alturas [Modo Frontal]
sw_paint_tiles: DS 4            ; Indice de los tiles para pintar el mapa F
sw_player_jump_value_n: DS 1    ; Enteros para el salto
sw_player_jump_value_d: DS 1    ; Decimales para el salto
sw_player_jump_state: DS 1      ; Estado del salto
sw_fireball_pos_y: DS 1         ; Fireball Y Position
sw_fireball_pos_x: DS 1         ; Fireball X Position
sw_fireball_pos_tile: DS 1      ; [YX] Tile de fireball
sw_fireball_state: DS 1         ; Fireball state
sw_fireball_frame: DS 1         ; Fireball animation
sw_old_scy: DS 1                ; Scroll Display anterior Y
sw_cont: DS 1                   ; Contador para usos variados
sw_enemy_pos_y: DS 1
sw_enemy_pos_x: DS 1
sw_enemy_pos_tile: DS 1
sw_enemy_facing: DS 1           ; Posicion a la que mira el enemigo
sw_enemy_health: DS 2           
sw_enemy_type: DS 1             ; Tipo del enemigo [0 = Knight, 1 = Shooter]

;o-----------------------------------o
;|            GAME INIT              |
;o-----------------------------------o

SECTION "Game", HOME ; Comienza el programa

Game:
    di      ; Deshabilito interrupciones, no hacen falta durante la partida

    ld      a, %11100100    ; Colores de paleta desde el mas oscuro al mas claro, 11 10 01 00
    ld      [rBGP], a       ; escribimos esto en el registro de paleta de fondo
    ld      [sw_palette_background], a

    ld      a, %11010010
    ld      [rOBP0], a      ; paleta 0 de sprites
    ld      [sw_palette_oam], a

    ld      a, %11100001
    ld      [rOBP1], a      ; paleta 1 de sprites

    ; Paleta GBC Background
    ;ld      hl, palette_dungeon
    ;ld      de, sw_palette_gbc_background
    ;ld      bc, 4*2
    ;call    CopiaMemoria

    ld      a, 0            ; escribimos 0 en los registros de scroll X e Y
    ld      [rSCX], a       ; con lo que posicionamos la pantalla visible
    ld      [rSCY], a       ; al inicio (arriba a la izq) del fondo.

    call    apaga_LCD       ; llamamos a la rutina que apaga el LCD

    ; cargamos los tiles en la memoria de tiles

    ld      hl, GameTiles       ; cargamos en HL la direcciÃ³n de nuestro tile
    ld      de, _VRAM           ; en DE direcciÃ³n de la memoria de video
    ld      bc, EndGameTiles-GameTiles  ; numero de bytes a copiar

    call    CopiaMemoria

    ; seleccionamos el mapa actual para luego cambiar de modo
    ld      a, 1
    ld      [sw_player_room], a

    ld      hl, GameMap1                ; Tiles Mapa Aereo
    ld      a, h
    ld      [sw_current_map], a
    ld      a, l
    ld      [sw_current_map+1], a               
    ld      de, _SCRN0
    ld      bc, 32*32
    call    CopiaMemoria

    ld      hl, GameMap1Col              ; Colisiones Mapa Aereo
    ld      de, sw_collision_map_a     
    ld      bc, 16*16
    call    CopiaMemoria

    ld      hl, _SCRN1
    ld      d, $25
    ld      bc, 32*32
    call    memset

    ld      hl, sw_collision_map_f      ; Colisiones Mapa Frontal
    ld      a, 0
    ld      d, a
    ld      bc, 16*16
    call    memset

 
    ; bien, tenemos todo el mapa de tiles cargado
    ; ahora limpiamos la memoria de sprites
    ld      de, _OAMRAM     ; memoria de atributos de sprites
    ld      bc, 40*4        ; 40 sprites x 4 bytes cada uno
    ld      l, 0                ; lo vamos a poner todo a cero, asi los sprites
    call    RellenaMemoria  ; no usados quedan fuera de pantalla

    ; posiciones del player (no de los graficos)
    ld      a, $EF
    ld      [sw_player_pos_y], a    ; posición Y del sprite     
    ld      a, $28
    ld      [sw_player_pos_x], a    ; posición X del sprite

    ; salud 
    ld      a, 6
    ld      [sw_player_health], a

    ; invencible
    ld      a, 0
    ld      [sw_player_inv], a

    ; salto
    ld      a, 0
    ld      [sw_player_jump_value_n], a
    ld      [sw_player_jump_value_d], a
    ld      [sw_player_jump_state], a

    ; caida
    ld      a, 0
    ld      [sw_player_pos_before_jump_y], a
    ld      [sw_player_pos_before_jump_x], a
    ld      [sw_player_fall], a
    ld      [sw_player_fall_cont], a

    ; cambio de room

    ld      a, 0
    ld      [sw_change_room_flag], a

    ; Fireball
    ld      a, 0
    ld      [sw_fireball_pos_y], a
    ld      a, 0
    ld      [sw_fireball_pos_x], a
    ld      a, 0
    ld      [sw_fireball_state], a

    ; Enemy
    ld      a, 0;140
    ld      [sw_enemy_pos_y], a
    ld      a, 0;40
    ld      [sw_enemy_pos_x], a
    ld      a, 0
    ld      [sw_enemy_pos_tile], a
    ld      a, 1
    ld      [sw_enemy_facing], a
    ld      a, 2
    ld      [sw_enemy_health], a
    ld      a, 1
    ld      [sw_enemy_type], a

    ld      de, sw_oam_table     ; memoria de atributos de sprites
    ld      bc, 40*4        ; 40 sprites x 4 bytes cada uno
    ld      l, 0                ; lo vamos a poner todo a cero, asi los sprites
    call    RellenaMemoria  ; no usados quedan fuera de pantalla

    ; ahora vamos a crear los sprite.

    ld      a, 16
    ld      [_SPR_HEART1_Y], a    ; posición Y del sprite     
    ld      a, 16
    ld      [_SPR_HEART1_X], a    ; posición X del sprite
    ld      a, 41
    ld      [_SPR_HEART1_NUM], a  ; número de tile en la tabla de tiles que usaremos
    ld      a, 0
    ld      [_SPR_HEART1_ATT], a  ; atributos especiales, de momento nada.

    ld      a, 16
    ld      [_SPR_HEART2_Y], a    ; posición Y del sprite     
    ld      a, 24
    ld      [_SPR_HEART2_X], a    ; posición X del sprite
    ld      a, 41
    ld      [_SPR_HEART2_NUM], a  ; número de tile en la tabla de tiles que usaremos
    ld      a, 0
    ld      [_SPR_HEART2_ATT], a  ; atributos especiales, de momento nada.

    ld      a, 16
    ld      [_SPR_HEART3_Y], a    ; posición Y del sprite     
    ld      a, 32
    ld      [_SPR_HEART3_X], a    ; posición X del sprite
    ld      a, 41
    ld      [_SPR_HEART3_NUM], a  ; número de tile en la tabla de tiles que usaremos
    ld      a, 0
    ld      [_SPR_HEART3_ATT], a  ; atributos especiales, de momento nada.


    ld      a, 56
    ld      [_SPR_PLAYER_L_Y], a    ; posición Y del sprite     
    ld      a, 56
    ld      [_SPR_PLAYER_L_X], a    ; posición X del sprite
    ld      a, 0
    ld      [_SPR_PLAYER_L_NUM], a  ; número de tile en la tabla de tiles que usaremos
    ld      a, 0
    ld      [_SPR_PLAYER_L_ATT], a  ; atributos especiales, de momento nada.

    ld      a, [_SPR_PLAYER_L_Y]
    ld      [_SPR_PLAYER_R_Y], a    ; posición Y del sprite     
    ld      a, [_SPR_PLAYER_L_X]
    add     a, 8
    ld      [_SPR_PLAYER_R_X], a    ; posición X del sprite
    ld      a, 2
    ld      [_SPR_PLAYER_R_NUM], a  ; número de tile en la tabla de tiles que usaremos
    ld      a, 0
    ld      [_SPR_PLAYER_R_ATT], a  ; atributos especiales, de momento nada.

    ld      a, 0
    ld      [_SPR_FIREBALL_Y], a 
    ld      a, 0
    ld      [_SPR_FIREBALL_X], a
    ld      a, 92
    ld      [_SPR_FIREBALL_NUM], a
    ld      a, 0
    ld      [_SPR_FIREBALL_ATT], a

    ld      a, 0
    ld      [_SPR_ENEMY1_L_Y], a 
    ld      a, 0
    ld      [_SPR_ENEMY1_L_X], a
    ld      a, 136
    ld      [_SPR_ENEMY1_L_NUM], a
    ld      a, %00010000
    ld      [_SPR_ENEMY1_L_ATT], a

    ld      a, 0
    ld      [_SPR_ENEMY1_R_Y], a 
    ld      a, 0
    ld      [_SPR_ENEMY1_R_X], a
    ld      a, 138
    ld      [_SPR_ENEMY1_R_NUM], a
    ld      a, %00010000
    ld      [_SPR_ENEMY1_R_ATT], a

    call    refresh_OAM
    call    update_display      ; mas tarde lo haga, mas bugs genera
    call    update_sprites

    ; reseteamos el modo de juego, por defecto es modo aereo
    ld      a, 0
    ld      [sw_playmode], a
    ld      a, 0
    ld      [sw_switch_params], a

    ; configuramos y activamos el display
    ld      a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJON;|LCDCF_WIN9C00
    ld      [rLCDC], a

    ; VENTANA
    ;ld      a, 8
    ;ld      [rWX], a
 
    ;ld      a, 128
    ;ld      [rWY], a
 
    ;ld      a, [rLCDC]
    ;or      LCDCF_WINON
    ;ld      [rLCDC], a

;o-----------------------------------o
;|             GAME LOOP             |
;o-----------------------------------o

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

    call    update_display
    call    update_sprites
    call    refresh_OAM
    ; refresh_OAM tiene que hacerse antes de que termine V-Blank
    ; asi que no deberia ser mas abajo

    call    switch_playmode

    ld      a, [sw_switch_params]
    and     %00000001
    jr      nz, .game_loop_continue
    
    call    player_move
    call    update_pos_tile
    call    update_altura
    call    player_jump
    call    check_fall
    call    player_shoot
    ;call    update_enemy
    call    check_door

.game_loop_continue:
    ld      a, [sw_change_room_flag]
    cp      1
    jr      z, .game_loop_end
    
    call    check_collisions

.game_loop_end:
    ld      a, 0
    ld      [sw_change_room_flag], a

    call    update_health

    call    gbt_update ; Update player

    jr      game_loop

;o-----------------------------------o
;|          SWITCH MODES             |
;o-----------------------------------o

switch_playmode:
    ; Compruebo si estoy cambiando
    ld      a, [sw_switch_params]   ; Si esta cambiando, continuamos el efecto -> xxxx xxx1
    and     %00000001               ; Si no estaba cambiando, seguimos...      -> xxxx xxx0
    jr      nz, .switch_playmode_continue

    ld      a, [sw_pad]
    and     PADF_B                      ; Si se ha pulsado B, seguimos...
    ret     z

    ld      a, [sw_player_jump_state]
    cp      0
    ret     nz

    ld      a, [sw_switch_params]
    or      %01110001                   ; Avisamos de que estamos cambiando:
    ld      [sw_switch_params], a       ; x111 xxx1

    ld      a, 32
    ld      [sw_switch_cont_fade], a   ; Preparamos contador de 32 para el fade

.switch_playmode_continue:
    ld      a, [sw_cpu_type]            ; Si no es GBC, saltate esto
    cp      $11
    jr      nz, .switch_playmode_gbc_fadeout_end

; FADE EFFECT GAME BOY COLOR
    ld      a, [sw_switch_params]
    and     %00000100
    jr      nz, .switch_playmode_gbc_fadein

.switch_playmode_gbc_fadeout:
    call    prepare_fade_out_palette_gbc
    jr      .switch_playmode_gbc_fadeout_end

.switch_playmode_gbc_fadein:
    call    prepare_fade_in_palette_gbc
; END FADE EFFECT GAME BOY COLOR

.switch_playmode_gbc_fadeout_end:
    ld      a, [sw_switch_cont_fade]
    dec     a
    ld      [sw_switch_cont_fade], a

    ld      a, [sw_switch_params]    ; Usamos 3 bits como contador
    swap    a                        ; Para que el fade sea mas lento
    and     %00000111           
    jr      nz, .switch_playmode_wait

    ld      a, [sw_switch_params]
    and     %00000100           
    jr      z, .switch_playmode_fadeout

    jr      .switch_playmode_fadein

    ret

.switch_playmode_fadeout:
    ld      a, [rBGP] 
    cp      %00000000    
    call    nz, fade_out_palette        ; Si la paleta no es blanca del todo, seguimos el fade

    ld      a, [sw_switch_cont_fade]
    cp      0
    jr      nz, .switch_playmode_end

    ld      a, [rBGP] 
    cp      %00000000 
    jr      nz, .switch_playmode_end

    ld      a, 32
    ld      [sw_switch_cont_fade], a   

    ld      a, [sw_switch_params]
    or      %00000100                   ; Ha acabado out, empezamos in:
    ld      [sw_switch_params], a       ; xxxx x1xx

    ;ld      a, [rLCDC]                  ; Cambiamos al otro mapa
    ;xor     %00001000
    ;ld      [rLCDC], a

    call    switch_to                   ; Preparamos mapa, colisiones, etc

    jr      .switch_playmode_end

.switch_playmode_fadein:
    ; FadeIn de Background
    ld      a, [rBGP]
    ld      b, a

    ld      a, [sw_palette_background]
    ld      c, a
    call    fade_in_palette
    ld      [rBGP], a                   ; Cargamos la paleta resultante

    ; FadeIn de OAM
    ld      a, [rOBP0]
    ld      b, a

    ld      a, [sw_palette_oam]
    ld      c, a
    call    fade_in_palette
    ld      [rOBP0], a                   ; Cargamos la paleta resultante

    ld      a, [sw_switch_cont_fade]
    cp      0
    jr      nz, .switch_playmode_end

    ; Comprobar si se ha terminado el FadeIn
    ld      a, [rBGP] 
    ld      b, a
    ld      a, [sw_palette_background]
    cp      b
    jr    nz, .switch_playmode_end

    ld      a, %00000000
    ld      [sw_switch_params], a
    
    ret

.switch_playmode_wait:
    ld      a, [sw_switch_params]   ; Decrementamos el contador para la siguiente fase del fade
    swap    a
    dec     a
    swap    a
    ld      [sw_switch_params], a 

    ret

.switch_playmode_end:
    ld      a, [sw_switch_params]   ; Reiniciamos el contador
    or      %01110000
    ld      [sw_switch_params], a

    ret

;o-----------------------------------o
;|       SWITCH - PREPARE MAP        |
;o-----------------------------------o

switch_to:
    ld      a, [sw_playmode]
    xor     %00000001
    ld      [sw_playmode], a

    jp      z, .switch_to_aereo

.switch_to_frontal:
    call    reset_fireball                  ; Borramos la fireball si es que hay

    call    update_altura                   ; Almacenamos la altura a la que estamos
    ld      [sw_player_lasth_aereo], a

    ld      a, [sw_player_sensor_down]      ; Almaceno la posicion que tenia
    ld      [sw_player_lastpos_aereo], a    ; antes de cambiar de modo

    and     %11110000                       ; Me quedo con Y -> yyyy0000
    swap    a                               ; 0Y 
    ld      b, a                            ; b -> Y Profundidad

    ld      a, [sw_player_lasth_aereo]
    ld      c, a                            ; c -> Y Altura

    ld      a, b
    cp      c 
    jr      c, .switch_to_frontal_pLh       ; Profundidad < Altura

    ld      a, c                            ; Si la altura ya es 0 nos saltamos
    cp      0                               ; el siguiente bucle
    jr      z, .switch_to_frontal_prepare_loop_end

.switch_to_frontal_prepare_loop:
    dec     b                               ; Restamos hasta que la altura sea 0
    dec     c                               
    jr      nz, .switch_to_frontal_prepare_loop

.switch_to_frontal_prepare_loop_end:
    ld      hl, sw_collision_map_a          ; Preparamos el mapa A para que empiece
    ld      d, $00                          ; por la primera fila que nos interesa
    ld      e, b
    swap    e
    add     hl, de
    ld      d, h
    ld      e, l

    ld      hl, sw_collision_map_f

    ld      a, 16
    ld      [sw_cont], a

    jr      .switch_to_frontal_pEh 

.switch_to_frontal_pLh:         ; p Less h
    ld      a, b 
    sub     c 
    ld      b, a                ; p = p - h
    ld      c, 0                ; h = 0

    ld      hl, sw_collision_map_f

    ld      a, 16               ; Contador para las filas
    ld      [sw_cont], a

.switch_to_frontal_pLh_loop:    ; Con este bucle relleno de aire ($00) las 
    ld      a, [sw_cont]        ; alturas del mapa F que no corresponden a
    cp      16                  ; ninguna profundidad del mapa A
    jr      z, .switch_to_frontal_pLh_loop_pared
    ld      a, [sw_cont]
    cp      1
    jr      z, .switch_to_frontal_pLh_loop_pared
    
    ld      [hl], $00           
    jr      .switch_to_frontal_pLh_loop_continue

.switch_to_frontal_pLh_loop_pared:
    ld      [hl], $10

.switch_to_frontal_pLh_loop_continue:
    inc     hl                  

    ld      a, [sw_cont]
    dec     a
    ld      [sw_cont], a
    jr      nz, .switch_to_frontal_pLh_loop

    inc     b 
    inc     c 

    ld      a, 16
    ld      [sw_cont], a
 
    ld      a, b                                ; Si la profundidad es 0
    cp      0                                   ; (no es negativa), ya podemos
    jr      nz, .switch_to_frontal_pLh_loop     ; empezar a transformar

    push    hl 
    ld      hl, sw_collision_map_a
    ld      d, h 
    ld      e, l
    pop     hl

.switch_to_frontal_pEh:         ; p Equal h

.switch_to_frontal_pEh_loop:
    ld      a, [sw_cont]
    cp      16          
    jr      z, .switch_to_frontal_pEh_pared
    ld      a, [sw_cont]
    cp      1
    jr      z, .switch_to_frontal_pEh_pared

    call    switch_to_compare_tile_pEh
    ld      [hl], a          
    jr      .switch_to_frontal_pEh_continue

.switch_to_frontal_pEh_pared:
    ld      [hl], $10           

.switch_to_frontal_pEh_continue:

    inc     hl
    inc     de

    ld      a, [sw_cont]
    dec     a
    ld      [sw_cont], a
    jr      nz, .switch_to_frontal_pEh_loop

    inc     b
    inc     c

    ld      a, 16
    ld      [sw_cont], a

    ld      a, c
    cp      15
    jr      z, .switch_to_frontal_pMh

    ld      a, b
    cp      15
    jr      z, .switch_to_frontal_pMh

    jr      .switch_to_frontal_pEh_loop

.switch_to_frontal_pMh:
    ; Si quisiera poner pozos tendria que ser aqui
    ld      a, 16
    ld      d, h
    ld      e, l
.switch_to_frontal_pMh_prepare:
    dec     de
    dec     a
    jr      nz, .switch_to_frontal_pMh_prepare 

    push    de 

.switch_to_frontal_pMh_loop:

    ld      a, [de]
    ld      [hl], a
    inc     hl
    inc     de

    ld      a, [sw_cont]
    dec     a
    ld      [sw_cont], a
    jr      nz, .switch_to_frontal_pMh_loop

    inc     c 

    ld      a, 16
    ld      [sw_cont], a

    pop     af
    push    de

    ld      a, c
    cp      16
    jr      nz, .switch_to_frontal_pMh_loop

    pop     de

.switch_to_frontal_end:
    call    fill_collisions_with_tiles

    ld      a, [sw_player_lasth_aereo]      ; Recolocamos al Player
    swap    a
    ld      [sw_player_pos_y], a

    ret

.switch_to_aereo:
    call    apaga_LCD

    ld      a, [sw_current_map]
    ld      h, a
    ld      a, [sw_current_map+1]
    ld      l, a
    ld      de, _SCRN0
    ld      bc, 32*32
    call    CopiaMemoria

    call    enciende_LCD

    ld      a, [sw_player_pos_tile]
    and     %11110000
    swap    a
    ld      b, a

    ld      a, [sw_player_lasth_aereo]
    cp      b
    jr      c, .switch_to_aereo_aLb

.switch_to_aereo_aMb:
    sub     b

    ld      b, a
    ld      a, [sw_player_lastpos_aereo]
    and     %11110000
    swap    a
    sub     b
    inc     a
    swap    a
    ld      [sw_player_pos_y], a

    jr      .switch_to_aereo_continue

.switch_to_aereo_aLb:
    ld      c, b
    ld      b, a
    ld      a, c
    sub     b

    ld      b, a
    ld      a, [sw_player_lastpos_aereo]
    and     %11110000
    swap    a
    add     a, b
    inc     a
    swap    a
    ld      [sw_player_pos_y], a

.switch_to_aereo_continue:

    ret

switch_to_compare_tile_pEh:
    ld      a, [de]                             ; Cojo la altura del tile
    and     %00001111                           ; del mapa A
    cp      c 
    jr      c, .switch_to_compare_tile_pEh_aLc  ; Si 
    jr      z, .switch_to_compare_tile_pEh_aEc
    jr      .switch_to_compare_tile_pEh_aMc
.switch_to_compare_tile_pEh_aLc:
    ld      a, $10
    ret

.switch_to_compare_tile_pEh_aEc:
    push    hl
    push    de
    push    bc
    ld      c, a

    ld      a, b        ; Si estamos en 15, la altura mas baja, no podemos
    cp      15          ; comparar con el tile inferior porque no hay
    jr      z, .switch_to_compare_tile_pEh_aEc_continue

    ld      h, d
    ld      l, e
    ld      d, 0
    ld      e, $10
    add     hl, de
    ld      a, [hl]
    and     %00001111
    ld      b, a
    ld      a, c 
    cp      b
    jr      c, .switch_to_compare_tile_pEh_aEc_cero

.switch_to_compare_tile_pEh_aEc_continue:
    ld      a, $10

    jr      .switch_to_compare_tile_pEh_aEc_end    

.switch_to_compare_tile_pEh_aEc_cero:
    ld      a, $00

.switch_to_compare_tile_pEh_aEc_end:
    pop     bc
    pop     de
    pop     hl

    ret

.switch_to_compare_tile_pEh_aMc:
    ld      a, $00
    ret

fill_collisions_with_tiles:
    call    apaga_LCD

    ld      hl, _SCRN0
    ld      de, sw_collision_map_f
    ld      a, 0
    ld      [sw_cont], a
    ld      c, 0

.fill_collisions_with_tiles_loop:
    ld      a, [de]
    swap    a
    and     %00000001
    jr      nz, .fill_collisions_with_tiles_solid

.fill_collisions_with_tiles_air:
    call    fill_collisions_air
    jr      .fill_collisiones_with_tiles_paint

.fill_collisions_with_tiles_solid:
    call    fill_collisions_solid
    jr      .fill_collisiones_with_tiles_paint

.fill_collisiones_with_tiles_paint:
    push    hl
    push    de

    ld      a, [sw_paint_tiles]
    ld      [hl], a
    inc     hl
    ld      a, [sw_paint_tiles+1]
    ld      [hl], a
    ld      d, 0
    ld      e, 31
    add     hl, de
    ld      a, [sw_paint_tiles+2]
    ld      [hl], a
    inc     hl
    ld      a, [sw_paint_tiles+3]
    ld      [hl], a

    pop     de
    pop     hl

.fill_collisions_with_tiles_painted:
    inc     hl
    inc     hl
    inc     de

    inc     c
    ld      a, c
    cp      16
    jr      c, .fill_collisions_with_tiles_loop

    ld      c, 0
    push    de
    ld      d, 0
    ld      e, 32
    add     hl, de
    pop     de

    ld      a, [sw_cont]
    inc     a
    ld      [sw_cont], a
    cp      16
    jr      c, .fill_collisions_with_tiles_loop

    call    enciende_LCD

    ret

fill_collisions_air:
    ld      a, [sw_cont]
    cp      5
    jr      c, .fill_collisions_air_white0
    cp      8
    jr      c, .fill_collisions_air_white1
    cp      9
    jr      c, .fill_collisions_air_white2
    cp      10
    jr      c, .fill_collisions_air_white3

.fill_collisions_air_white4:
    ld      a, 38
    ld      [sw_paint_tiles], a
    ld      a, 38
    ld      [sw_paint_tiles+1], a
    ld      a, 38
    ld      [sw_paint_tiles+2], a
    ld      a, 38
    ld      [sw_paint_tiles+3], a
    ret

.fill_collisions_air_white3:
    ld      a, 86
    ld      [sw_paint_tiles], a
    ld      a, 86
    ld      [sw_paint_tiles+1], a
    ld      a, 87
    ld      [sw_paint_tiles+2], a
    ld      a, 87
    ld      [sw_paint_tiles+3], a
    ret

.fill_collisions_air_white2:
    ld      a, 84
    ld      [sw_paint_tiles], a
    ld      a, 84
    ld      [sw_paint_tiles+1], a
    ld      a, 85
    ld      [sw_paint_tiles+2], a
    ld      a, 85
    ld      [sw_paint_tiles+3], a
    ret

.fill_collisions_air_white1:
    ld      a, 67
    ld      [sw_paint_tiles], a
    ld      a, 67
    ld      [sw_paint_tiles+1], a
    ld      a, 68
    ld      [sw_paint_tiles+2], a
    ld      a, 68
    ld      [sw_paint_tiles+3], a
    ret

.fill_collisions_air_white0:
    ld      a, 37
    ld      [sw_paint_tiles], a
    ld      a, 37
    ld      [sw_paint_tiles+1], a
    ld      a, 37
    ld      [sw_paint_tiles+2], a
    ld      a, 37
    ld      [sw_paint_tiles+3], a
    ret

; TILES SOLIDOS
fill_collisions_solid:
    ld      a, c
    cp      0   ; Limite izquierdo
    jr      z, .fill_collisions_solid_lim_left
    cp      15  ; Limite derecho
    jr      z, .fill_collisions_solid_lim_right

    push    de
    dec     de
    ld      a, [de]
    pop     de
    swap    a
    and     %00000001 ; Pared borde izquierdo
    jr      z, .fill_collisions_solid_wall_left

    push    de
    inc     de
    ld      a, [de]
    pop     de
    swap    a
    and     %00000001 ; Pared borde izquierdo
    jr      z, .fill_collisions_solid_wall_right

.fill_collisions_solid_default:
    ld      a, 39
    ld      [sw_paint_tiles], a
    ld      a, 39
    ld      [sw_paint_tiles+1], a
    ld      a, 17
    ld      [sw_paint_tiles+2], a
    ld      a, 17
    ld      [sw_paint_tiles+3], a
    ret

.fill_collisions_solid_lim_left:
    ld      a, 52
    ld      [sw_paint_tiles], a
    ld      a, 50
    ld      [sw_paint_tiles+1], a
    ld      a, 53
    ld      [sw_paint_tiles+2], a
    ld      a, 51
    ld      [sw_paint_tiles+3], a
    ret

.fill_collisions_solid_lim_right:
    ld      a, 54
    ld      [sw_paint_tiles], a
    ld      a, 56
    ld      [sw_paint_tiles+1], a
    ld      a, 55
    ld      [sw_paint_tiles+2], a
    ld      a, 57
    ld      [sw_paint_tiles+3], a
    ret

.fill_collisions_solid_wall_left:
    push    de
    inc     de
    ld      a, [de]
    pop     de
    swap    a
    and     %00000001 ; Pared borde izquierdo
    jr      z, .fill_collisions_solid_wall_leftandright

    ld      a, 61
    ld      [sw_paint_tiles], a
    ld      a, 39
    ld      [sw_paint_tiles+1], a
    ld      a, 60
    ld      [sw_paint_tiles+2], a
    ld      a, 17
    ld      [sw_paint_tiles+3], a
    ret

.fill_collisions_solid_wall_right:
    ld      a, 39
    ld      [sw_paint_tiles], a
    ld      a, 65
    ld      [sw_paint_tiles+1], a
    ld      a, 17
    ld      [sw_paint_tiles+2], a
    ld      a, 64
    ld      [sw_paint_tiles+3], a
    ret

.fill_collisions_solid_wall_leftandright:
    ld      a, 61
    ld      [sw_paint_tiles], a
    ld      a, 65
    ld      [sw_paint_tiles+1], a
    ld      a, 60
    ld      [sw_paint_tiles+2], a
    ld      a, 64
    ld      [sw_paint_tiles+3], a
    ret

update_altura:
    ld      hl, sw_collision_map_a          ; Almacenamos la altura a la que estamos
    ld      d, 0                            ; d  -> 00
    ld      a, [sw_player_pos_tile]         ; e  -> YX (coordenadas tile)
    ld      e, a                            ; de -> 00YX
    add     hl, de                          ; Sumamos al primer byte del mapa
    ld      a, [hl]                         ; de colisiones para acceder al byte
    and     %00001111
    ld      [sw_player_altura_especial], a      ; Guardamos la altura

    ld      hl, sw_collision_map_a          ; Almacenamos la altura a la que estamos
    ld      d, 0                            ; d  -> 00
    ld      a, [sw_player_sensor_down]      ; e  -> YX (coordenadas tile)
    ld      e, a                            ; de -> 00YX
    add     hl, de                          ; Sumamos al primer byte del mapa
    ld      a, [hl]                         ; de colisiones para acceder al byte
    and     %00001111
    ld      [sw_player_altura], a      ; Guardamos la altura

    ret

;o-----------------------------------o
;|           FADE EFFECT             |
;o-----------------------------------o

fade_out_palette:       ; Fade out de la paleta de fondo
    ld      d, 4        ; Contador para los 4 colores

    ld      a, [rBGP]   ; Cargamos la paleta en a
    ld      b, a        ; La guardamos en b para operar

    ld      a, [rOBP0]
    ld      c, a

.fade_out_palette_loop:
    ld      a, b        
    and     %00000011
    jr      z, .fade_out_palette_oam

    dec     b           ; Si el color no es blanco, lo bajamos un tono

.fade_out_palette_oam:
    ;ld      b, a

    ld      a, c        
    and     %00000011
    jr      z, .fade_out_palette_continue

    dec     c           ; Si el color no es blanco, lo bajamos un tono

.fade_out_palette_continue:
    ;ld      c, a

    rlc     b
    rlc     b           ; Rotamos para coger el siguiente color

    rlc     c
    rlc     c           ; Rotamos para coger el siguiente color
    
    dec     d           ; Decrementamos d, si no es 0 seguimos
    jr      nz, .fade_out_palette_loop

    ld      a, b
    ld      [rBGP], a   ; Cargamos la paleta resultante

    ld      a, c
    ld      [rOBP0], a

    ret

fade_in_palette:        ; Fade out de la paleta de fondo
    ld      d, 4        ; Contador para los 4 colores

.fade_in_palette_loop:
    ld      a, c
    and     %00000011
    ld      e, a
    ld      a, b
    and     %00000011
    cp      e
    jr      z, .fade_in_palette_continue

    inc     b           ; Si el color no es blanco, lo bajamos un tono

.fade_in_palette_continue:
    rrc     b
    rrc     b
    rrc     c
    rrc     c

    dec     d           ; Decrementamos d, si no es 0 seguimos
    jr      nz, .fade_in_palette_loop

    ld      a, b

    ret

prepare_fade_out_palette_gbc:
    ; Palette Background 0
    ld      hl, sw_palette_gbc_background
    ld      a, %00000000    ; Siguiente paleta fondo seria aumentar %00xxx000
    call    bg_get_palette
    ld      hl, sw_palette_gbc_background
    call    fade_out_palette_gbc
    ld      hl, sw_palette_gbc_background
    ld      a, 0
    call    bg_set_palette

    ; Palette Sprite 0
    ld      hl, sw_palette_gbc_background
    ld      a, %00000000    ; Siguiente paleta sprite seria aumentar %00xxx000
    call    spr_get_palette
    ld      hl, sw_palette_gbc_background
    call    fade_out_palette_gbc
    ld      hl, sw_palette_gbc_background
    ld      a, 0
    call    spr_set_palette

    ret

fade_out_palette_gbc:
    ld      a, 4
    ld      [sw_cont], a

.fade_out_palette_gbc_loop_start:
    push    hl
    ld      e, [hl]
    inc     hl
    ld      d, [hl]
    pop     hl

    ld      a, e
    cp      %11111111
    jr      nz, .fade_out_palette_gbc_loop
    ld      a, d
    cp      %01111111
    jr      nz, .fade_out_palette_gbc_loop

    jr      .fade_out_palette_gbc_loop_end

.fade_out_palette_gbc_loop:
    ld      a, e
    and     %00011111
    cp      %00011111
    jr      z, .fade_out_palette_gbc_loop1 
    inc     e

.fade_out_palette_gbc_loop1:
    push    de
    ld      a, e
    swap    a
    rrc     a
    and     %00000111
    ld      b, a
    ld      a, d
    swap    a
    rrc     a
    and     %00011000
    or      b
    cp      %00011111
    pop     de
    jr      z, .fade_out_palette_gbc_loop2 
    inc     a
    
    ld      b, a
    swap    a
    rlc     a
    and     %11100000
    ld      c, a
    ld      a, e
    and     %00011111
    or      c
    ld      e, a
    ld      a, b
    rrc     a
    rrc     a
    rrc     a
    and     %00000011
    ld      c, a
    ld      a, d
    and     %11111100
    or      c
    ld      d, a

.fade_out_palette_gbc_loop2:
    rrc     d
    rrc     d
    ld      a, d
    and     %00011111
    cp      %00011111
    jr      z, .fade_out_palette_gbc_loop3
    inc     d

.fade_out_palette_gbc_loop3:
    rlc     d
    rlc     d

    ld      a, e
    ld      [hl], e
    inc     hl
    ld      a, d
    ld      [hl], d
    inc     hl
    jr      .fade_out_palette_gbc_loop_if

.fade_out_palette_gbc_loop_end:
    inc     hl
    inc     hl

.fade_out_palette_gbc_loop_if:
    ld      a, [sw_cont]
    dec     a
    ld      [sw_cont], a
    jr      nz, .fade_out_palette_gbc_loop_start

    ret

prepare_fade_in_palette_gbc:
    ld      hl, sw_palette_gbc_background
    ld      a, %00000000
    call    bg_get_palette
    ld      hl, sw_palette_gbc_background
    ld      de, palette_dungeon
    call    fade_in_palette_gbc
    ld      hl, sw_palette_gbc_background
    ld      a, 0
    call    bg_set_palette

    ld      hl, sw_palette_gbc_background
    ld      a, %00000000
    call    spr_get_palette
    ld      hl, sw_palette_gbc_background
    ld      de, palette_player
    call    fade_in_palette_gbc
    ld      hl, sw_palette_gbc_background
    ld      a, 0
    call    spr_set_palette

    ret

fade_in_palette_gbc:
    push    de

    ld      a, 4
    ld      [sw_cont], a

.fade_in_palette_gbc_loop_start:
    pop     de
    push    hl
    ld      h, d
    ld      l, e
    ld      a, [hl]
    and     %00011111
    ld      [sw_palette_gbc_red], a
    ld      a, [hl]
    swap    a
    rrc     a
    and     %00000111
    ld      b, a
    inc     hl
    ld      a, [hl]
    swap    a
    rrc     a
    and     %00011000
    or      b
    ld      [sw_palette_gbc_green], a
    ld      a, [hl]
    rrc     a
    rrc     a
    and     %00011111
    ld      [sw_palette_gbc_blue], a
    inc     de
    inc     de
    pop     hl
    push    de

    push    hl
    ld      e, [hl]
    inc     hl
    ld      d, [hl]

    ld      a, e
    cp      %00000000
    jr      nz, .fade_in_palette_gbc_loop
    ld      a, d
    cp      %00000000
    jr      nz, .fade_in_palette_gbc_loop

    jr      .fade_in_palette_gbc_loop_end

.fade_in_palette_gbc_loop:
    ld      a, e
    and     %00011111
    ld      b, a
    ; COMPRUEBA ROJO
    ld      a, [sw_palette_gbc_red]
    cp      b
    jr      z, .fade_in_palette_gbc_loop1 
    dec     e

.fade_in_palette_gbc_loop1:
    push    de
    ld      a, e
    swap    a
    rrc     a
    and     %00000111
    ld      b, a
    ld      a, d
    swap    a
    rrc     a
    and     %00011000
    or      b
    ld      b, a
    ; COMPRUEBA VERDE
    ld      a, [sw_palette_gbc_green]
    cp      b
    pop     de
    jr      z, .fade_in_palette_gbc_loop2 
    ld      a, b
    dec     a
    
    ld      b, a
    swap    a
    rlc     a
    and     %11100000
    ld      c, a
    ld      a, e
    and     %00011111
    or      c
    ld      e, a
    ld      a, b
    rrc     a
    rrc     a
    rrc     a
    and     %00000011
    ld      c, a
    ld      a, d
    and     %11111100
    or      c
    ld      d, a

.fade_in_palette_gbc_loop2:
    rrc     d
    rrc     d
    ld      a, d
    and     %00011111
    ld      b, a
    ; COMPRUEBA AZUL
    ld      a, [sw_palette_gbc_blue]
    cp      b
    jr      z, .fade_in_palette_gbc_loop3
    dec     d

.fade_in_palette_gbc_loop3:
    pop     hl

    rlc     d
    rlc     d

    ld      a, e
    ld      [hl], e
    inc     hl
    ld      a, d
    ld      [hl], d
    inc     hl
    jr      .fade_in_palette_gbc_loop_if

.fade_in_palette_gbc_loop_end:
    pop     hl

    inc     hl
    inc     hl

.fade_in_palette_gbc_loop_if:
    ld      a, [sw_cont]
    dec     a
    ld      [sw_cont], a
    jp      nz, .fade_in_palette_gbc_loop_start

    pop     de

    ret

;o-----------------------------------o
;|          PLAYER MOVEMENT          |
;o-----------------------------------o

player_move:
    ; Si se ha caido al pozo que no se mueva
    ld      a, [sw_player_fall]
    cp      0
    ret     nz

    ld      a, [sw_playmode]        ; Si es modo frontal, no se
    and     %00000001               ; mueve ni arriba ni abajo
    jr      nz, .player_move_right

.player_move_up:
    ld      a, [sw_pad]
    and     PADF_UP
    jr      z, .player_move_down

    ld      a, [sw_player_pos_y]    ; Muevo arriba Posicion real
    dec     a
    ld      [sw_player_pos_y], a

    ld      a, 8
    ld      [_SPR_PLAYER_L_NUM], a
    ld      a, 10
    ld      [_SPR_PLAYER_R_NUM], a

    ld      a, [_SPR_PLAYER_L_ATT]
    and     %11011111
    ld      [_SPR_PLAYER_L_ATT], a

    ld      a, [_SPR_PLAYER_R_ATT]
    and     %11011111
    ld      [_SPR_PLAYER_R_ATT], a

.player_move_down:
    ld      a, [sw_pad]
    and     PADF_DOWN
    jr      z, .player_move_right

    ld      a, [sw_player_pos_y]    ; Muevo abajo Posicion real
    inc     a
    ld      [sw_player_pos_y], a

    ld      a, 0
    ld      [_SPR_PLAYER_L_NUM], a
    ld      a, 2
    ld      [_SPR_PLAYER_R_NUM], a

    ld      a, [_SPR_PLAYER_L_ATT]
    and     %11011111
    ld      [_SPR_PLAYER_L_ATT], a

    ld      a, [_SPR_PLAYER_R_ATT]
    and     %11011111
    ld      [_SPR_PLAYER_R_ATT], a

.player_move_right:
    ld      a, [sw_pad]
    and     PADF_RIGHT
    jr      z, .player_move_left

    ld      a, [sw_player_pos_x]    ; Muevo derecha Posicion real
    inc     a
    ld      [sw_player_pos_x], a

    ld      a, 4
    ld      [_SPR_PLAYER_L_NUM], a
    ld      a, 6
    ld      [_SPR_PLAYER_R_NUM], a

    ld      a, [_SPR_PLAYER_L_ATT]
    and     %11011111
    ld      [_SPR_PLAYER_L_ATT], a

    ld      a, [_SPR_PLAYER_R_ATT]
    and     %11011111
    ld      [_SPR_PLAYER_R_ATT], a

.player_move_left:
    ld      a, [sw_pad]
    and     PADF_LEFT
    jr      z, .player_move_end

    ld      a, [sw_player_pos_x]    ; Muevo izquierda Posicion real
    dec     a
    ld      [sw_player_pos_x], a

    ld      a, 6
    ld      [_SPR_PLAYER_L_NUM], a
    ld      a, 4
    ld      [_SPR_PLAYER_R_NUM], a

    ld      a, [_SPR_PLAYER_L_ATT]
    or      %00100000
    ld      [_SPR_PLAYER_L_ATT], a

    ld      a, [_SPR_PLAYER_R_ATT]
    or      %00100000
    ld      [_SPR_PLAYER_R_ATT], a


.player_move_end: 

    ret

update_sprites:
    ; Player
    ld      a, [_SPR_PLAYER_L_Y]
    ld      [_SPR_PLAYER_R_Y], a    ; posición Y del sprite     
    ld      a, [_SPR_PLAYER_L_X]
    add     a, 8
    ld      [_SPR_PLAYER_R_X], a    ; posición X del sprite

    ; Fireball
    ld      a, [sw_fireball_state]
    bit     4, a
    jr      z, .update_sprites_fireball_end

    ld      a, [rSCY]
    ld      b, a
    ld      a, [sw_fireball_pos_y]
    sub     a, b
    ld      [_SPR_FIREBALL_Y], a

    ld      a, [rSCX]
    ld      b, a
    ld      a, [sw_fireball_pos_x]
    sub     a, b
    ld      [_SPR_FIREBALL_X], a
.update_sprites_fireball_end:

    ld      a, [rSCY]
    ld      b, a
    ld      a, [sw_enemy_pos_y]
    sub     a, b
    ;ld      [_SPR_ENEMY1_L_Y], a
    ;ld      [_SPR_ENEMY1_R_Y], a

    ld      a, [rSCX]
    ld      b, a
    ld      a, [sw_enemy_pos_x]
    sub     a, b
    ;ld      [_SPR_ENEMY1_L_X], a
    add     a, 8
    ;ld      [_SPR_ENEMY1_R_X], a

.update_sprites_end:

    ret

;o-----------------------------------o
;|            PLAYER JUMP            |
;o-----------------------------------o

player_jump:
    ld      a, [sw_playmode]                ; Si no es modo frontal
    and     %00000001                       ; no puede saltar
    jr      nz, .player_jump_modo_f

    ret

.player_jump_modo_f:

    ld      a, [sw_player_jump_state]
    cp      0
    jr      nz, .player_jump_continue       ; Si ya estaba saltando, sigo

    ;ld      a, [sw_player_sensor_land_r]    ; Compruebo si alguno de los dos sensores
    ;cp      0                               ; esta tocando el suelo
    ;jr      nz, .player_jump_start

    ;ld      a, [sw_player_sensor_land_l]
    ;cp      0
    ;jr      nz, .player_jump_start     

    ;ret                                     ; Ninguno, no puedo saltar

.player_jump_start:                         ; Empiezo a saltar
    ld      a, [sw_pad]
    and     PADF_A
    ret     z

    ld      a, 1
    ld      [sw_player_jump_state], a
    ld      a, %00000111
    ld      [sw_player_jump_value_n], a 
    ld      a, %00000101
    ld      [sw_player_jump_value_d], a
    ;ret                                     ; En el primer frame no salto

.player_jump_continue:
    ld      a, [sw_player_jump_value_n]
    and     %00000100
    jr      z, .player_jump_bajando

.player_jump_subiendo:
    ld      a, [sw_player_jump_value_n]
    and     %00000011
    ld      b, a
    ld      a, [sw_player_pos_y]
    sub     b
    ld      [sw_player_pos_y], a

    ld      a, [sw_player_jump_value_d]
    dec     a
    ld      [sw_player_jump_value_d], a
    cp      0
    ret     nz

    ld      a, %00000101
    ld      [sw_player_jump_value_d], a
    ld      a, [sw_player_jump_value_n]
    dec     a
    ld      [sw_player_jump_value_n], a
    and     %00000011
    ret     nz
    
    ld      a, [sw_player_jump_value_n]
    res     2, a
    ld      [sw_player_jump_value_n], a
    ret

.player_jump_bajando:
    ld      a, [sw_player_jump_value_n]
    and     %00000011
    ld      b, a
    ld      a, [sw_player_pos_y]
    add     a, b
    ld      [sw_player_pos_y], a

    ld      a, [sw_player_jump_value_d]
    dec     a
    ld      [sw_player_jump_value_d], a
    cp      0
    ret     nz

    ld      a, %00000101
    ld      [sw_player_jump_value_d], a
    ld      a, [sw_player_jump_value_n]
    cp      3
    ret     z
    inc     a
    ld      [sw_player_jump_value_n], a

    ret

player_jump_reset:
    ld      a, 0
    ld      [sw_player_jump_state], a
    ret

;o-----------------------------------o
;|           PLAYER SHOOT            |
;o-----------------------------------o

player_shoot:
    ld      a, [sw_playmode]                ; Si no es modo aereo
    and     %00000001                       ; no puede disparar
    ret     nz

    ld      a, [sw_fireball_state]
    bit     4, a 
    jp      nz, .player_shoot_update 

.player_shoot_start:
    ld      a, [sw_pad]
    and     PADF_A
    ret     z

    ld      a, 0
    ld      [sw_fireball_frame], a

.player_shoot_up:
    ld      a, _SW_FACE_UP
    ld      b, a
    ld      a, [_SPR_PLAYER_L_NUM]
    cp      b
    jr      nz, .player_shoot_down

    ld      a, [sw_player_pos_y]
    sub     a, 16
    ld      [sw_fireball_pos_y], a

    ld      a, [sw_player_pos_x]
    add     a, 4
    ld      [sw_fireball_pos_x], a

    ld      a, 92
    ld      [_SPR_FIREBALL_NUM], a

    ld      a, [_SPR_FIREBALL_ATT]
    res     5, a
    set     6, a
    ld      [_SPR_FIREBALL_ATT], a

    ld      a, %00010000
    ld      [sw_fireball_state], a
    call    check_fireball

.player_shoot_down:
    ld      a, _SW_FACE_DOWN
    ld      b, a
    ld      a, [_SPR_PLAYER_L_NUM]
    cp      b
    jr      nz, .player_shoot_right

    ld      a, [sw_player_pos_y]
    add     a, 8
    ld      [sw_fireball_pos_y], a

    ld      a, [sw_player_pos_x]
    add     a, 4
    ld      [sw_fireball_pos_x], a

    ld      a, 92
    ld      [_SPR_FIREBALL_NUM], a

    ld      a, [_SPR_FIREBALL_ATT]
    res     5, a
    res     6, a
    ld      [_SPR_FIREBALL_ATT], a

    ld      a, %00010001
    ld      [sw_fireball_state], a
    call    check_fireball

.player_shoot_right:
    ld      a, _SW_FACE_RIGHT
    ld      b, a
    ld      a, [_SPR_PLAYER_L_NUM]
    cp      b
    jr      nz, .player_shoot_left

    ld      a, [sw_player_pos_y]
    ;add     a, 8
    ld      [sw_fireball_pos_y], a

    ld      a, [sw_player_pos_x]
    add     a, 15
    ld      [sw_fireball_pos_x], a

    ld      a, 96
    ld      [_SPR_FIREBALL_NUM], a

    ld      a, [_SPR_FIREBALL_ATT]
    res     5, a
    res     6, a
    ld      [_SPR_FIREBALL_ATT], a

    ld      a, %00010010
    ld      [sw_fireball_state], a
    call    check_fireball

.player_shoot_left:
    ld      a, _SW_FACE_LEFT
    ld      b, a
    ld      a, [_SPR_PLAYER_L_NUM]
    cp      b
    ret     nz

    ld      a, [sw_player_pos_y]
    ;add     a, 8
    ld      [sw_fireball_pos_y], a

    ld      a, [sw_player_pos_x]
    sub     a, 7
    ld      [sw_fireball_pos_x], a

    ld      a, 96
    ld      [_SPR_FIREBALL_NUM], a

    ld      a, [_SPR_FIREBALL_ATT]
    set     5, a
    res     6, a
    ld      [_SPR_FIREBALL_ATT], a

    ld      a, %00010011
    ld      [sw_fireball_state], a
    call    check_fireball

.player_shoot_update:
    ld      a, [sw_fireball_state]
    and     %00000011
    cp      %00000000
    jr      z, .player_shoot_update_up
    cp      %00000001
    jr      z, .player_shoot_update_down
    cp      %00000010
    jr      z, .player_shoot_update_right
    jr      .player_shoot_update_left

.player_shoot_update_up:
    ld      a, [sw_fireball_pos_y]
    sub     a, 2
    ld      [sw_fireball_pos_y], a
    jr      .player_shoot_update_end

.player_shoot_update_down:
    ld      a, [sw_fireball_pos_y]
    add     a, 2
    ld      [sw_fireball_pos_y], a
    jr      .player_shoot_update_end

.player_shoot_update_right:
    ld      a, [sw_fireball_pos_x]
    add     a, 2
    ld      [sw_fireball_pos_x], a
    jr      .player_shoot_update_end

.player_shoot_update_left:
    ld      a, [sw_fireball_pos_x]
    sub     a, 2
    ld      [sw_fireball_pos_x], a

.player_shoot_update_end:
    call    ani_fireball
    call    check_fireball

    ret

check_fireball:
    ld      a, [sw_fireball_pos_x]        
    ld      d, a                        
    ld      a, [sw_fireball_pos_y]
    call    update_pos_tile_next
    ld      [sw_fireball_pos_tile], a

    ld      a, [sw_fireball_pos_x]
    cp      9
    jr      c, .check_fireball_reset
    cp      248
    jr      nc, .check_fireball_reset

    ld      a, [sw_fireball_pos_y]
    cp      9
    jr      c, .check_fireball_reset
    cp      248
    jr      nc, .check_fireball_reset

    ld      hl, sw_collision_map_a
    ld      d, $00                       ; d  -> 00
    ld      a, [sw_fireball_pos_tile]    ; e  -> YX (coordenadas tile)
    ld      e, a                         ; de -> 00XY
    
    add     hl, de

    ld      a, [hl]
    and     %00001111
    ld      hl, sw_player_altura
    cp      [hl]
    ret     nc

.check_fireball_reset:
    call    reset_fireball

    ret

reset_fireball:
    ld      a, 0
    ld      [sw_fireball_pos_y], a
    ld      [sw_fireball_pos_x], a
    ld      [sw_fireball_pos_tile], a
    ld      [sw_fireball_state], a
    ld      [_SPR_FIREBALL_Y], a
    ld      [_SPR_FIREBALL_X], a 

    ret

ani_fireball:
    ld      a, [sw_fireball_frame]
    inc     a
    ld      [sw_fireball_frame], a

    cp      4
    ret     c

    ld      a, 0
    ld      [sw_fireball_frame], a

.ani_fireball_v1:
    ld      a, [_SPR_FIREBALL_NUM]
    cp      92
    jr      nz, .ani_fireball_v2
    ld      a, 94
    ld      [_SPR_FIREBALL_NUM], a
    ret

.ani_fireball_v2:
    cp      94
    jr      nz, .ani_fireball_h1
    ld      a, 92
    ld      [_SPR_FIREBALL_NUM], a
    ret

.ani_fireball_h1:
    cp      96
    jr      nz, .ani_fireball_h2
    ld      a, 98
    ld      [_SPR_FIREBALL_NUM], a
    ret

.ani_fireball_h2:
    cp      98
    ret     nz
    ld      a, 96
    ld      [_SPR_FIREBALL_NUM], a
    ret

;o---------------------------------------o
;| DISPLAY UPDATE + PLAYER SPRITE UPDATE |
;o---------------------------------------o

update_display:
    ld      a, [sw_player_fall]
    cp      0
    jr      nz, .update_display_y_move_bottom

    call    wait_screen_blank
    ld      a, [rSCY]
    ld      [sw_old_scy], a

.update_display_y:
    ld      a, [sw_player_pos_y]            ; PlayerPosY < 72, Display no se mueve
    cp      72 ;$48
    jr      c, .update_display_y_move_top   

    ld      a, [sw_player_pos_y]            ; PlayerPosY >= 184, Display no se mueve
    cp      184 ;$B8
    jr      nc, .update_display_y_move_bottom

    call    wait_screen_blank
    ld      a, [sw_player_pos_y]            ; Else, Display si se mueve
    sub     a, 72 ;$48
    ld      [rSCY], a

    call    wait_screen_blank
    ld      a, 72                           ; Dejar Grafico estatico en la
    ld      [_SPR_PLAYER_L_Y], a                    ; mitad Y del display

    jr      .update_display_x

.update_display_y_move_top:   
    call    wait_screen_blank              
    ld      a, 0
    ld      [rSCY], a

    call    wait_screen_blank
    ld      a, [sw_player_pos_y]            ; Mover Grafico cuando esta
    ld      [_SPR_PLAYER_L_Y], a                    ; en el limite superior del mapa

    jr      .update_display_x

.update_display_y_move_bottom: 
    call    wait_screen_blank
    ld      a, 112 ;$70
    ld      [rSCY], a

    call    wait_screen_blank
    ld      a, [sw_player_pos_y]            ; Mover Grafico cuando esta
    sub     a, 112 ;$70                     ; en el limite inferior del mapa
    ld      [_SPR_PLAYER_L_Y], a

.update_display_x:
    ld      a, [sw_player_pos_x]            ; PlayerPosX < 80, Display no se mueve
    cp      80 ;$50
    jr      c, .update_display_x_move_left

    ld      a, [sw_player_pos_x]            ; PlayerPosX >= 176, Display no se mueve
    cp      176 ;$B0
    jr      nc, .update_display_x_move_right

    call    wait_screen_blank
    ld      a, [sw_player_pos_x]            ; Else, Display si se mueve
    sub     a, 80 ;$50
    ld      [rSCX], a

    call    wait_screen_blank
    ld      a, 80                           ; Dejar Grafico estatico en la
    ld      [_SPR_PLAYER_L_X], a                    ; mitad X del display

    jr      .update_display_end

.update_display_x_move_left:
    call    wait_screen_blank   
    ld      a, 0
    ld      [rSCX], a

    call    wait_screen_blank
    ld      a, [sw_player_pos_x]            ; Mover Grafico cuando esta
    ld      [_SPR_PLAYER_L_X], a                    ; en el limite izquierdo del mapa

    jr      .update_display_end

.update_display_x_move_right: 
    call    wait_screen_blank
    ld      a, 96 ;$60
    ld      [rSCX], a

    call    wait_screen_blank
    ld      a, [sw_player_pos_x]            ; Mover Grafico cuando esta
    sub     a, 96 ;$60                      ; en el limite derecho del mapa
    ld      [_SPR_PLAYER_L_X], a

.update_display_end:

    ret

;o-----------------------------------o
;|    UPDATE PLAYER TILE POSITION    |
;o-----------------------------------o

update_pos_tile:
    ld      a, [sw_player_pos_x]        ; Tile player
    ld      d, a                        ; d -> posX
    ld      a, [sw_player_pos_y]        ; a -> posY
    call    update_pos_tile_next        ; Me devuelve el tile a partir
    ld      [sw_player_pos_tile], a     ; de las posiciones

    ld      a, [sw_player_pos_x]        ; Tile sensor up
    ld      d, a
    ld      a, [sw_player_pos_y]
    sub     a, 8
    call    update_pos_tile_next
    ld      [sw_player_sensor_up], a

    ld      a, [sw_player_pos_x]        ; Tile sensor down
    ld      d, a
    ld      a, [sw_player_pos_y]
    sub     a, 1
    call    update_pos_tile_next
    ld      [sw_player_sensor_down], a

    ld      a, [sw_player_pos_x]        ; Tile sensor right
    add     a, 3 ; Uno menos que left 
    ld      d, a
    ld      a, [sw_player_pos_y]
    sub     a, 4
    call    update_pos_tile_next
    ld      [sw_player_sensor_right], a

    ld      a, [sw_player_pos_x]        ; Tile sensor left
    sub     a, 4
    ld      d, a
    ld      a, [sw_player_pos_y]
    sub     a, 4
    call    update_pos_tile_next
    ld      [sw_player_sensor_left], a

    ld      a, [sw_player_pos_x]        ; Tile sensor land right
    add     a, 3
    ld      d, a
    ld      a, [sw_player_pos_y]
    call    update_pos_tile_next
    ld      [sw_player_sensor_land_r], a

    ld      a, [sw_player_pos_x]        ; Tile sensor land left
    sub     a, 4
    ld      d, a
    ld      a, [sw_player_pos_y]
    call    update_pos_tile_next
    ld      [sw_player_sensor_land_l], a

    ret 

update_pos_tile_next:                        
    and     %11110000           ; Get tileY a partir de posY
    ld      b, a                ; yyyy0000

    ld      a, d                ; Get tileX a partir de posX
    and     %11110000           ; xxxx0000
    swap    a                   ; 0000xxxx <- SWAP

    or      b                   ; yyyyxxxx <- OR

    ret

;o-----------------------------------o
;|            COLLISIONS             |
;o-----------------------------------o

check_collisions:
    call    update_pos_tile
    call    update_altura

    ld      a, [sw_playmode]
    and     %00000001
    jr      nz, .check_collisions_frontal
    jr      .check_collisions_aereo

.check_collisions_frontal:
    ld      hl, sw_collision_map_f
    ld      b, h
    ld      c, l

    jr      .check_collisions_up

.check_collisions_aereo:
    ld      hl, sw_collision_map_a
    ld      b, h
    ld      c, l

.check_collisions_up:                   ; Colisiones sensor up
    ld      h, b
    ld      l, c
    ld      d, $00                       ; d  -> 00
    ld      a, [sw_player_sensor_up]     ; e  -> YX (coordenadas tile)
    ld      e, a                         ; de -> 00XY
    
    add     hl, de

    ld      a, [sw_playmode]
    and     %00000001
    jr      nz, .check_collisions_up_f

.check_collisions_up_a:
    ld      a, [hl]
    swap    a
    and     %00000001
    jr      nz, .check_collisions_up_set

    ld      a, [hl]
    and     %00001111
    ld      hl, sw_player_altura
    cp      [hl]
    jr      z, .check_collisions_down

    jr      .check_collisions_up_set  

.check_collisions_up_f:
    ld      a, [hl]
    swap    a
    and     %00000001
    jr      z, .check_collisions_down

.check_collisions_up_set:
    ld      a, [sw_player_pos_y]        ; Empujamos hacia el lado contrario
    inc     a
    ld      [sw_player_pos_y], a        ; Repetimos con los demas sensores
    jr      check_collisions

.check_collisions_down:                 ; Colisiones sensor down
    ld      h, b
    ld      l, c
    ld      d, $00
    ld      a, [sw_player_sensor_down]
    ld      e, a
    
    add     hl, de

    ld      a, [sw_playmode]
    and     %00000001
    jr      nz, .check_collisions_down_f

.check_collisions_down_a:
    ld      a, [hl]
    swap    a
    and     %00000001
    jr      nz, .check_collisions_down_set

    ld      a, [hl]
    and     %00001111
    ld      hl, sw_player_altura_especial
    cp      [hl]
    jr      z, .check_collisions_right

    jr      .check_collisions_down_set  

.check_collisions_down_f:
    ld      a, [hl]
    swap    a
    and     %00000001
    jr      z, .check_collisions_right

.check_collisions_down_set:
    ld      a, [sw_player_pos_y]
    dec     a
    ld      [sw_player_pos_y], a
    jr      check_collisions

.check_collisions_right:                ; Colisiones sensor right
    ld      h, b
    ld      l, c
    ld      d, $00
    ld      a, [sw_player_sensor_right]
    ld      e, a
    
    add     hl, de

    ld      a, [sw_playmode]
    and     %00000001
    jr      nz, .check_collisions_right_f

.check_collisions_right_a:
    ld      a, [hl]
    swap    a
    and     %00000001
    jr      nz, .check_collisions_right_set

    ld      a, [hl]
    and     %00001111
    ld      hl, sw_player_altura
    cp      [hl]
    jr      z, .check_collisions_left

    jr      .check_collisions_right_set  

.check_collisions_right_f:
    ld      a, [hl]
    swap    a
    and     %00000001
    jr      z, .check_collisions_left

.check_collisions_right_set:
    ld      a, [sw_player_pos_x]
    dec     a
    ld      [sw_player_pos_x], a
    jp      check_collisions

.check_collisions_left:                 ; Colisiones sensor left
    ld      h, b
    ld      l, c
    ld      d, $00
    ld      a, [sw_player_sensor_left]
    ld      e, a
    
    add     hl, de

    ld      a, [sw_playmode]
    and     %00000001
    jr      nz, .check_collisions_left_f

.check_collisions_left_a:
    ld      a, [hl]
    swap    a
    and     %00000001
    jr      nz, .check_collisions_left_set

    ld      a, [hl]
    and     %00001111
    ld      hl, sw_player_altura
    cp      [hl]
    jr      z, .check_collisions_land

    jr      .check_collisions_left_set  

.check_collisions_left_f:
    ld      a, [hl]
    swap    a
    and     %00000001
    jr      z, .check_collisions_land

.check_collisions_left_set:
    ld      a, [sw_player_pos_x]
    inc     a
    ld      [sw_player_pos_x], a
    jp      check_collisions

.check_collisions_land:
    ld      a, [sw_playmode]
    and     %00000001
    ret     z

.check_collisions_land_r:
    ld      h, b
    ld      l, c
    push    hl
    ld      b, 1
    ld      d, $00
    ld      a, [sw_player_sensor_land_r]
    ld      e, a
    
    add     hl, de
    ld      a, [hl]
    swap    a
    and     %00000001
    jr      z, .check_collisions_land_l

    dec     b
    ld      a, [sw_player_pos_y]
    ;dec     a
    ld      [sw_player_pos_y], a

    ld      a, [sw_player_jump_value_n]
    and     %00000100
    call    z, player_jump_reset

    ;jp      check_collisions

.check_collisions_land_l:
    pop     hl
    ld      d, $00
    ld      a, [sw_player_sensor_land_l]
    ld      e, a
    
    add     hl, de
    ld      a, [hl]
    swap    a
    and     %00000001
    jr      z, .check_collisions_noland

    ld      a, [sw_player_pos_y]
    ;dec     a
    ld      [sw_player_pos_y], a

    ld      a, [sw_player_jump_value_n]
    and     %00000100
    call    z, player_jump_reset

    ; Si llega aqui es que los dos sensores detectan suelo
    ld      a, b
    cp      1
    ret     z
    ld      a, [sw_player_pos_y]
    ld      [sw_player_pos_before_jump_y], a
    ld      a, [sw_player_pos_x]
    ld      [sw_player_pos_before_jump_x], a

    ;jp      check_collisions
    ret

.check_collisions_noland:
    ld      a, b
    cp      0
    ret     z

    ld      a, [sw_player_jump_state]
    cp      1
    ret     z

    ;ld      a, [sw_player_sensor_land_r]    ; Compruebo si alguno de los dos sensores
    ;cp      1                               ; esta tocando el suelo
    ;ret     z

    ;ld      a, [sw_player_sensor_land_l]
    ;cp      1
    ;ret     z

    ; Si ninguno esta tocando el suelo, sigo porque me estoy cayendo

    ld      a, 1
    ld      [sw_player_jump_state], a
    ld      a, %00000000
    ld      [sw_player_jump_value_n], a 
    ld      a, %00000101
    ld      [sw_player_jump_value_d], a

    ret


check_door:
    ld      a, [sw_playmode]    ; Cambia de Room solo en modo aereo
    and     %00000001
    ret     nz

    call    update_pos_tile
    call    update_altura

    ld      hl, sw_collision_map_a
    ld      d, $00                     
    ld      a, [sw_player_sensor_down]    
    ld      e, a
    add     hl, de

    ld      a, [hl]
    and     %01100000
    ret     z

    swap    a
    rrc     a
    ld      b, a

    call    choose_room
    call    prepare_room

    ld      a, 1
    ld      [sw_change_room_flag], a

    ret

choose_room:
    cp      1
    jr      nz, .choose_room_retrocede

.choose_room_avanza: ; Si es 1, avanza
    ld      a, [sw_player_room]
    inc     a
    ld      [sw_player_room], a
    ret

.choose_room_retrocede: ; Si es 2, retrocede
    ld      a, [sw_player_room]
    dec     a
    ld      [sw_player_room], a
    ret

prepare_room:
    cp      1
    jr      z, .prepare_room_1
    cp      2
    jr      z, .prepare_room_2
    cp      3
    jr      z, .prepare_room_3

    ; Si llega a aqui es que va a los creditos
    jp      Credits

.prepare_room_1:
    ld      hl, GameMap1Col
    push    hl
    ld      hl, GameMap1

    ld      a, $70
    ld      [sw_player_pos_y], a
    ld      a, $EC
    ld      [sw_player_pos_x], a

    jr      .prepare_room_continue

.prepare_room_2:
    ld      hl, GameMap2Col
    push    hl
    ld      hl, GameMap2

    ld      a, b
    cp      1
    jr      z, .prepare_room_2_avanza

    ld      a, $DD
    ld      [sw_player_pos_y], a
    ld      a, $EC
    ld      [sw_player_pos_x], a

    jr      .prepare_room_continue

.prepare_room_2_avanza:
    ld      a, $7F
    ld      [sw_player_pos_y], a
    ld      a, $18
    ld      [sw_player_pos_x], a

    jr      .prepare_room_continue

.prepare_room_3:
    ld      hl, GameMap3Col
    push    hl
    ld      hl, GameMap3

    ld      a, $DE
    ld      [sw_player_pos_y], a
    ld      a, $14
    ld      [sw_player_pos_x], a

    jr      .prepare_room_continue

.prepare_room_continue:

    call    apaga_LCD

    ld      a, h
    ld      [sw_current_map], a
    ld      a, l
    ld      [sw_current_map+1], a               
    ld      de, _SCRN0
    ld      bc, 32*32
    call    CopiaMemoria

    pop     hl
    ld      de, sw_collision_map_a     
    ld      bc, 16*16
    call    CopiaMemoria

    call    enciende_LCD

    ret

update_health:
    ld      a, [sw_player_health]
    cp      5
    jr      z, .update_health_3h
    jr      nc, .update_health_3f

    ld      a, 45
    jr      .update_health_continue2
.update_health_3f:
    ld      a, 41
    jr      .update_health_continue2
.update_health_3h:
    ld      a, 43

.update_health_continue2:
    ld      [_SPR_HEART3_NUM], a

    ld      a, [sw_player_health]
    cp      3
    jr      z, .update_health_2h
    jr      nc, .update_health_2f

    ld      a, 45
    jr      .update_health_continue1
.update_health_2f:
    ld      a, 41
    jr      .update_health_continue1
.update_health_2h:
    ld      a, 43

.update_health_continue1:
    ld      [_SPR_HEART2_NUM], a

    ld      a, [sw_player_health]
    cp      1
    jr      z, .update_health_1h
    jr      nc, .update_health_1f

    ld      a, 45
    jr      .update_health_end
.update_health_1f:
    ld      a, 41
    jr      .update_health_end
.update_health_1h:
    ld      a, 43

.update_health_end:
    ld      [_SPR_HEART1_NUM], a

    ret

update_enemy:
    ld      a, [sw_enemy_type]
    cp      0
    jr      z, .knight
    jr      .shooter

.knight:

    jr      .update_enemy_params

.shooter:
    ; Calculo dist X entre Player y Enemy
    ld      a, [sw_enemy_pos_x]
    ld      b, a
    ld      a, [sw_player_pos_x]
    call    sub_abs
    ld      d, a

    ; Calculo dist Y entre Player y Enemy
    ld      a, [sw_enemy_pos_y]
    ld      b, a
    ld      a, [sw_player_pos_y]
    call    sub_abs

    cp      d
    jr      c, .shooter_horizontal

.shooter_vertical:
    ld      a, [sw_enemy_pos_y]
    ld      b, a
    ld      a, [sw_player_pos_y]
    cp      b
    jr      nc, .shooter_vertical_s

.shooter_vertical_n:
    ld      a, 0
    jr      .shooter_face_end

.shooter_vertical_s:
    ld      a, 1
    jr      .shooter_face_end

.shooter_horizontal:
    ld      a, [sw_enemy_pos_x]
    ld      b, a
    ld      a, [sw_player_pos_x]
    cp      b
    jr      c, .shooter_horizontal_e

.shooter_horizontal_w:
    ld      a, 2
    jr      .shooter_face_end

.shooter_horizontal_e:
    ld      a, 3
    jr      .shooter_face_end

.shooter_face_end:
    ld      [sw_enemy_facing], a
    jr      .update_enemy_params

.update_enemy_params:
    ld      a, [_SPR_ENEMY1_L_ATT]          ; Quitamos el espejado si lo tiene
    res     5, a
    ld      [_SPR_ENEMY1_L_ATT], a
    ld      [_SPR_ENEMY1_R_ATT], a
    ld      a, [sw_enemy_facing]
    cp      0
    jr      z, .update_enemy_face_up
    cp      1
    jr      z, .update_enemy_face_down
    cp      2
    jr      z, .update_enemy_face_right

    ld      a, [_SPR_ENEMY1_L_ATT]          ; Hacemos espejado porque mira izquierda
    set     5, a
    ld      [_SPR_ENEMY1_L_ATT], a
    ld      [_SPR_ENEMY1_R_ATT], a
    jr      .update_enemy_face_left

.update_enemy_face_up:
    ld      a, 144
    ld      b, 146
    jr      .update_enemy_face_end
.update_enemy_face_down:
    ld      a, 136
    ld      b, 138
    jr      .update_enemy_face_end
.update_enemy_face_right:
    ld      a, 140
    ld      b, 142
    jr      .update_enemy_face_end
.update_enemy_face_left:  
    ld      a, 142
    ld      b, 140
.update_enemy_face_end:
    ld      [_SPR_ENEMY1_L_NUM], a
    ld      a, b
    ld      [_SPR_ENEMY1_R_NUM], a

    ret

; Valor absoluto de una resta:
; a -> n1, b -> n2   |  a -> res, c-> aux
sub_abs:
    cp      b
    jr      nc, .next
    ld      c, b
    ld      b, a
    ld      a, c
.next: 
    sub     b
    ret

check_fall:
    ld      a, [sw_playmode]                ; Si no es modo frontal
    and     %00000001                       ; no tiene que comprobar
    ret     z

    ld      a, [sw_player_fall]
    cp      0
    jr      nz, .check_fall_recover

    ld      a, [sw_player_pos_tile]
    and     %11110000
    cp      $F0
    ret     nz

    ld      a, 1
    ld      [sw_player_fall], a

    ret

.check_fall_recover:
    ld      a, [sw_player_fall_cont]
    inc     a
    ld      [sw_player_fall_cont], a
    cp      64
    jr      nc, .check_fall_recover_finish

    ; Para que se quede ahi abajo el grafico un rato
    ld      a, [sw_player_pos_y]
    cp      20
    ret     nc
    cp      16
    ret     c

    ld      a, 16
    ld      [sw_player_pos_y], a
    ret

.check_fall_recover_finish:
    ld      a, 0
    ld      [sw_player_fall], a
    ld      [sw_player_fall_cont], a

    ld      a, [sw_player_health]
    dec     a
    ld      [sw_player_health], a
    
    ld      a, [sw_player_pos_before_jump_y]
    ld      [sw_player_pos_y], a
    ld      a, [sw_player_pos_before_jump_x]
    ld      [sw_player_pos_x], a

    ret