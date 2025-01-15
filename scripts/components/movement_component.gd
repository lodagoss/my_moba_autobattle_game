class_name MovementComponent extends Node

signal movement_started(target_position: Vector2)
signal movement_completed()

@export var move_speed: float = 100.0
var target_position: Vector2
var is_moving: bool = false

func move_to(position: Vector2) -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return
		
	target_position = position
	is_moving = true
	movement_started.emit(target_position)

func _physics_process(_delta: float) -> void:
	if process_mode == PROCESS_MODE_DISABLED or not is_moving:
		return
		
	var owner_body := owner as CharacterBody2D
	if not owner_body:
		push_error("MovementComponent的拥有者必须是CharacterBody2D类型")
		return
		
	var direction = (target_position - owner_body.global_position).normalized()
	owner_body.velocity = direction * move_speed
	owner_body.move_and_slide()
	
	# 如果到达目标位置附近，停止移动
	if owner_body.global_position.distance_to(target_position) < 5.0:
		stop_movement()

func stop_movement() -> void:
	if not is_moving:
		return
		
	is_moving = false
	var owner_body := owner as CharacterBody2D
	if owner_body:
		owner_body.velocity = Vector2.ZERO
	movement_completed.emit()

func disable() -> void:
	process_mode = PROCESS_MODE_DISABLED
	stop_movement()

func enable() -> void:
	process_mode = PROCESS_MODE_INHERIT 