extends TextureButton

onready var player: KinematicBody = $"../../../../.."
onready var icon: TextureRect = $Icon
onready var all_skills: Node = $"../../../SkillTrees"
func _ready() -> void:
	switchAttackIcon()
func switchAttackIcon() -> void:
#	if all_skills.necro_switch == true:
#		icon.texture = Icons.base_attack_necromant
#	else:
		match player.weapon_type:
			Icons.weapon_type_list.fist:
				if player.base_atk_duration == false:
					icon.texture = Icons.punch
				else:
					icon.texture = Icons.punch2
			Icons.weapon_type_list.sword:
				if player.base_atk_duration == false:
					icon.texture = Icons.vanguard_icons["base_atk"]
				else:
					icon.texture = Icons.vanguard_icons["base_atk2"]
			Icons.weapon_type_list.dual_swords:
				if player.base_atk_duration == false:
					icon.texture = Icons.vanguard_icons["base_atk"]
				else:
					icon.texture = Icons.vanguard_icons["base_atk2"]
			Icons.weapon_type_list.sword_shield:
				if player.base_atk_duration == false:
					icon.texture = Icons.vanguard_icons["base_atk"]
				else:
					icon.texture = Icons.vanguard_icons["base_atk2"]
			Icons.weapon_type_list.bow:
				icon.texture = Icons.quick_shot
			Icons.weapon_type_list.heavy:
				if player.base_atk_duration == false:
					icon.texture = Icons.vanguard_icons["base_atk"]
				else:
					icon.texture = Icons.vanguard_icons["base_atk2"]
