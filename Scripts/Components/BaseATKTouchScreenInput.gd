extends TouchScreenButton


func switchAttackIcon(player) -> void:
	match  player.skills.selected_element:
		"lightning":
			icon.texture = Icons.lighting_shot
		"fire":
			icon.texture = Icons.fireball
		"ice":
			icon.texture = Icons.icile_scatter_shot
		"shadow":
			icon.texture = Icons.arcane_bolt
		"wind":
			icon.texture = Icons.razor_wind_shield
		"none":
			icon.texture = null

onready var icon =  $IconBaseATK

