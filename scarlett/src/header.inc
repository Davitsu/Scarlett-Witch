; Davitsu (David Giron) 2015
; Scarlett Witch

	IF	!DEF(HEADER_INC)
HEADER_INC	SET	1

;o-----------------------------------o
;|			   Variables             |
;o-----------------------------------o

	GLOBAL sw_oam_table
	GLOBAL sw_cpu_type
	GLOBAL sw_pad
	GLOBAL sw_playmode
	GLOBAL sw_palette_background

;o-----------------------------------o
;|			   MAIN.ASM              |
;o-----------------------------------o

	GLOBAL Start

;o-----------------------------------o
;|			   GAME.ASM              |
;o-----------------------------------o

	GLOBAL Game

;o-----------------------------------o
;|			 UTILITIES.ASM           |
;o-----------------------------------o

	GLOBAL lee_pad
	GLOBAL memset
	GLOBAL CopiaMemoria
	GLOBAL CopiaMemoriaMapa
	GLOBAL RellenaMemoria

;o-----------------------------------o
;|			   VIDEO.ASM             |
;o-----------------------------------o

	GLOBAL TitleTiles
	GLOBAL EndTitleTiles

	GLOBAL TitleMap
	GLOBAL EndTitleMap

	GLOBAL GameTiles
	GLOBAL EndGameTiles

	GLOBAL GameMap
	GLOBAL EndGameMap

	GLOBAL GameMapCol
	GLOBAL EndGameMapCol

	GLOBAL GameMap2
	GLOBAL EndGameMap2

	GLOBAL palette_dungeon
	GLOBAL palette_player

	GLOBAL apaga_LCD
	GLOBAL enciende_LCD
	GLOBAL wait_screen_blank
	GLOBAL spr_set_palette
	GLOBAL spr_get_palette

	GLOBAL init_OAM
	GLOBAL refresh_OAM
	GLOBAL refresh_custom_OAM

	GLOBAL bg_set_palette
	GLOBAL bg_get_palette

	ENDC	;HEADER_INC