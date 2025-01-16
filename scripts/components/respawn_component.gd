class_name RespawnComponent extends Node

signal respawn_started(respawn_time: float)
signal respawn_completed()

@export var respawn_time: float = 5.0
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

func get_respawn_position() -> Vector2:
	# 获取团队信息
	var team_comp := get_node_or_null("../TeamComponent")
	if not team_comp:
		push_error("RespawnComponent: 找不到 TeamComponent")
		return Vector2.ZERO
	
	# 获取泉水位置
	var arena = get_tree().get_first_node_in_group("arena")
	if not arena:
		push_error("RespawnComponent: 找不到 arena 节点")
		return Vector2.ZERO
		
	var fountain_name = "FountainLeft" if team_comp.team == "left" else "FountainRight"
	var fountain = arena.get_node_or_null(fountain_name)
	if not fountain:
		push_error("RespawnComponent: 找不到泉水节点：" + fountain_name)
		return Vector2.ZERO
		
	return fountain.global_position

func perform_respawn() -> void:
	if not is_dead:
		return
		
	is_dead = false
	
	# 重置位置
	owner.global_position = get_respawn_position()
	
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