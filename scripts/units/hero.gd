# 此脚本需要在 Godot 编辑器中进行以下配置：
# 1. 将此脚本挂载到继承自 CharacterBody2D 的场景根节点
# 2. 添加以下子节点：
#    - Sprite2D
#    - CollisionShape2D
#    - HealthComponent
#    - TeamComponent（配置 team 为 "left" 或 "right"）
#    - MovementComponent
#    - RespawnComponent
#    - SkillComponent
#    - StatusComponent
#    - HealthBar (ProgressBar)
# 3. 将节点添加到 "Hero" 组

class_name Hero extends CharacterBody2D

@export var hero_data: HeroData
@export_enum("left", "right") var team: String = "left"

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_comp: HealthComponent = $HealthComponent
@onready var team_comp: TeamComponent = $TeamComponent
@onready var movement_comp: MovementComponent = $MovementComponent
@onready var respawn_comp: RespawnComponent = $RespawnComponent
@onready var skill_comp: SkillComponent = $SkillComponent
@onready var status_comp: StatusComponent = $StatusComponent

func _ready() -> void:
	# 检查必要组件
	if not health_bar:
		push_error("Hero: 缺少 HealthBar 节点")
		return
	if not health_comp:
		push_error("Hero: 缺少 HealthComponent 节点")
		return
	if not team_comp:
		push_error("Hero: 缺少 TeamComponent 节点")
		return
	if not movement_comp:
		push_error("Hero: 缺少 MovementComponent 节点")
		return
	if not respawn_comp:
		push_error("Hero: 缺少 RespawnComponent 节点")
		return
	if not skill_comp:
		push_error("Hero: 缺少 SkillComponent 节点")
		return
	if not status_comp:
		push_error("Hero: 缺少 StatusComponent 节点")
		return
	if not hero_data:
		push_error("Hero: 缺少 HeroData 资源")
		return
	
	# 添加到英雄组
	add_to_group("Hero")
	
	# 设置组件属性
	team_comp.team = team
	
	# 从英雄数据中设置属性
	health_comp.max_health = hero_data.max_health
	health_comp.current_health = hero_data.max_health
	movement_comp.move_speed = hero_data.move_speed
	respawn_comp.respawn_time = hero_data.respawn_time
	
	# 添加技能
	for skill in hero_data.create_skills():
		skill_comp.add_skill(skill)
	
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

# 移动到指定位置
func move_to(target_position: Vector2) -> void:
	if movement_comp:
		movement_comp.move_to(target_position)

# 使用技能
func cast_skill(skill_name: String, target: Node2D) -> void:
	if skill_comp:
		skill_comp.try_cast_skill(skill_name, target)
