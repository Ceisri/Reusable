extends TextureButton


onready var player: KinematicBody = $"../../../../.."
onready var icon: TextureRect = $Icon
onready var necromant: Node = $"../../../SkillTrees/Background/Necromant"

func switchAttackIcon():
	if necromant.necro_switch == true:
		icon.texture = autoload.necro_guard
	else:
		match player.weapon_type:
			player.fist:
				icon.texture = autoload.guard
			player.sword:
				icon.texture = autoload.guard_sword
			player.dual_swords:
				icon.texture = autoload.guard_sword
			player.bow:
				icon.texture = autoload.full_draw
