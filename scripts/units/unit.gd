#此脚本待删除

# 此脚本需要在 Godot 编辑器中进行以下配置：
# 1. 在场景中添加以下节点：
#    - AttackArea (Area2D)
#      - CollisionShape2D
#        - 添加 CircleShape2D 资源到 shape 属性
#    - HealthBar (ProgressBar)
#    - RangeIndicator (Node2D) - 新增
# 2. 确保节点名称与脚本中的 @onready 变量名称一致
# 3. 在检查器中设置以下导出变量：
#    - team: 选择 LEFT 或 RIGHT
#    - unit_type: 选择 HERO, TOWER, BASE
# 4. 如果是英雄单位，将节点添加到 "Hero" 组
# 5. 如果是建筑单位，将节点添加到 "Building" 组
# 6. 在Arena场景中添加两个Marker2D节点：
#    - FountainLeft: 左方泉水位置
#    - FountainRight: 右方泉水位置
# 7. 确保场景根节点（通常是 arena）有 game_balance 属性并设置为 default_balance.tres

class_name Unit extends CharacterBody2D

enum Team { LEFT, RIGHT }
enum UnitType { HERO, TOWER, BASE }

@export var team: Team
@export var unit_type: UnitType

const SPRITE_NODE_NAME := "Sprite2D"  # 所有单位的 Sprite 节点都命名为 "Sprite2D"
const TEAM_COLORS := {
	Team.LEFT: Color(1.0, 0.3, 0.3, 1.0),  # 红色
	Team.RIGHT: Color(0.3, 0.3, 1.0, 1.0)  # 蓝色
}

var current_health: float
var target: Unit = null
var can_attack: bool = true
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_dead: bool = false
var game_balance: GameBalance
var attack_range: float = 0.0  # 添加攻击范围属性

@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: Sprite2D = get_node_or_null(SPRITE_NODE_NAME)
@onready var range_indicator: Node2D = $RangeIndicator

func _ready() -> void:
	# 从场景根节点获取 game_balance
	var arena = get_tree().get_first_node_in_group("arena")
	if not arena or not "game_balance" in arena:
		push_error("Arena node not found or doesn't have game_balance property!")
		return
		
	game_balance = arena.game_balance
	if not game_balance:
		push_error("Game balance resource not assigned in Arena node!")
		return
		
	# 根据单位类型设置属性
	match unit_type:
		UnitType.HERO:
			current_health = game_balance.hero_max_health
			attack_range = game_balance.hero_attack_range
			add_to_group("Hero")
		UnitType.TOWER:
			current_health = game_balance.tower_max_health
			attack_range = game_balance.tower_attack_range
			add_to_group("Building")
		UnitType.BASE:
			current_health = game_balance.base_max_health
			attack_range = 0.0  # 基地没有攻击范围
			add_to_group("Building")
			# 基地不需要攻击区域
			if attack_area:
				attack_area.queue_free()
				attack_area = null
			if range_indicator:
				range_indicator.queue_free()
				range_indicator = null
			return
	
	# 设置攻击范围（仅对英雄和防御塔）
	if attack_area:
		var collision_shape: CollisionShape2D = attack_area.get_node_or_null("CollisionShape2D")
		if collision_shape:
			var circle_shape: CircleShape2D = collision_shape.shape
			if circle_shape:
				circle_shape.radius = attack_range
			else:
				push_error("No CircleShape2D found for: " + name)
		else:
			push_error("No CollisionShape2D found for: " + name)
	else:
		push_error("No AttackArea found for: " + name)
	
	# 设置 Sprite 颜色
	if sprite:
		sprite.modulate = TEAM_COLORS[team]
	
	# 创建攻击范围指示器（仅对英雄和防御塔）
	if range_indicator:
		_update_range_indicator()

func _physics_process(_delta: float) -> void:
	if not game_balance:
		return
		
	update_target()
	if target and can_attack:
		attack()
	
	# 处理移动
	if is_moving and unit_type == UnitType.HERO:
		var direction = (target_position - global_position).normalized()
		velocity = direction * game_balance.hero_move_speed
		move_and_slide()
		
		# 如果到达目标位置附近，停止移动
		if global_position.distance_to(target_position) < 5.0:
			is_moving = false
			velocity = Vector2.ZERO

