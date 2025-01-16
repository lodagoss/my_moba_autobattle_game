# 此脚本需要在 Godot 编辑器中进行以下配置：
# 1. 创建一个 Path2D 节点作为根节点，添加此脚本
# 2. 在 Path2D 下添加 PathFollow2D 节点，命名为 "LineFollow"
# 3. 在 LineFollow 下添加：
#    - Sprite2D 节点用于显示兵线，命名为 "LineSprite"
#    - Area2D 节点命名为 "BlockDetector"
#    - 在 Area2D 下添加合适大小的 CollisionShape2D
# 4. 在编辑器中编辑 Path2D 的路径，绘制一条从左方基地到右方基地的路径
# 5. 确保场景根节点（通常是 arena）有 game_balance 属性并设置为 default_balance.tres

class_name CreepLine extends Path2D

var game_balance: GameBalance
var current_offset: float = 0.5  # 当前在路径上的位置(0-1)
var last_offset: float = 0.5  # 上一帧的位置
var movement_direction: int = 0  # -1: 左移, 0: 静止, 1: 右移
var blocking_tower: Node2D = null  # 当前阻挡的塔

var velocity: float = 0.0  # 当前速度
var acceleration: float = 0.0  # 当前加速度

var can_move_left: bool = true  # 是否可以向左移动
var can_move_right: bool = true  # 是否可以向右移动

@onready var line_follow: PathFollow2D = $LineFollow
@onready var block_detector: Area2D = $LineFollow/BlockDetector
@onready var line_sprite: Sprite2D = $LineFollow/LineSprite

func _ready() -> void:
	game_balance = get_tree().get_first_node_in_group("arena").game_balance
	
	# 连接碰撞信号
	block_detector.body_entered.connect(_on_block_detector_body_entered)
	block_detector.body_exited.connect(_on_block_detector_body_exited)
	
	update_line_position()
	update_line_color()

func _physics_process(delta: float) -> void:
	# 更新移动方向
	if velocity > 0:
		movement_direction = 1
	elif velocity < 0:
		movement_direction = -1
	else:
		movement_direction = 0
		
	# 清理已死亡的塔
	if blocking_tower != null:
		var health_comp = blocking_tower.get_node_or_null("HealthComponent")
		if not is_instance_valid(blocking_tower) or (health_comp and health_comp.is_dead()):
			blocking_tower = null
			can_move_left = true
			can_move_right = true
	
	var total_force: float = 0.0
	
	# 获取所有单位
	var units = get_tree().get_nodes_in_group("Hero")
	var buildings = get_tree().get_nodes_in_group("Building")
	
	# 计算所有推力
	for unit in units:
		var health_comp = unit.get_node_or_null("HealthComponent")
		var combat_comp = unit.get_node_or_null("CombatComponent")
		var team_comp = unit.get_node_or_null("TeamComponent")
		
		if health_comp and combat_comp and team_comp and not health_comp.is_dead():
			var distance = unit.global_position.distance_to(line_follow.global_position)
			if distance < combat_comp.attack_range:
				var force = game_balance.creep_line_hero_push_force * (1.0 - distance / combat_comp.attack_range)
				total_force += force * (-1.0 if team_comp.team == "right" else 1.0)
	
	# 计算防御塔的推力
	for building in buildings:
		var health_comp = building.get_node_or_null("HealthComponent")
		var combat_comp = building.get_node_or_null("CombatComponent")
		var team_comp = building.get_node_or_null("TeamComponent")
		
		if health_comp and combat_comp and team_comp and not health_comp.is_dead():
			var distance = building.global_position.distance_to(line_follow.global_position)
			if distance < combat_comp.attack_range:
				var force = game_balance.creep_line_tower_push_force * (1.0 - distance / combat_comp.attack_range)
				var direction = -1.0 if team_comp.team == "right" else 1.0
				total_force += force * direction
	
	# 更新加速度
	acceleration = clamp(total_force * game_balance.creep_line_force_to_acceleration_factor, 
		-game_balance.creep_line_max_acceleration, 
		game_balance.creep_line_max_acceleration)
	
	# 更新速度（受加速度影响）
	velocity += acceleration * delta
	velocity = clamp(velocity, -game_balance.creep_line_max_velocity, game_balance.creep_line_max_velocity)
	
	# 根据速度和移动限制更新位置
	if velocity != 0:
		var movement = velocity * delta
		var can_move := true
		
		# 根据移动方向和限制检查是否可以移动
		if movement < 0 and not can_move_left:  # 想要向左移动但被限制
			can_move = false
		elif movement > 0 and not can_move_right:  # 想要向右移动但被限制
			can_move = false
		
		if can_move:
			last_offset = current_offset  # 保存上一帧的位置
			current_offset = clamp(current_offset + movement, 0.0, 1.0)
			update_line_position()

		update_line_color()

func _on_block_detector_body_entered(body: Node) -> void:
	if body.is_in_group("Building") and body.has_node("CombatComponent"):
		var health_comp = body.get_node_or_null("HealthComponent")
		if health_comp and not health_comp.is_dead():
			blocking_tower = body
			
			# 根据进入时的移动方向设置移动限制
			if current_offset > last_offset:  # 正在向右移动
				can_move_right = false
				can_move_left = true
			else:  # 正在向左移动
				can_move_left = false
				can_move_right = true

func _on_block_detector_body_exited(body: Node) -> void:
	if body == blocking_tower:
		blocking_tower = null
		# 恢复移动限制
		can_move_left = true
		can_move_right = true

func update_line_position() -> void:
	line_follow.progress_ratio = current_offset

func update_line_color() -> void:
	var normalized_velocity = velocity / game_balance.creep_line_max_velocity  # 范围在 -1 到 1 之间
	var color := Color.WHITE
	
	if normalized_velocity > 0:  # 向右移动，变红
		color = Color.WHITE.lerp(Color.RED, normalized_velocity)
	elif normalized_velocity < 0:  # 向左移动，变蓝
		color = Color.WHITE.lerp(Color.BLUE, -normalized_velocity)
	
	line_sprite.modulate = color

# 获取某个点在路径上最近的位置的偏移量
func get_offset_at_point(point: Vector2) -> float:
	var closest_offset := 0.0
	var closest_distance := INF
	var test_points := 100  # 增加测试点数量以提高精度
	
	for i in test_points:
		var offset = float(i) / float(test_points - 1)  # 修正范围为 0 到 1
		var path_point = curve.sample_baked(curve.get_baked_length() * offset)
		var distance = path_point.distance_to(point)
		if distance < closest_distance:
			closest_distance = distance
			closest_offset = offset
	
	return closest_offset
