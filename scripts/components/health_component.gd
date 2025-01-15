class_name HealthComponent extends Component

signal health_changed(new_health: float, old_health: float)
signal died()

@export var max_health: float = 100.0
var current_health: float

func _on_initialize() -> void:
	current_health = max_health

# 受到伤害
func take_damage(amount: float, _source: UnitBase = null) -> void:
	if not is_enabled():
		return
		
	var old_health := current_health
	current_health = clampf(current_health - amount, 0.0, max_health)
	
	if current_health != old_health:
		health_changed.emit(current_health, old_health)
		
		if current_health <= 0:
			died.emit()

# 治疗
func heal(amount: float) -> void:
	if not is_enabled():
		return
		
	var old_health := current_health
	current_health = clampf(current_health + amount, 0.0, max_health)
	
	if current_health != old_health:
		health_changed.emit(current_health, old_health)

# 获取当前生命值
func get_current_health() -> float:
	return current_health

# 获取最大生命值
func get_max_health() -> float:
	return max_health

# 获取生命值百分比
func get_health_percent() -> float:
	return current_health / max_health * 100.0

# 是否已死亡
func is_dead() -> bool:
	return current_health <= 0.0

# 重置生命值
func reset() -> void:
	var old_health := current_health
	current_health = max_health
	health_changed.emit(current_health, old_health) 