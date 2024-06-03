extends TextureButton


onready var player: KinematicBody = $"../../../../.."
onready var icon: TextureRect = $Icon
onready var all_skills: Node = $"../../../SkillTrees"

func switchAttackIcon():
	if all_skills.necro_switch == true:
		icon.texture = autoload.necro_guard
	else:
		match player.weapon_type:
			autoload.weapon_list.fist:
				icon.texture = autoload.guard
			autoload.weapon_list.sword:
				icon.texture = autoload.guard_sword
			autoload.weapon_list.dual_swords:
				icon.texture = autoload.guard_sword
			autoload.weapon_list.bow:
				icon.texture = autoload.full_draw
			autoload.weapon_list.heavy:
				icon.texture = autoload.cleave
