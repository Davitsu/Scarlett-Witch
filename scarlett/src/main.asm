;;-----------------------------LICENSE NOTICE------------------------------------
;;  This file is part of Scarlett Witch: A Game Boy and Game Boy Color Game
;;  Copyright (C) 2015 David Giron Jareno (@Davitsu - david.kitsu@gmail.com)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;------------------------------------------------------------------------------

INCLUDE "hardware.inc"
INCLUDE "header.inc"

_STACKTOP       EQU     $FFFE

_SPR0_TITLE_Y    EQU     _RAM
_SPR0_TITLE_X    EQU     _RAM+1
_SPR0_TITLE_NUM  EQU     _RAM+2
_SPR0_TITLE_ATT  EQU     _RAM+3

_SPR1_TITLE_Y    EQU     _RAM+4
_SPR1_TITLE_X    EQU     _RAM+5
_SPR1_TITLE_NUM  EQU     _RAM+6
_SPR1_TITLE_ATT  EQU     _RAM+7

_SPR2_TITLE_Y    EQU     _RAM+8
_SPR2_TITLE_X    EQU     _RAM+9
_SPR2_TITLE_NUM  EQU     _RAM+10
_SPR2_TITLE_ATT  EQU     _RAM+11

_SPR3_TITLE_Y    EQU     _RAM+12
_SPR3_TITLE_X    EQU     _RAM+13
_SPR3_TITLE_NUM  EQU     _RAM+14
_SPR3_TITLE_ATT  EQU     _RAM+15

_SPR4_TITLE_Y    EQU     _RAM+16
_SPR4_TITLE_X    EQU     _RAM+17
_SPR4_TITLE_NUM  EQU     _RAM+18
_SPR4_TITLE_ATT  EQU     _RAM+19

_SPR5_TITLE_Y    EQU     _RAM+20
_SPR5_TITLE_X    EQU     _RAM+21
_SPR5_TITLE_NUM  EQU     _RAM+22
_SPR5_TITLE_ATT  EQU     _RAM+23

_SPR6_TITLE_Y    EQU     _RAM+24
_SPR6_TITLE_X    EQU     _RAM+25
_SPR6_TITLE_NUM  EQU     _RAM+26
_SPR6_TITLE_ATT  EQU     _RAM+27

_SPR7_TITLE_Y    EQU     _RAM+28
_SPR7_TITLE_X    EQU     _RAM+29
_SPR7_TITLE_NUM  EQU     _RAM+30
_SPR7_TITLE_ATT  EQU     _RAM+31

_SPR8_TITLE_Y    EQU     _RAM+32
_SPR8_TITLE_X    EQU     _RAM+33
_SPR8_TITLE_NUM  EQU     _RAM+34
_SPR8_TITLE_ATT  EQU     _RAM+35

_SPR9_TITLE_Y    EQU     _RAM+36
_SPR9_TITLE_X    EQU     _RAM+37
_SPR9_TITLE_NUM  EQU     _RAM+38
_SPR9_TITLE_ATT  EQU     _RAM+39

_SPR10_TITLE_Y   EQU     _RAM+40
_SPR10_TITLE_X   EQU     _RAM+41
_SPR10_TITLE_NUM EQU     _RAM+42
_SPR10_TITLE_ATT EQU     _RAM+43

SECTION "SW_VAR_1", WRAM0

sw_oam_table: DS 160    ; Datos de los Sprite para DMA (40 sprites x 4 bytes = 160)
sw_cpu_type: DS 1       ; CPU (GB = $01, GBC = $11)
sw_pad: DS 1            ; Boton pulsado
sw_start_flag: DS 1
sw_start_fly: DS 1
_is_vbl_flag:   DS 1
VBL_handler:    DS 2
LCD_handler:    DS 2

SECTION "Interrupt Vectors",HOME[$0040]
    
;   SECTION "VBL Interrupt Vector",HOME[$0040]
    push    hl
    ld  hl,_is_vbl_flag
    ld  [hl],1
    jp  change_tiles_up
    
;   SECTION "LCD Interrupt Vector",HOME[$0048]
    push    hl
    ld  hl,LCD_handler
    jp  check_LYC_title
    nop
    nop

SECTION "Cartridge Header",HOME[$0100]
    nop
    jp  Start

    NINTENDO_LOGO

    DB  "SCARLETT WITCH",0 ; 15 bytes
    DB  $C0      ; GBC flag
    DB  0,0,0    ; SGB
    DB  CART_ROM_MBC1 ; CARTTYPE
    DB  0        ; ROMSIZE
    DB  0        ; RAMSIZE
    DB  $01      ; Destination (0 = Japan, 1 = Non Japan)
    DB  $00      ; Manufacturer

    DB  0        ; Version
    DB  0        ; Complement check
    DW  0        ; Checksum

