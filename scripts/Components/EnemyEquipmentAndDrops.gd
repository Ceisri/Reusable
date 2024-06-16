extends Spatial

export var can_hold_weapon:bool = true
export var species:String = "human"
	
	
	
var item = autoload.bread #the item drops are always PNGs 
var quantity = 1 


var armor
	
func selectRandomEquipment() -> void:
	# Get the enum values
	var torso_values = autoload.torso_list.values()
	# Select a random armor from the enum
	var random_index = randi() % torso_values.size()
	var random_armor = torso_values[random_index]
	print("Selected Random Armor: ", random_armor)
	match random_armor:
		autoload.torso_list.naked:
			equipArmorWeapons(autoload.human_xy_naked_torso_0,"Torso")
			armor = null
		autoload.torso_list.tunic:
			equipArmorWeapons(autoload.human_xy_tunic_0,"Torso")
			armor = autoload.garment1
		autoload.torso_list.gambeson:
			equipArmorWeapons(autoload.human_xy_gambeson_0,"Torso")
			armor = autoload.torso_armor2
		autoload.torso_list.chainmail:
			equipArmorWeapons(autoload.human_xy_chainmail_0,"Torso")
			armor = autoload.torso_armor3
		autoload.torso_list.cuirass:
			equipArmorWeapons(autoload.human_xy_cuirass_0,"Torso")
			armor = autoload.torso_armor4
	
	
onready var owner_entity = $"../.."
var held_weapon = autoload.main_weap_list.axe_beginner
func handWeaponBackWeapon() -> void:#switch weapnons from the back or the sides to the hands
	match held_weapon:
		autoload.main_weap_list.axe_beginner:
			if owner_entity.state == autoload.state_list.engage:
				equipArmorWeapons(autoload.axe_beginner_main_scene,"Weapon")
			else:
				equipArmorWeapons(autoload.axe_beginner_mainB_scene,"Weapon")
	
	
	
func removeEquipment():
	if owner_entity.can_wear_armor == true:
		equipArmorWeapons(autoload.human_xy_naked_torso_0,"Torso")
		equipArmorWeapons(autoload.null_main,"Weapon")
	
	

onready var skeleton: Skeleton = $Armature/Skeleton
func equipArmorWeapons(clothing_to_equip,clothing_type_to_delete:String)->void:
	if clothing_to_equip == null:
		print("Can't equip NULL")
	if !is_instance_valid(clothing_to_equip):
		print("Can't equip INVALID")
	else:
		var clothing_to_equip_instance = clothing_to_equip.instance()
		clothing_to_equip_instance.scale = Vector3(1,1,1) # just in case you can't see the clothing, it might have been resized due to how mixamo works change this between 0.01 to 1 or 100 to test 
		for child in skeleton.get_children():
			if child.is_in_group(clothing_type_to_delete):
				child.queue_free() # this will delete all the armors that share the same group, use names like "Legs, Torso,Hands,Feet"
		skeleton.add_child(clothing_to_equip_instance)


#BUTCHERING/GATHERING
func gather(player,value)->void:#IF THE ENTITY IS A GATHERING ITEM LIKE A TREE OR IF IS A DEAD ENEMY TO BE BUTCHERED
	match owner_entity.is_made_of:
		autoload.gathering_type.furless:
			player.receiveDrops(autoload.steak,value)
			player.receiveDrops(autoload.ribs,value)
			
			



#ON DEATH DROP THESE
func dropItems(player)->void:#FOR AUTOLOOTING
	player.receiveDrops(autoload.bread,quantity)
	
	match held_weapon:
		autoload.main_weap_list.axe_beginner:
			player.receiveDrops(autoload.axe_png,1)
	
	if armor == null:
		pass
	else:
		player.receiveDrops(armor,quantity)
		armor == null
		equipArmorWeapons(autoload.human_xy_naked_torso_0,"Torso")
		
	
func dropItemsLootTable(player)->void: #FOR MANUAL LOOTING 
	player.receiveLootInLootTable(autoload.bread,quantity)
	
	match held_weapon:
		autoload.main_weap_list.axe_beginner:
			player.receiveLootInLootTable(autoload.axe_png,1)
	
	if armor == null:
		pass
	else:
		player.receiveLootInLootTable(armor,quantity)
		armor == null

	
