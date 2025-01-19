class_name StatusComponent extends Node

signal status_added(status_name: String, duration: float)
signal status_removed(status_name: String)

# 状态字典，键为状态名称，值为Timer
var _active_statuses: Dictionary = {}

func _ready() -> void:
	pass

# 添加状态效果
func add_status(status_name: String, duration: float) -> void:
	# 如果状态已存在，刷新持续时间
	if status_name in _active_statuses:
		var existing_timer: Timer = _active_statuses[status_name]
		existing_timer.start(duration)
		return
	
	# 创建新的计时器
	var timer := Timer.new()
	timer.one_shot = true
	timer.timeout.connect(func(): _remove_status(status_name))
	add_child(timer)
	
	# 存储并启动计时器
	_active_statuses[status_name] = timer
	timer.start(duration)
	
	# 应用状态效果
	_apply_status_effect(status_name, true)
	status_added.emit(status_name, duration)

# 移除状态效果
func _remove_status(status_name: String) -> void:
	if not status_name in _active_statuses:
		return
	
	# 获取并清理计时器
	var timer: Timer = _active_statuses[status_name]
	timer.queue_free()
	_active_statuses.erase(status_name)
	
	# 移除状态效果
	_apply_status_effect(status_name, false)
	status_removed.emit(status_name)

# 检查状态是否存在
func has_status(status_name: String) -> bool:
	return status_name in _active_statuses

# 应用状态效果
func _apply_status_effect(status_name: String, is_apply: bool) -> void:
	match status_name:
		"stunned":
			_apply_stun(is_apply)
		# 在这里添加更多状态效果的处理

# 处理晕眩效果
func _apply_stun(is_stunned: bool) -> void:
	# 获取需要禁用/启用的组件
	var movement_comp := get_parent().get_node_or_null("MovementComponent")
	var skill_comp := get_parent().get_node_or_null("SkillComponent")
	
	# 禁用/启用移动和技能
	if movement_comp:
		if is_stunned:
			movement_comp.disable()
		else:
			movement_comp.enable()
	
	if skill_comp:
		if is_stunned:
			skill_comp.disable()
		else:
			skill_comp.enable() 