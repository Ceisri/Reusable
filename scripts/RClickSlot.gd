extends TextureButton


onready var player: KinematicBody = $"../../../../.."
onready var icon: TextureRect = $Icon
onready var all_skills: Node = $"../../../SkillTrees"

func switchAttackIcon():
#	if all_skills.necro_switch == true:
#		icon.texture = Icons.necro_guard
#	else:
		match player.weapon_type:
			Icons.weapon_type_list.fist:
				icon.texture = Icons.throw_rock
			Icons.weapon_type_list.sword:
					icon.texture = Icons.vanguard_icons["guard_sword"]
			Icons.weapon_type_list.sword_shield:
					icon.texture = Icons.vanguard_icons["guard_shield"]
			Icons.weapon_type_list.dual_swords:
					icon.texture = Icons.vanguard_icons["guard_sword"]
			Icons.weapon_type_list.bow:
				icon.texture = Icons.full_draw
			Icons.weapon_type_list.heavy:
				if player.base_atk_duration == false:
					icon.texture = Icons.vanguard_icons["guard_sword"]

