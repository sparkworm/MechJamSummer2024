extends Body
class_name PlayerCharacter

@onready var _fire_point: Node3D = $FirePoint

#Currently used just for pickups but could be used for other features
@onready var _detection_area: Area3D = $DetectionArea

@onready var _attack_component: AttackComponent = $Components/AttackComponent
@onready var _health_component: HealthComponent = $Components/HealthComponent
@onready var _energy_component: EnergyComponent = $Components/EnergyComponent
@onready var _ammo_component: AmmoComponent = $Components/AmmoComponent

@export var _detection_area_radius: float = 10
@export var _obtain_radius: float = 1

func _ready() -> void:
	_detection_area.scale = Vector3(_detection_area_radius, _detection_area_radius, _detection_area_radius)

func _physics_process(delta: float) -> void:

	_handle_movement_input()
	_handle_look_rotation_input()

	if Input.is_action_pressed("Fire"):
		_attack_component.use_primary_attack(self, _fire_point)

	for collision_body: CollisionObject3D in _detection_area.get_overlapping_bodies():
		_on_overlapping_body(collision_body)

func _on_overlapping_body(collision_body: CollisionObject3D) -> void:

	if(collision_body is Pickup):
		_handle_pickup(collision_body as Pickup)

func _handle_movement_input() -> void:
	var input_dir: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var isometric_dir: Vector3 = Vector3(input_dir.x + input_dir.y, 0, input_dir.y - input_dir.x).normalized()

	if isometric_dir.length() > 0:
		_velocity.x = isometric_dir.x * _movement_speed
		_velocity.z = isometric_dir.z * _movement_speed

	else:
		_velocity.x = move_toward(_velocity.x, 0, _movement_speed)
		_velocity.z = move_toward(_velocity.z, 0, _movement_speed)

	velocity = _velocity

	move_and_slide()

func _handle_look_rotation_input() -> void:
	var mouse_pos_3d: Vector3 = MouseUtility.get_mouse_pos_3d()
	TransformUtility.smooth_look_at(self, mouse_pos_3d, _rotation_speed)
	#var mouse_dir: Vector3 = Vector3.FORWARD
	#if mouse_pos_3d:
		#mouse_pos_3d.y = global_position.y
		#mouse_dir = (mouse_pos_3d - global_position).normalized()

func _handle_pickup(pickup: Pickup) -> void:
	pickup.assign_attract_target(primary_collider)
	if(primary_collider.global_transform.origin.distance_to(pickup.global_position) < _obtain_radius):
		var pickup_data: PickupData = pickup.obtain_pickup_data_and_expire()
		if(pickup_data is HealthData):
			var health_data: HealthData = pickup_data as HealthData
			_health_component.heal(health_data.health_amount)
		elif(pickup_data is EnergyData):
			var energy_data: EnergyData = pickup_data as EnergyData
			_energy_component.energy = energy_data.energy_amount
		elif(pickup_data is AmmoData):
			var ammo_data: AmmoData = pickup_data as AmmoData
			_ammo_component.add_ammo(ammo_data)
