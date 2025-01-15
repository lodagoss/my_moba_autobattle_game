# 此脚本需要在 Godot 编辑器中进行以下配置：
# 1. 在场景中添加以下节点：
#    - Sprite2D (设置合适的基地贴图)
#    - HealthBar (ProgressBar)
#    - HealthComponent (添加 HealthComponent 脚本)
# 2. 确保节点名称与脚本中的 @onready 变量名称一致
# 3. 在检查器中设置以下导出变量：
#    - team: 选择 LEFT 或 RIGHT

class_name BaseBuilding extends UnitBase

enum Team { LEFT, RIGHT }

@export var team: Team

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_comp: HealthComponent = $HealthComponent

const TEAM_COLORS := {
	Team.LEFT: Color(1.0, 0.3, 0.3, 1.0),  # 红色
	Team.RIGHT: Color(0.3, 0.3, 1.0, 1.0)  # 蓝色
}

func _ready() -> void:
	# 从游戏配置中获取基地最大生命值
	var arena = get_tree().get_first_node_in_group("arena")
	if arena and "game_balance" in arena:
		var game_balance = arena.game_balance
		health_comp.max_health = game_balance.base_max_health
	
	# 设置团队颜色
	if sprite:
		sprite.modulate = TEAM_COLORS[team]
	
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
	
	# 基地被摧毁，游戏结束
	var winner_team: int = Team.RIGHT if team == Team.LEFT else Team.LEFT
	GameEvents.game_ended.emit(winner_team)
	print("game ended ", winner_team," has won")
	
	# 禁用碰撞和可见性
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false 