SECTION "Start", HOME[$0150] ; Comienza el programa

Start:
    nop
    di      ; Deshabilita interrupciones

    ld      [sw_cpu_type], a    ; Guardamos la CPU (GB o GBC) 

    ld      sp,$D000 ; Set stack

    ld      hl,_HRAM ; Clear high RAM (and rIE)
    ld      bc,$0080
    ld      d,$00
    call    memset

    ei  

    ;ld      a,$01
    ;ld      [rIE],a ; Enable VBL interrupt

    ld      de,song_data
    ld      bc,BANK(song_data)
    ld      a,$05
    call    gbt_play ; Play song

    ld      sp, _STACKTOP

inicializacion:
    ld      a, [sw_cpu_type]
    cp      $11
    jr      z, .main_gbc_palette
    
.main_gb_palette: ; GB Paletas
    ld      a, %11100100    ; Colores de la paleta
    ld      [rBGP], a       ; Paleta de fondo

    ld      a, %11100100
    ld      [rOBP0], a      ; Paleta de sprites
    ld      a, %11100001
    ld      [rOBP1], a      ; Paleta de sprites

    jr      .main_end_palette

.main_gbc_palette: ; GBC Paletas
    ld      hl, palette_dungeon
    ld      a, 0
    call    bg_set_palette

    ld      hl, palette_player
    ld      a, 0
    call    spr_set_palette

