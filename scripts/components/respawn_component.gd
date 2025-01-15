class_name RespawnComponent extends Node

signal respawn_started(respawn_time: float)
signal respawn_completed()

@export var respawn_time: float = 5.0
@export var respawn_position: Vector2
var is_dead: bool = false

func _ready() -> void:
	# 连接到 HealthComponent 的死亡信号
	var health_comp := get_node_or_null("../HealthComponent")
	if health_comp and health_comp.has_signal("died"):
		health_comp.died.connect(_on_health_component_died)

func _on_health_component_died() -> void:
	if process_mode == PROCESS_MODE_DISABLED or is_dead:
		return
		
	is_dead = true
	
	# 禁用其他组件
	disable_other_components()
	
	# 开始复活倒计时
	respawn_started.emit(respawn_time)
	await get_tree().create_timer(respawn_time).timeout
	
	if process_mode == PROCESS_MODE_DISABLED:
		return
		
	perform_respawn()

func disable_other_components() -> void:
	for child in owner.get_children():
		if child != self and child.has_method("disable"):
			child.disable()
		elif child != self:
			child.process_mode = PROCESS_MODE_DISABLED

func enable_other_components() -> void:
	for child in owner.get_children():
		if child != self and child.has_method("enable"):
			child.enable()
		elif child != self:
			child.process_mode = PROCESS_MODE_INHERIT

func perform_respawn() -> void:
	if not is_dead:
		return
		
	is_dead = false
	
	# 重置位置
	owner.global_position = respawn_position
	
	# 重置生命值
	var health_comp := get_node_or_null("../HealthComponent")
	if health_comp and health_comp.has_method("reset"):
		health_comp.reset()
	
	# 启用其他组件
	enable_other_components()
	
	respawn_completed.emit()

func disable() -> void:
	process_mode = PROCESS_MODE_DISABLED
	is_dead = false

func enable() -> void:
	process_mode = PROCESS_MODE_INHERIT 