class_name Level
extends Node3D

#Each game level will incoporate an instance of Level which specifies spawn points and other level specifics

enum AlertStatus
{
	Passive,
	Alerted
}

var _max_enemies = 40
var _current_enemies: Array[EnemyCharacter]

@export var _level_start_point: MeshInstance3D = null
@export var _level_exit_point: Area3D = null
@export var _level_patrol_routes: Array[PatrolRoute]
var _level_alert_status: AlertStatus = AlertStatus.Passive
var _level_objective_collected: bool = false

func level_objective_collected():
	_level_objective_collected = true
	set_level_alert_status(AlertStatus.Alerted)

func _ready() -> void:
	call_deferred("_deferred_ready")

func _physics_process(delta):
	if(level_objective_collected):
		for node3D: CollisionObject3D in _level_exit_point.get_overlapping_bodies():
			if (node3D is PlayerCharacter):
				GameManager.change_to_next_level()

func _deferred_ready():
	for node in get_children():
		if node is EnemyCharacter:
			var enemy: EnemyCharacter = node as EnemyCharacter
			_current_enemies.append(enemy as EnemyCharacter)
			if(_level_alert_status == AlertStatus.Alerted):
				enemy.alert_enemy_to_player()

func add_enemy_to_level(enemy: EnemyCharacter):
	if(_current_enemies.size() >= _max_enemies || _current_enemies.has(enemy)):
		enemy.queue_free()
		return
	else:
		_current_enemies.append(enemy)
		add_child(enemy)
		if(_level_alert_status == AlertStatus.Alerted):
			enemy.alert_enemy_to_player()

func remove_and_free_enemy(enemy: EnemyCharacter):
	if(!_current_enemies.has(enemy)):
		return
	else:
		_current_enemies.erase(enemy)
		enemy.queue_free()

func get_random_level_patrol_route() -> PatrolRoute:
	if _level_patrol_routes.size() == 0:
		return null
	var random_index = randi() % _level_patrol_routes.size()
	return _level_patrol_routes[random_index]

func set_level_alert_status(status: AlertStatus):
	_level_alert_status = status
	if(_level_alert_status == AlertStatus.Passive):
		for enemy: EnemyCharacter in _current_enemies:
			enemy.force_patrol_nav_state()
	if(_level_alert_status == AlertStatus.Alerted):
		for enemy: EnemyCharacter in _current_enemies:
			enemy.alert_enemy_to_player()

func get_level_start_position() -> Vector3:
	return _level_start_point.global_position