.main_end_palette:

    ld      a, 0
    ld      [sw_start_flag], a
    ld      a, 4
    ld      [sw_start_fly], a

    ld      a, 0            ; Escribimos 0 en los registros de scroll X e Y
    ld      [rSCX], a       ; con lo que posicionamos la pantalla visible
    ld      [rSCY], a       ; al inicio (arriba a la izq) del fondo.

    call    apaga_LCD       ; llamamos a la rutina que apaga el LCD

    call    init_OAM

    ; cargamos los tiles en la memoria de tiles

    ld      hl, TitleBGTiles01          ; cargamos en HL la direcciÃ³n de nuestro tile
    ld      de, $8900               ; en DE direcciÃ³n de la memoria de video
    ld      bc, EndTitleBGTiles01-TitleBGTiles01  ; numero de bytes a copiar

    call    CopiaMemoria

    ld      hl, TitleBGTiles02          ; cargamos en HL la direcciÃ³n de nuestro tile
    ld      de, $8000               ; en DE direcciÃ³n de la memoria de video
    ld      bc, EndTitleBGTiles02-TitleBGTiles02  ; numero de bytes a copiar

    call    CopiaMemoria

    ld      hl, TitleBGMap01
    ld      de, _SCRN0
    ld      bc, 32*12
    call    CopiaMemoriaMapa

    ld      hl, TitleBGMap02
    ld      de, $9980
    ld      bc, 32*6
    call    CopiaMemoriaMapa
 
    ; cargamos el mapa
    ;ld	    hl, TitleMap
    ;ld	    de, _SCRN0		; mapa 0
    ;ld	    bc, 32*32
    ;call    CopiaMemoriaMapa
 
	; bien, tenemos todo el mapa de tiles cargado
	; ahora limpiamos la memoria de sprites
    ld	    de, _OAMRAM		; memoria de atributos de sprites
    ld	    bc, 40*4		; 40 sprites x 4 bytes cada uno
    ld	    l, 0            	; lo vamos a poner todo a cero, asi los sprites
    call    RellenaMemoria	; no usados quedan fuera de pantalla

    ; Inicializamos la tabla de sprites
    ld      hl, sw_oam_table
    ld      bc, $A0
    ld      d, 0
    call    memset

    ld      a, 80
    ld      [_SPR0_TITLE_Y], a
    ld      a, 32
    ld      [_SPR0_TITLE_X], a
    ld      a, 120
    ld      [_SPR0_TITLE_NUM], a
    ld      a, %00000000
    ld      [_SPR0_TITLE_ATT], a

    ld      a, [_SPR0_TITLE_Y]
    ld      [_SPR1_TITLE_Y], a
    ld      a, [_SPR0_TITLE_X]
    add     a, 8
    ld      [_SPR1_TITLE_X], a
    ld      a, 122
    ld      [_SPR1_TITLE_NUM], a
    ld      a, %00000000
    ld      [_SPR1_TITLE_ATT], a

    ld      a, [_SPR0_TITLE_Y]
    ld      [_SPR2_TITLE_Y], a
    ld      a, [_SPR0_TITLE_X]
    add     a, 16
    ld      [_SPR2_TITLE_X], a
    ld      a, 124
    ld      [_SPR2_TITLE_NUM], a
    ld      a, %00010000
    ld      [_SPR2_TITLE_ATT], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 16
    ld      [_SPR3_TITLE_Y], a
    ld      a, [_SPR0_TITLE_X]
    ld      [_SPR3_TITLE_X], a
    ld      a, 126
    ld      [_SPR3_TITLE_NUM], a
    ld      a, %00000000
    ld      [_SPR3_TITLE_ATT], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 16
    ld      [_SPR4_TITLE_Y], a
    ld      a, [_SPR0_TITLE_X]
    add     a, 8
    ld      [_SPR4_TITLE_X], a
    ld      a, 128
    ld      [_SPR4_TITLE_NUM], a
    ld      a, %00000000
    ld      [_SPR4_TITLE_ATT], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 16
    ld      [_SPR5_TITLE_Y], a
    ld      a, [_SPR0_TITLE_X]
    add     a, 16
    ld      [_SPR5_TITLE_X], a
    ld      a, 130
    ld      [_SPR5_TITLE_NUM], a
    ld      a, %00010000
    ld      [_SPR5_TITLE_ATT], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 16
    ld      [_SPR6_TITLE_Y], a
    ld      a, [_SPR0_TITLE_X]
    add     a, 24
    ld      [_SPR6_TITLE_X], a
    ld      a, 132
    ld      [_SPR6_TITLE_NUM], a
    ld      a, %00010000
    ld      [_SPR6_TITLE_ATT], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 32
    ld      [_SPR7_TITLE_Y], a
    ld      a, [_SPR0_TITLE_X]
    sub     a, 8
    ld      [_SPR7_TITLE_X], a
    ld      a, 134
    ld      [_SPR7_TITLE_NUM], a
    ld      a, %00010000
    ld      [_SPR7_TITLE_ATT], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 32
    ld      [_SPR8_TITLE_Y], a
    ld      a, [_SPR0_TITLE_X]
    ld      [_SPR8_TITLE_X], a
    ld      a, 136
    ld      [_SPR8_TITLE_NUM], a
    ld      a, %00010000
    ld      [_SPR8_TITLE_ATT], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 32
    ld      [_SPR9_TITLE_Y], a
    ld      a, [_SPR0_TITLE_X]
    add     a, 8
    ld      [_SPR9_TITLE_X], a
    ld      a, 138
    ld      [_SPR9_TITLE_NUM], a
    ld      a, %00000000
    ld      [_SPR9_TITLE_ATT], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 32
    ld      [_SPR10_TITLE_Y], a
    ld      a, [_SPR0_TITLE_X]
    add     a, 16
    ld      [_SPR10_TITLE_X], a
    ld      a, 140
    ld      [_SPR10_TITLE_NUM], a
    ld      a, %00000000
    ld      [_SPR10_TITLE_ATT], a

    call    refresh_OAM

    ; configuramos y activamos el display
    ld      a, LCDCF_ON|LCDCF_BG8800|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJON
    ld      [rLCDC], a 

    ld  a, 80       ; Cambio de paleta de sprites
    ;ld  a, 95       ; Cambio de tabla de tiles
    ld  [rLYC],a
    
    ld  a,STATF_LYC
    ld  [rSTAT],a
    
    ld  a,0
    ld  [rIF],a
    
    ld  a,$03
    ld  [rIE],a

; bucle principal
main_loop:
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

    call    refresh_OAM

    ld      a, [sw_pad]
    and     PADF_START     
    jp    nz, Game  

    call    title_scarlett_fly
    call    title_update_sprites

    call    gbt_update ; Update player

    ld      a, [rLYC]
    cp      95
    jr      z, .main_loop_end

    ld      a, [_SPR0_TITLE_Y]
    ld      [rLYC],a

.main_loop_end:
    jr      main_loop

title_scarlett_fly:
    ld      a, [sw_start_fly]
    dec     a
    ld      [sw_start_fly], a
    and     %01111111
    ret     nz
    ld      a, [sw_start_fly]
    and     %10000000
    set     2, a
    ld      [sw_start_fly], a
    bit     7, a
    jr      nz, .title_scarlett_fly_down

.title_scarlett_fly_up:
    ld      a, [_SPR0_TITLE_Y]
    dec     a
    ld      [_SPR0_TITLE_Y], a

    cp      70
    jr      z, .title_scarlett_fly_up_slow
    cp      71
    jr      z, .title_scarlett_fly_up_slow
    cp      80
    jr      z, .title_scarlett_fly_up_slow
    jr      .title_scarlett_fly_up_fast

