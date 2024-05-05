extends Spatial

var player 
onready var animation = $AnimationPlayer

func _ready():
	player.animation = animation





#_____________________________________Equipment 3D______________________________

func EquipmentSwitch():
	switchHead()
	switchTorso()
	switchBelt()
	switchLegs()
	switchHandL()
	switchHandR()
	
	
	
func switchHead():
	var head0 = null
	var head1 = null
	match player.head:
		"naked":
			player.applyEffect(self,"helm1", false)
		"garment1":
			player.applyEffect(self,"helm1", true)
func switchTorso():
	var torso0 = $Armature/Skeleton/torso0
	var torso1 = $Armature/Skeleton/torso1
	if torso0 != null:
		if torso1 != null:
			match player.torso:
				"naked":
					torso0.visible = true 
					torso1.visible = false
					player.applyEffect(self,"garment1", false)
				"garment1":
					torso0.visible = false
					torso1.visible = true
					player.applyEffect(self,"garment1", true)
func switchBelt():
	match player.belt:
		"naked":
			player.applyEffect(self,"belt1", false)
		"belt1":
			player.applyEffect(self,"belt1", true)

func switchLegs():
	var legs0 = $Armature/Skeleton/legs0
	var legs1 = $Armature/Skeleton/legs1
	if legs0 != null:
		if legs1 != null:
			match player.legs:
				"naked":
					legs0.visible = true 
					legs1.visible = false
					player.applyEffect(self,"pants1", false)
					
				"cloth1":
					legs0.visible = false
					legs1.visible = true	
					player.applyEffect(self,"pants1", true)
			
func switchHandL():
	var hand_l0 = null
	var hand_l1 = null
	match player.hand_l:
		"naked":
			player.applyEffect(self,"Lhand1", false)
		"cloth1":
			player.applyEffect(self,"Lhand1", true)
func switchHandR():
	var hand_r0 = null
	var hand_r1 = null
	match player.hand_r:
		"naked":
			player.applyEffect(self,"Rhand1", false)
		"cloth1":
			player.applyEffect(self,"Rhand1", true)
