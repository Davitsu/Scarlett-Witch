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