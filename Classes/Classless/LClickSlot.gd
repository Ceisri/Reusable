extends TextureButton


onready var icon: TextureRect = $Icon
onready var necromant: Node = $"../../../SkillTrees/Background/Necromant"

func switchAttackIcon():
	if necromant.necro_switch == true:
		icon.texture = autoload.base_attack_necromant
	else:
		icon.texture = autoload.punch
