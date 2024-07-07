extends CharacterBody3D
class_name Projectile

@export_subgroup("Basic Properties")
@export var _cooldown_time: float = 0.25
@export var _speed: float = 8
@export var _life_time: float = 5
@export var _linger_time: float = 0.25

@export_subgroup("Layer Properties")
@export var _collisional_layers: Array[LayerUtility.Layer] #Layers that this projectile can collide with
@export var _hit_layers: Array[LayerUtility.Layer] #Layers that this projectile can hit

var _collisional_layers_mask: int = 0
var _hit_layers_mask: int = 0
var _source : Node3D = null #Source would be that who emitted the projectile

@onready var _area_3D: Area3D = $Area3D

var isEnabled: bool = true
var hasCollided: bool = false
var hit_targets: Array[Node3D] = []

var cooldown_time: float:
	get:
		return _cooldown_time

func change_velocity(world_direction: Vector3, speed: float) -> void:
	velocity = world_direction * speed

func change_speed(speed: float) -> void:
	velocity = velocity.normalized() * speed

func change_world_direction(world_direction: Vector3) -> void:
	velocity = velocity.length() * world_direction

func change_local_position(pos: Vector3) -> void:
	position = pos

func change_world_position(pos: Vector3) -> void:
	global_position = pos

func look_at_dir(dir: Vector3) -> void:
	Basis.looking_at(dir)

func _ready() -> void:
	_collisional_layers_mask = LayerUtility.get_bitmask_from_bits(_collisional_layers)
	_hit_layers_mask = LayerUtility.get_bitmask_from_bits(_hit_layers)

	await get_tree().create_timer(_life_time).timeout
	_expire()

func init_with_world_direction(source: Node3D, world_start_pos: Vector3, world_direction: Vector3) -> void:
	_source = source
	change_world_position(world_start_pos)
	change_velocity(world_direction, _speed)

func _physics_process(_delta: float) -> void:
	if(!isEnabled):
		return

	move_and_slide()

	#Area3D Collision func
	for collider: CollisionObject3D in _area_3D.get_overlapping_bodies():
		var collisionLayer: int = collider.get_collision_layer()

		#If the projectile can hit: damage, knockback, on hit effect, ect
		if(LayerUtility.check_any_bits_from_bitmask(collisionLayer, _hit_layers_mask)):
			_on_hit(collider)

		#If the projectile can collide: projectile expires and on collision effects
		if(LayerUtility.check_any_bits_from_bitmask(collisionLayer, _collisional_layers_mask)):
			_on_collision(collider)

	#If has collided this frame, expire the projectile
	if(hasCollided):
		_expire()


func _on_hit(collider: CollisionObject3D) -> void:
	for hit_target: Node3D in hit_targets:
		if hit_target == collider:
			return
	hit_targets.append(collider)
	var collisionLayer: int = collider.get_collision_layer()
	print("Has hit: " + LayerUtility.get_layer_name_from_bit(collisionLayer))

	#If the target has health, do damage
	var health_component: HealthComponent = collider.get_node_or_null("Components/HealthComponent") as HealthComponent
	if(health_component != null):
		health_component.damage(_source, 1)

	pass

func _on_collision(collider: CollisionObject3D) -> void:
	var collisionLayer: int = collider.get_collision_layer()
	print("Has collided with: " + LayerUtility.get_layer_name_from_bit(collisionLayer))
	hasCollided = true

func _expire() -> void:
	if(!isEnabled):
		return

	isEnabled = !isEnabled

	#We let the projectile linger for particle system purposes
	await get_tree().create_timer(_linger_time).timeout
	queue_free()
