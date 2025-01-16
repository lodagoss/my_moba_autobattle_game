# 此脚本需要在 Godot 编辑器中进行以下配置：
# 1. 将此脚本挂载到继承自 StaticBody2D 的场景根节点
# 2. 添加以下子节点：
#    - Sprite2D
#    - CollisionShape2D
#    - HealthComponent（配置 max_health 为 game_balance.tower_max_health）
#    - TeamComponent（配置 team 为 "left" 或 "right"）
#    - CombatComponent（配置 attack_range 为 game_balance.tower_attack_range，
#                     attack_damage 为 game_balance.tower_attack_damage，
#                     attack_speed 为 game_balance.tower_attack_speed）
#    - HealthBar (ProgressBar)
# 3. 将节点添加到 "Building" 组

class_name Tower extends StaticBody2D

# 团队组件属性
@export_enum("left", "right") var team: String = "left"

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_comp: HealthComponent = $HealthComponent
@onready var team_comp: TeamComponent = $TeamComponent
@onready var combat_comp: CombatComponent = $CombatComponent

func _ready() -> void:
	# 添加到建筑组
	add_to_group("Building")
	
	# 设置组件属性
	team_comp.team = team
	
	# 从游戏配置中获取防御塔属性
	var arena = get_tree().get_first_node_in_group("arena")
	if arena and "game_balance" in arena:
		var game_balance = arena.game_balance
		health_comp.max_health = game_balance.tower_max_health
		combat_comp.attack_range = game_balance.tower_attack_range
		combat_comp.attack_damage = game_balance.tower_attack_damage
		combat_comp.attack_speed = game_balance.tower_attack_speed
	
	# 连接信号
	health_comp.health_changed.connect(_on_health_changed)
	health_comp.died.connect(_on_died)

# 生命值变化回调
func _on_health_changed(new_health: float, old_health: float) -> void:
	if health_bar:
		health_bar.value = health_comp.get_health_percent()
	
	var diff = new_health - old_health
	if diff > 0:
		# 治疗事件
		GameEvents.unit_healed.emit(self, diff)
	elif diff < 0:
		# 受伤事件
		GameEvents.unit_damaged.emit(self, -diff, null)

# 死亡回调
func _on_died() -> void:
	# 发送全局死亡事件
	GameEvents.unit_died.emit(self)
	
	# 禁用碰撞和可见性
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false 