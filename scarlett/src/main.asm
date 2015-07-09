; Davitsu (David Giron) 2015
; Scarlett Witch

INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "SW_VAR_1", WRAM0

sw_cpu_type: DS 1    ; CPU (GB || GBC)
sw_pad: DS 1         ; Boton pulsado

SECTION "Cartridge Header",HOME[$0100]
    nop
    jp  Start

    NINTENDO_LOGO

    ;    0123456789ABCDE
    DB  "SCARLETT WITCH",0 ; 15 bytes
    DB  $C0 ; GBC flag
    DB  0,0,0   ; SGB
    DB  CART_ROM_MBC5 ; CARTTYPE (MBC5)
    DB  0   ; ROMSIZE
    DB  0   ; RAMSIZE

    DB  $01 ; Destination (0 = Japan, 1 = Non Japan)
    DB  $00 ; Manufacturer

    DB  0   ; Version
    DB  0   ; Complement check
    DW  0   ; Checksum

SECTION "Start", HOME[$0150] ; Comienza el programa

Start:
    nop
    di      ; Deshabilita interrupciones

    ld      [sw_cpu_type], a    ; Guardamos la CPU (GB o GBC) 

    ld      sp,$D000 ; Set stack

    ld      a,$01
    ld      [rIE],a ; Enable VBL interrupt

    ld      de,song_data
    ld      bc,BANK(song_data)
    ld      a,$05
    call    gbt_play ; Play song

    ld      sp, $ffff       ; Apuntamos al tope de la ram

inicializacion:

    ld      a, [sw_cpu_type]
    cp      $C0
    jr      z, .main_gbc_palette
    
.main_gb_palette: ; GB Paletas
    ld      a, %00100111    ; Colores de la paleta

    ld      [rBGP], a       ; Paleta de fondo
    ld      [rOBP0], a      ; Paleta de sprites

    jr      z, .main_end_palette

.main_gbc_palette: ; GBC Paletas
    ld      hl, palette_dungeon
    ld      a, 0
    call    bg_set_palette

    ld      hl, palette_player
    ld      a, 0
    call    spr_set_palette

.main_end_palette:

    ld      a, 0            ; Escribimos 0 en los registros de scroll X e Y
    ld      [rSCX], a       ; con lo que posicionamos la pantalla visible
    ld      [rSCY], a       ; al inicio (arriba a la izq) del fondo.

    call    apaga_LCD       ; llamamos a la rutina que apaga el LCD

    ; cargamos los tiles en la memoria de tiles

    ld      hl, TitleTiles		    ; cargamos en HL la direcciÃ³n de nuestro tile
    ld      de, _VRAM			    ; en DE direcciÃ³n de la memoria de video
    ld      bc, EndTitleTiles-TitleTiles  ; numero de bytes a copiar

    call    CopiaMemoria
 
    ; cargamos el mapa
    ld	    hl, TitleMap
    ld	    de, _SCRN0		; mapa 0
    ld	    bc, 32*32
    call    CopiaMemoriaMapa
 
	; bien, tenemos todo el mapa de tiles cargado
	; ahora limpiamos la memoria de sprites
    ld	    de, _OAMRAM		; memoria de atributos de sprites
    ld	    bc, 40*4		; 40 sprites x 4 bytes cada uno
    ld	    l, 0            	; lo vamos a poner todo a cero, asi los sprites
    call    RellenaMemoria	; no usados quedan fuera de pantalla

    ; configuramos y activamos el display
    ld      a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON
    ld      [rLCDC], a

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

    ld      a, [sw_pad]
    and     PADF_START     
    call    nz, Game  

    call    gbt_update ; Update player

    jr      main_loop