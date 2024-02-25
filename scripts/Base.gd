extends StaticBody

onready var enemies = get_tree().get_nodes_in_group("Enemy")
var entity_name = "Base"
var aggro_power = 15
var instigator = self 
onready var area =  $Area

func _on_Cycle_timeout():
	var enemies = area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("Enemy"):
			enemy.takeAggro(aggro_power,self)
	
func dealAggro():
	for enemy in enemies:
			enemy.takeDamage(0, 50, self, 0, "slash")
