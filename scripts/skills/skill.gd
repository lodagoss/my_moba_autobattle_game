class_name Skill
extends RefCounted

var skill_name: String
var cooldown: float
var skill_range: float
var damage: float
var owner_unit: Node2D
var skill_component: Node

var _is_cooling_down: bool = false
var _cooldown_timer: Timer

func _init(p_skill_name: String, p_cooldown: float, p_range: float, p_damage: float) -> void:
	skill_name = p_skill_name
	cooldown = p_cooldown
	skill_range = p_range
	damage = p_damage
	
	# 创建冷却计时器
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(_on_cooldown_finished)

# 虚函数：检查是否可以释放技能
func can_cast() -> bool:
	if not owner_unit or not is_instance_valid(owner_unit):
		return false
	return not _is_cooling_down

# 虚函数：释放技能
func cast(target: Node2D) -> bool:
	if not can_cast():
		return false
		
	if not _validate_target(target):
		return false
		
	_start_cooldown()
	return true

# 验证目标
func _validate_target(target: Node2D) -> bool:
	if not target or not is_instance_valid(target):
		return false
		
	if not target.has_node("HealthComponent"):
		return false
		
	var distance := owner_unit.global_position.distance_to(target.global_position)
	return distance <= skill_range

# 开始冷却
func _start_cooldown() -> void:
	_is_cooling_down = true
	if not _cooldown_timer.is_inside_tree():
		owner_unit.add_child(_cooldown_timer)
	_cooldown_timer.start(cooldown)

# 冷却结束
func _on_cooldown_finished() -> void:
	_is_cooling_down = false 
