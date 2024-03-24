extends Control


onready var crafting_slot1 = $CraftingGrid/craftingSlot1
onready var crafting_slot2 = $CraftingGrid/craftingSlot2
onready var crafting_slot3 = $CraftingGrid/craftingSlot3
onready var crafting_slot4 = $CraftingGrid/craftingSlot4
onready var crafting_slot5 = $CraftingGrid/craftingSlot5
onready var crafting_slot6 = $CraftingGrid/craftingSlot6
onready var crafting_slot7 = $CraftingGrid/craftingSlot7
onready var crafting_slot8 = $CraftingGrid/craftingSlot8
onready var crafting_slot9 = $CraftingGrid/craftingSlot9
onready var crafting_slot10 = $CraftingGrid/craftingSlot10
onready var crafting_slot11 = $CraftingGrid/craftingSlot11
onready var crafting_slot12 = $CraftingGrid/craftingSlot12
onready var crafting_slot13 = $CraftingGrid/craftingSlot13
onready var crafting_slot14 = $CraftingGrid/craftingSlot14
onready var crafting_slot15 = $CraftingGrid/craftingSlot15
onready var crafting_slot16 = $CraftingGrid/craftingSlot16

onready var crafting_result = $CraftingResultSlot
onready var icon = $CraftingResultSlot/Icon

onready var item = crafting_result.item 

func craftItemTest():
	mushroomCrafts()
		
func crafting():
	craftItemTest()
	redPotionCraft()

func redPotionCraft():
	if  crafting_slot1.item == "rosehip":
		crafting_result.quantity = 1	
		crafting_result.item = "ground rosehip"
	if crafting_slot16.item == "water":
		if crafting_slot15.item == "beetroot":
			if crafting_slot12.item == "ground rosehip":
				if crafting_slot11.item == "strawberry":
					if crafting_slot1.item == "raspberry":
						crafting_result.quantity = 1	
						crafting_result.item = "red potion"

func mushroomCrafts():
	if crafting_slot1.item == "mushroom 1" and crafting_slot2.item == "mushroom 1":
		crafting_result.quantity = 2
		crafting_result.item = "mushroom 1"
	elif crafting_slot1.item == "mushroom 1" and crafting_slot2.item == "mushroom 2":
		crafting_result.quantity = 1
		crafting_result.item = "mushroom 3"
	elif crafting_slot1.item == "mushroom 2" and crafting_slot2.item == "mushroom 3":
		crafting_result.quantity = 1
		crafting_result.item = "mushroom 4"
	elif crafting_slot1.item == "mushroom 3" and crafting_slot2.item == "mushroom 4":
		crafting_result.quantity = 1
		crafting_result.item = "mushroom 5"
	elif crafting_slot1.item == "mushroom 4" and crafting_slot2.item == "mushroom 5":
		crafting_result.quantity = 1
		crafting_result.item = "mushroom 6"
	elif crafting_slot1.item == "mushroom 5" and crafting_slot2.item == "mushroom 6":
		crafting_result.quantity = 1
		crafting_result.item = "mushroom 7"
	elif crafting_slot1.item == "mushroom 6" and crafting_slot2.item == "mushroom 7":
		crafting_result.quantity = 1
		crafting_result.item = "mushroom 8"
	elif crafting_slot1.item == "mushroom 7" and crafting_slot2.item == "mushroom 8":
		crafting_result.quantity = 1
		crafting_result.item = "mushroom 9"
	elif crafting_slot1.item == "mushroom 8" and crafting_slot2.item == "mushroom 9":
		crafting_result.quantity = 1
		crafting_result.item = "mushroom 10"

# Add more conditions as needed for other combinations

	else:
		crafting_result.item = "empty"	

