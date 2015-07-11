; Davitsu (David Giron) 2015
; Scarlett Witch

INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION	"JoypadHandler",HOME

lee_pad::
    ; vamos a leer la cruzeta:
    ld      a, %00100000    ; bit 4 a 0, bit 5 a 1 (cruzeta activada, botones no)
    ld      [rP1], a

    ; ahora leemos el estado de la cruzeta, para evitar el bouncing
    ; hacemos varias lecturas
    ld      a, [rP1]
    ld      a, [rP1]
    ld      a, [rP1]
    ld      a, [rP1]

    and     $0F             ; solo nos importan los 4 bits de abajo.
    swap    a               ; intercambiamos parte baja y alta.
    ld      b, a            ; guardamos el estado de la cruzeta en b

    ; vamos a por los botones
    ld      a, %00010000    ; bit 4 a 1, bit 5 a 0 (botones activados, cruzeta no)
    ld      [rP1], a

    ; leemos varias veces para evitar el bouncing
    ld      a, [rP1]
    ld      a, [rP1]
    ld      a, [rP1]
    ld      a, [rP1]

    ; tenemos en A, el estado de los botones
    and     $0F             ; solo nos importan los 4 bits de abajo.
    or      b               ; hacemos un or con b, para "meter" en la parte
                            ; superior de A, el estado de la cruzeta.

    ; ahora tenemos en A, el estado de todo, hacemos el complemento y
    ; lo guardamos en la variable
    cpl
    ld      [sw_pad], a
    ; volvemos
    ret

SECTION	"Utilities",HOME

; rutina de copia a memoria
; copia un numero de bytes de una direccion a otra
; espera los parámetros:
; hl - dirección de datos a copiar
; de - dirección de destino
; bc - numero de datos a copiar
; destruye el contenido de A
CopiaMemoria::
    ld	    a, [hl]	; cargamos el dato en A
    ld	    [de], a	; copiamos el dato al destino
    dec	    bc		; uno menos por copiar
    ; comprobamos si bc es cero
    ld	    a, c
    or	    b
    ret	    z		; si es cero, volvemos
    ; si no, seguimos
    inc	    hl
    inc	    de
    jr	    CopiaMemoria

CopiaMemoriaMapa::
    ld	    a, [hl]		; cargamos el dato en A
    ld	    [de], a		; copiamos el dato al destino
    dec	    bc		; uno menos por copiar
    jr	    .copia_memoria_mapa_seguir

.copia_memoria_mapa_blanco:
    ld	    a, 0		; cargamos el dato en A
    ld	    [de], a		; copiamos el dato al destino
    dec	    bc		; uno menos por copiar

.copia_memoria_mapa_seguir:
    ; comprobamos si bc es cero
    ld	    a, c
    or	    b
    ret	    z		; si es cero, volvemos
    ; si no, seguimos
    
    ; comprobamos si estamos fuera de lo 20x18
    ld	    a, c
    and	    %00011111
    cp	    $0D
    jr	    c, .copia_memoria_mapa_fuera

    ;si no, seguimos
.copia_memoria_mapa_dentro:
    inc	    hl
    inc	    de
    jr	    CopiaMemoriaMapa

.copia_memoria_mapa_fuera:
    ld	    a, c
    and	    %00001111
    jr	    z, .copia_memoria_mapa_dentro

    inc	    de
    jr	    .copia_memoria_mapa_blanco

; rutina de relleno de memoria
; rellena un numero de bytes de memoria con un dato
; espera los parámetros:
; de - direccion de destino
; bc - número de datos a rellenar
; l - dato a rellenar
RellenaMemoria::
    ld	    a, l
    ld	    [de], a	; mete el dato en el destino
    dec	    bc		; uno menos a rellenar
    
    ld	    a, c		
    or	    b		; comprobamos si bc es cero
    ret	    z		; si es cero volvemos
    inc	    de		; si no, seguimos
    jr	    RellenaMemoria