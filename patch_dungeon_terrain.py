import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

# Replace the whole top section up to generate()
old_top = content.split("func generate(")[0]

new_top = """extends RefCounted
class_name DungeonGenerator

# Procedural generator for Stardew Valley-style mine/dungeon floors.
# ИСПОЛЬЗУЕТ GODOT TERRAINS ДЛЯ АВТОТАЙЛИНГА!

# ==============================================================================
# ID ТЕРРЕЙНОВ (ОБЯЗАТЕЛЬНО ПОМЕНЯЙ ИХ НА ТЕ, ЧТО ПОЛУЧИЛИСЬ В ТАЙЛСЕТЕ!)
# ==============================================================================
const TERRAIN_SET_WALLS = 0
const TERRAIN_WALLS = 17 

const TERRAIN_SET_FLOOR = 1
const TERRAIN_FLOOR = 2

const TERRAIN_SET_WATER = 0
const TERRAIN_WATER = 18
# ==============================================================================

const SCENE_LADDER_UP = preload("res://scenes/objects/dungeon/ladder_up.tscn")
const SCENE_LADDER_DOWN = preload("res://scenes/objects/dungeon/ladder_down.tscn")
const SCENE_ORE_ROCK = preload("res://scenes/objects/dungeon/cave_ore_rock.tscn")
const SCENE_TORCH = preload("res://scenes/objects/dungeon/cave_torch.tscn")

const MINABLE_STONES = [
	preload("res://scenes/objects/stones/stone_10.tscn"),
	preload("res://scenes/objects/stones/stone_11.tscn"),
	preload("res://scenes/objects/stones/stone_12.tscn"),
	preload("res://scenes/objects/stones/stone_13.tscn"),
	preload("res://scenes/objects/stones/stone_14.tscn")
]

"""

# Replace the drawing logic inside generate
# We will use python regex or just find the sections.
# It's safer to just rewrite the file fully to avoid matching issues.
