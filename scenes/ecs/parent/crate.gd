class_name Crate
extends Unit

@onready var _health_component: HealthComponent = $Components/HealthComponent
@onready var _pickup_drop_component: PickupDropComponent = $Components/PickupDropComponent
@onready var _particles_when_hit: GPUParticles3D = $HitParticles
var _is_disabled: bool = false

func _ready():
	_health_component.connect("hit", _is_hit)
	_health_component.connect("killed", _die)

func _is_hit(source: Node3D, amount: int) -> void:
	if _is_disabled:
		return
	_particles_when_hit.restart()
	_particles_when_hit.emitting = true

func _die() -> void:
	if _is_disabled:
		return

	_is_disabled = true
	_pickup_drop_component.disperse_pickup_drops_at_point(global_position)
	queue_free()
