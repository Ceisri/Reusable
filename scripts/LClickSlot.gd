extends TextureButton

onready var player: KinematicBody = $"../../../../.."
onready var icon: TextureRect = $Icon
onready var all_skills: Node = $"../../../SkillTrees"
func _ready() -> void:
	switchAttackIcon()
func switchAttackIcon() -> void:
	if all_skills.necro_switch == true:
		icon.texture = autoload.base_attack_necromant
	else:
		match player.weapon_type:
			autoload.weapon_type_list.fist:
				if player.base_atk_duration == false:
					icon.texture = autoload.punch
				else:
					icon.texture = autoload.punch2
			autoload.weapon_type_list.sword:
				if player.base_atk_duration == false:
					icon.texture = autoload.vanguard_icons["base_atk"]
				else:
					icon.texture = autoload.vanguard_icons["base_atk2"]
			autoload.weapon_type_list.dual_swords:
				if player.base_atk_duration == false:
					icon.texture = autoload.vanguard_icons["base_atk"]
				else:
					icon.texture = autoload.vanguard_icons["base_atk2"]
			autoload.weapon_type_list.sword_shield:
				if player.base_atk_duration == false:
					icon.texture = autoload.vanguard_icons["base_atk"]
				else:
					icon.texture = autoload.vanguard_icons["base_atk2"]
			autoload.weapon_type_list.bow:
				icon.texture = autoload.quick_shot
			autoload.weapon_type_list.heavy:
				if player.base_atk_duration == false:
					icon.texture = autoload.vanguard_icons["base_atk"]
				else:
					icon.texture = autoload.vanguard_icons["base_atk2"]
