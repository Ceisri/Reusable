extends TextureButton


onready var icon = $Icon
onready var necromant: MarginContainer = $"../../../SkillTrees/Background/Necromant"

func switchAttackIcon():
	if necromant.necro_switch == true:
		icon.texture = autoload.base_attack_necromant
	else:
		icon.texture = autoload.punch