func update_target() -> void:
	# 基地不需要目标
	if unit_type == UnitType.BASE:
		target = null
		return
		
	var enemies: Array = get_enemies_in_range()
	target = get_priority_target(enemies)

func get_enemies_in_range() -> Array[Unit]:
	var enemies: Array[Unit] = []
	for body in attack_area.get_overlapping_bodies():
		if body is Unit and body.team != team:
			enemies.append(body)
	return enemies

func get_priority_target(enemies: Array[Unit]) -> Unit:
	var hero_target: Unit = null
	var building_target: Unit = null
	
	for enemy in enemies:
		if enemy.is_in_group("Hero"):
			hero_target = enemy
			break
		elif enemy.is_in_group("Building"):
			building_target = enemy
	
	return hero_target if hero_target else building_target

func attack() -> void:
	if not game_balance:
		return
		
	# 基地不能攻击
	if unit_type == UnitType.BASE:
		return
		
	if target:
		var damage := 0.0
		match unit_type:
			UnitType.HERO:
				damage = game_balance.hero_attack_damage
			UnitType.TOWER:
				damage = game_balance.tower_attack_damage
		
		target.take_damage(damage)
		can_attack = false
		
		var attack_speed := 1.0
		match unit_type:
			UnitType.HERO:
				attack_speed = game_balance.hero_attack_speed
			UnitType.TOWER:
				attack_speed = game_balance.tower_attack_speed
				
		await get_tree().create_timer(1.0 / attack_speed).timeout
		can_attack = true

func take_damage(damage: float) -> void:
	if is_dead:
		return
		
	current_health -= damage
	var max_health := 0.0
	match unit_type:
		UnitType.HERO:
			max_health = game_balance.hero_max_health
		UnitType.TOWER:
			max_health = game_balance.tower_max_health
		UnitType.BASE:
			max_health = game_balance.base_max_health
			
	health_bar.value = current_health / max_health * 100
	
	if current_health <= 0:
		die()

func die() -> void:
	is_dead = true
	current_health = 0
	health_bar.value = 0
	
	# 禁用碰撞和可见性
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	
	if is_in_group("Hero"):
		# 英雄会复活
		respawn()
	else:
		# 建筑物直接销毁
		queue_free()

func get_fountain_position() -> Vector2:
	var arena = get_tree().get_first_node_in_group("arena")
	if not arena:
		push_error("Arena not found!")
		return Vector2.ZERO
		
	var fountain_name = "FountainLeft" if team == Team.LEFT else "FountainRight"
	var fountain = arena.get_node_or_null(fountain_name)
	if not fountain:
		push_error("Fountain marker not found: " + fountain_name)
		return Vector2.ZERO
		
	return fountain.global_position

func respawn() -> void:
	if not game_balance:
		return
		
	await get_tree().create_timer(game_balance.hero_respawn_time).timeout
	
	if not is_instance_valid(self):
		return
		
	# 重置状态
	is_dead = false
	current_health = game_balance.hero_max_health
	health_bar.value = 100
	
	# 在泉水位置复活
	global_position = get_fountain_position()
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
	
	# 重置其他状态
	target = null
	can_attack = true
	is_moving = false
	velocity = Vector2.ZERO

func move_to(pos: Vector2) -> void:
	target_position = pos
	is_moving = true

func _process(_delta: float) -> void:
	if range_indicator and game_balance:
		range_indicator.visible = game_balance.show_attack_range_indicator

func _update_range_indicator() -> void:
	if not range_indicator:
		return
		
	# 清除旧的绘制
	range_indicator.queue_redraw()
	
	# 设置绘制方法
	range_indicator.draw.connect(func():
		var radius := 0.0
		match unit_type:
			UnitType.HERO:
				radius = game_balance.hero_attack_range
			UnitType.TOWER:
				radius = game_balance.tower_attack_range
		
		if radius > 0:
			var color := Color(1, 1, 1, 0.1) if team == Team.LEFT else Color(1, 0, 0, 0.1)
			range_indicator.draw_circle(Vector2.ZERO, radius, color)
			range_indicator.draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(color, 0.15))
	)
