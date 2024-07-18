extends Area3D


@export var _weapon_index: int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for node3D: Node3D in get_overlapping_bodies():
		if(node3D is PlayerCharacter):
			_pickup_weapon(node3D as PlayerCharacter)
	rotate_y(2 * delta)

func _pickup_weapon(player: PlayerCharacter):
	player.get_weapon(_weapon_index)
	queue_free()
