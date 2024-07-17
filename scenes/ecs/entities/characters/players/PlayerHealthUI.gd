class_name PlayerHealthUI
extends Control


@export var health_texture_array: Array[TextureRect]
@export var fullHeart: Texture
@export var emptyHeart: Texture
var amountHealth = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	if(health_texture_array.size() != 5):
		print("playerHealthUI is not set correctly")
	change_health(5)

func change_health(amount: int):
	if(amount > 5):
		amount = 5
	elif(amount < 0):
		amount = 0

	for i in range(health_texture_array.size()):
		if(amount <= i):
			health_texture_array[i].texture = emptyHeart
		else:
			health_texture_array[i].texture = fullHeart

