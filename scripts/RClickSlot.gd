extends TextureButton


onready var player: KinematicBody = $"../../../../.."
onready var icon: TextureRect = $Icon
onready var necromant: Node = $"../../../SkillTrees/Background/Necromant"

func switchAttackIcon():
	if necromant.necro_switch == true:
		icon.texture = autoload.necro_guard
	else:
		match player.weapon_type:
			"fist":
				icon.texture = autoload.guard
			"sword":
				icon.texture = autoload.guard_sword
			"dual_swords":
				icon.texture = autoload.guard_sword

