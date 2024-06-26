extends TextureButton


onready var player: KinematicBody = $"../../../../.."
onready var icon: TextureRect = $Icon
onready var all_skills: Node = $"../../../SkillTrees"

func switchAttackIcon():
#	if all_skills.necro_switch == true:
#		icon.texture = autoload.necro_guard
#	else:
		match player.weapon_type:
			autoload.weapon_type_list.fist:
				icon.texture = autoload.throw_rock
			autoload.weapon_type_list.sword:
					icon.texture = autoload.vanguard_icons["guard_sword"]
			autoload.weapon_type_list.sword_shield:
					icon.texture = autoload.vanguard_icons["guard_shield"]
			autoload.weapon_type_list.dual_swords:
					icon.texture = autoload.vanguard_icons["guard_sword"]
			autoload.weapon_type_list.bow:
				icon.texture = autoload.full_draw
			autoload.weapon_type_list.heavy:
				if player.base_atk_duration == false:
					icon.texture = autoload.vanguard_icons["guard_sword"]

