; Davitsu (David Giron) 2015
; Scarlett Witch

INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION	"Video_General",HOME

; Title
TitleTiles:
INCLUDE "font.z80"
EndTitleTiles:

TitleMap:
INCLUDE "title.z80"
EndTitleMap:

; Game
GameTiles:
INCLUDE "gametiles.z80"
EndGameTiles:

GameMap:
INCLUDE "gamemap.z80"
;INCLUDE "mapaprueba1.z80"
;INCLUDE "mapaprueba2.z80"
EndGameMap:

GameMapCol:
INCLUDE "mapaprueba2_col.z80"
EndGameMapCol:

GameMap2:
INCLUDE "gamemap2.z80"
EndGameMap2:

; Paletas GBC
palette_dungeon:
DB $54,$5A,$2B,$35,$06,$20,$02,$10

palette_player:
DB $FF,$7F,$5B,$3E,$5C,$19,$02,$10

apaga_LCD::
    ld      a,[rLCDC]
    rlca                    ; Pone el bit alto de LCDC en el flag de acarreo
    ret     nc              ; La pantalla ya estÃ¡ apagada, volver.

    ; esperamos al VBlank, ya que no podemos apagar la pantalla
    ; en otro momento

.espera_VBlank:
    ld      a, [rLY]
    cp      145
    jr      nz, .espera_VBlank

    ; estamos en VBlank, apagamos el LCD
    ld      a,[rLCDC]       ; en A, el contenido del LCDC
    res     7,a             ; ponemos a cero el bit 7 (activado del LCD)
    ld      [rLCDC],a       ; escribimos en el registro LCDC el contenido de A

    ret                     ; volvemos

enciende_LCD::
	ld 		a, [rLCDC]
	or 		LCDCF_ON
	ld 		[rLCDC], a

	ret

;--------------------------------------------------------------------------
;- wait_screen_blank()                                                    -
;--------------------------------------------------------------------------

wait_screen_blank::

	ld	a,[rSTAT]
	bit	1,a
	jr	nz,wait_screen_blank ; Not mode 0 or 1
	
	ret

SECTION	"Video_Sprites",HOME

;--------------------------------------------------------------------------
;- spr_set_palette()    a = palette number    hl = pointer to data        -
;--------------------------------------------------------------------------
	
spr_set_palette::
	swap a
	rra ; multiply palette by 8
	set	7,a ; auto increment
	ld	[rOCPS],a

	call    wait_screen_blank
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	
	call    wait_screen_blank
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	
	call    wait_screen_blank
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	
	call    wait_screen_blank
	ld	a,[hl+]
	ld	[rOCPD],a
	ld	a,[hl+]
	ld	[rOCPD],a
	
	ret

spr_get_palette::
	ld 		b, 8
	ld 		[rOCPS],a
	
.spr_get_palette_loop:
	call 	wait_screen_blank
	ld		a,[rOCPD]
	ld		[hl+], a
	
	dec 	b
	ret 	z

	ld 		a, [rOCPS]
	inc 	a
	ld 		[rOCPS], a
	jr 		.spr_get_palette_loop


init_OAM::

	ld	bc,__refresh_OAM_end - __refresh_OAM
	ld	hl,__refresh_OAM
	ld	de,refresh_OAM_HRAM
	call CopiaMemoria
	
	ret
	
__refresh_OAM:

	ld  [rDMA],a 
	ld  a,$28      ;delay 200ms
.delay
	dec a
	jr  nz,.delay
	
	ret

__refresh_OAM_end:

;--------------------------------------------------------------------------
;- refresh_OAM()                                                          -
;--------------------------------------------------------------------------
	
refresh_OAM::
	
	ld	a,sw_oam_table >> 8
	jp	refresh_OAM_HRAM

;--------------------------------------------------------------------------
;- refresh_custom_OAM()                                                   -
;--------------------------------------------------------------------------

refresh_custom_OAM::
	jp	refresh_OAM_HRAM

;--------------------------------------------------------------------------
;-                           HRAM VARIABLES                               -
;--------------------------------------------------------------------------

	SECTION	"OAMRefreshFn",HRAM[$FF80]
	
refresh_OAM_HRAM:	DS (__refresh_OAM_end - __refresh_OAM)

SECTION	"Video_Background",HOME
	
;--------------------------------------------------------------------------
;- bg_set_palette()    a = palette number    hl = pointer to data         -
;--------------------------------------------------------------------------
	
bg_set_palette::
	
	swap	a ; \  multiply
	rrca      ; /  palette by 8
	
	set	7,a ; auto increment
	ld	[rBCPS],a
	
	call wait_screen_blank
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	
	call wait_screen_blank
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	
	call wait_screen_blank
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	
	call wait_screen_blank
	ld	a,[hl+]
	ld	[rBCPD],a
	ld	a,[hl+]
	ld	[rBCPD],a
	
	ret

bg_get_palette::
	ld 		b, 8
	ld 		[rBCPS],a
	
.bg_get_palette_loop:
	call 	wait_screen_blank
	ld		a,[rBCPD]
	ld		[hl+], a
	
	dec 	b
	ret 	z

	ld 		a, [rBCPS]
	inc 	a
	ld 		[rBCPS], a
	jr 		.bg_get_palette_loop