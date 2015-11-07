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