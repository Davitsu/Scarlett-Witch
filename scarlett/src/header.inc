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
;|			 CREDITS.ASM             |
;o-----------------------------------o

	GLOBAL Credits

;o-----------------------------------o
;|			 UTILITIES.ASM           |
;o-----------------------------------o

	GLOBAL lee_pad
	GLOBAL memset
	GLOBAL memcopy
	GLOBAL memcopy_fast
	GLOBAL CopiaMemoria
	GLOBAL CopiaMemoriaMapa
	GLOBAL RellenaMemoria

;o-----------------------------------o
;|			   VIDEO.ASM             |
;o-----------------------------------o
	GLOBAL TitleBGTiles01
	GLOBAL EndTitleBGTiles01
	GLOBAL TitleBGTiles02
	GLOBAL EndTitleBGTiles02
	GLOBAL TitleBGTiles03
	GLOBAL EndTitleBGTiles03

	GLOBAL TitleBGMap01
	GLOBAL EndTitleBGMap01
	GLOBAL TitleBGMap02
	GLOBAL EndTitleBGMap02

	GLOBAL GameTiles
	GLOBAL EndGameTiles

	GLOBAL GameMap1
	GLOBAL EndGameMap1
	GLOBAL GameMap2
	GLOBAL EndGameMap2
	GLOBAL GameMap3
	GLOBAL EndGameMap3

	GLOBAL GameMap1Col
	GLOBAL EndGameMap1Col
	GLOBAL GameMap2Col
	GLOBAL EndGameMap2Col
	GLOBAL GameMap3Col
	GLOBAL EndGameMap3Col

	GLOBAL palette_dungeon
	GLOBAL palette_player

	GLOBAL CreditsTiles
	GLOBAL EndCreditsTiles
	GLOBAL CreditsMap
	GLOBAL EndCreditsMap

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