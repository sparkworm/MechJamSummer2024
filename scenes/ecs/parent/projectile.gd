extends CharacterBody3D
class_name Projectile

enum ProjectileState
{
	Inactive,
	Active,
	Lingering,
	Expire,
}

@export_subgroup("Basic Properties")
@export var _cooldown_time: float = 0.25
@export var _speed: float = 8
@export var _life_time: float = 2
@export var _linger_time: float = 0.25

@export_subgroup("Layer Properties")
@export var _collisional_layers: Array[LayerUtility.Layer] #Layers that this projectile can collide with
@export var _hit_layers: Array[LayerUtility.Layer] #Layers that this projectile can hit

var _collisional_layers_mask: int = 0
var _hit_layers_mask: int = 0
var _source : Node3D = null #Source would be that who emitted the projectile

@onready var _detection_area: Area3D = $Area3D
@onready var _timer: Timer = $Timer

var hasCollided: bool = false
var hit_targets: Array[Node3D] = []
var state: ProjectileState = ProjectileState.Inactive

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

	_change_to_active_state()

func init_with_world_direction(source: Node3D, world_start_pos: Vector3, world_direction: Vector3) -> void:
	_source = source
	change_world_position(world_start_pos)
	change_velocity(world_direction, _speed)

func _physics_process(_delta: float) -> void:
	if(state == ProjectileState.Active):
		_handle_active_projectile()

	elif(state == ProjectileState.Lingering):
		_handle_lingering_projectile()

	elif(state == ProjectileState.Expire):
		_handle_expired_projectile()

func _change_to_active_state() -> void:
	state = ProjectileState.Active
	_timer.set_wait_time(_life_time)
	_timer.start()

func _change_to_lingering_state() -> void:
	state = ProjectileState.Lingering
	_timer.set_wait_time(_linger_time)
	_timer.start()

func _change_to_expire_state() -> void:
	state = ProjectileState.Expire

func _handle_active_projectile() -> void:

	for node3D: Node3D in _detection_area.get_overlapping_bodies():
		var collision_Layer: int

		if(node3D is CollisionObject3D):
			var collision_object: CollisionObject3D = node3D as CollisionObject3D
			collision_Layer = collision_object.get_collision_layer()

			#If the projectile can hit: damage, knockback, on hit effect, ect
			if(LayerUtility.check_any_bits_from_bitmask(collision_Layer, _hit_layers_mask)):
				_on_hit(node3D as CollisionObject3D)

		elif(node3D is GridMap):
			var grid_map: GridMap = node3D as GridMap
			collision_Layer = grid_map.get_collision_layer()

		#If the projectile can collide: projectile expires and on collision effects
		if(LayerUtility.check_any_bits_from_bitmask(collision_Layer, _collisional_layers_mask)):
			_on_collision(node3D)

	#If has collided or timed out this frame, change state to lingering
	if(hasCollided || _timer.is_stopped()):
		_change_to_lingering_state()

	move_and_slide()
	return

func _handle_lingering_projectile() -> void:
	if(_timer.is_stopped()):
		_change_to_expire_state()

func _handle_expired_projectile() -> void:
	queue_free()
	state = ProjectileState.Inactive

func _on_hit(collider: CollisionObject3D) -> void:
	for hit_target: Node3D in hit_targets:
		if hit_target == collider:
			return
	hit_targets.append(collider)

	#Debug
	var collisionLayer: int = collider.get_collision_layer()
	print("Projectile has hit: " + LayerUtility.get_layer_name_from_bit(collisionLayer))

	#If the target has health, do damage
	var health_component: HealthComponent = collider.get_node_or_null("Components/HealthComponent") as HealthComponent
	if(health_component != null):
		health_component.damage(_source, 1)

	pass

func _on_collision(collider: Node3D) -> void:

	#Debug
	var collisionLayer: int = collider.get_collision_layer()
	print("Projectile has collided with: " + LayerUtility.get_layer_name_from_bit(collisionLayer))

	hasCollided = true