.title_scarlett_fly_up_slow:
    ld      a, [sw_start_fly]
    and     %10000000
    set     3, a
    ld      [sw_start_fly], a

.title_scarlett_fly_up_fast:
    ld      a, [_SPR0_TITLE_Y]
    cp      70
    ret     nz

    ld      a, [sw_start_fly]
    set     7, a
    ld      [sw_start_fly], a
    
    ret

.title_scarlett_fly_down:
    ld      a, [_SPR0_TITLE_Y]
    inc     a
    ld      [_SPR0_TITLE_Y], a

    cp      80
    jr      z, .title_scarlett_fly_down_slow
    cp      79
    jr      z, .title_scarlett_fly_down_slow
    cp      70
    jr      z, .title_scarlett_fly_down_slow
    jr      .title_scarlett_fly_down_fast

.title_scarlett_fly_down_slow:
    ld      a, [sw_start_fly]
    and     %10000000
    set     3, a
    ld      [sw_start_fly], a

.title_scarlett_fly_down_fast:
    ld      a, [_SPR0_TITLE_Y]
    cp      80
    ret     nz

    ld      a, [sw_start_fly]
    and     %10000000
    set     4, a
    ld      [sw_start_fly], a

    ld      a, [sw_start_fly]
    res     7, a
    ld      [sw_start_fly], a
    ret

title_update_sprites:
    ld      a, [_SPR0_TITLE_Y]
    ld      [_SPR1_TITLE_Y], a

    ld      a, [_SPR0_TITLE_Y]
    ld      [_SPR2_TITLE_Y], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 16
    ld      [_SPR3_TITLE_Y], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 16
    ld      [_SPR4_TITLE_Y], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 16
    ld      [_SPR5_TITLE_Y], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 16
    ld      [_SPR6_TITLE_Y], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 32
    ld      [_SPR7_TITLE_Y], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 32
    ld      [_SPR8_TITLE_Y], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 32
    ld      [_SPR9_TITLE_Y], a

    ld      a, [_SPR0_TITLE_Y]
    add     a, 32
    ld      [_SPR10_TITLE_Y], a

    ret

check_LYC_title:
    ld      hl, _SPR0_TITLE_Y
    ld      a, [rLY]
    cp      [hl]
    jr      nz, .change_tiles_down

    ; Cambio la segunda paleta para los sprites
    ld      a, %11010010
    ld      [rOBP1], a

    ; La siguiente interrupcion sera:
    ld  a, 95
    ld  [rLYC],a

    pop     hl
    reti

.change_tiles_down:
    ld      a, [rLY]
    cp      96
    jr      nz, .change_tiles_down

    ; Cambio la tabla de tiles
    ld      a, [rLCDC]
    xor     %00010000
    ld      [rLCDC], a

    ; La siguiente interrupcion sera:
    ld  a, [_SPR0_TITLE_Y]
    ld  [rLYC],a

    pop     hl
    reti

change_tiles_up:
    ; Vuelvo a poner la tabla de tiles original
    ld      a, [rLCDC]
    xor     %00010000
    ld      [rLCDC], a

    ; Vuelvo a poner la segunda paleta original para los sprites
    ld      a, %11100001
    ld      [rOBP1], a

    ld      a, [sw_start_flag]
    inc     a
    bit     5, a
    jr      z, .check_tiles_end
    and     %11000000
    ld      [sw_start_flag], a 

    bit     6, a
    jr      z, .check_tiles_hide_start

.check_tiles_show_start:
    ld      hl, TitleBGTiles03          ; cargamos en HL la direcciÃ³n de nuestro tile
    ld      de, $8430               ; en DE direcciÃ³n de la memoria de video
    ld      b, 96  ; numero de bytes a copiar
    call    memcopy_fast
    inc     hl
    inc     de
    
    ld      a, [sw_start_flag]
    res     6, a
    jr      .check_tiles_end

.check_tiles_hide_start:
    ld      hl, TitleBGTiles02+$430          ; cargamos en HL la direcciÃ³n de nuestro tile
    ld      de, $8430               ; en DE direcciÃ³n de la memoria de video
    ld      b, 96  ; numero de bytes a copiar
    call    memcopy_fast
    inc     hl
    inc     de
    
    ld      a, [sw_start_flag]
    set     6, a

.check_tiles_end:
    ld      [sw_start_flag], a 

    pop     hl
    reti

