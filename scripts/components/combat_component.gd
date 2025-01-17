class_name CombatComponent extends Node2D

signal target_acquired(target: Node2D)
signal target_lost()
signal attack_started(target: Node2D)
signal attack_completed(target: Node2D)

@export var auto_attack: bool = true  # 是否自动攻击最近的目标
@export var attack_damage: float = 10.0
@export var attack_range: float = 100.0
@export var attack_speed: float = 1.0  # 每秒攻击次数

var target: Node2D = null
var can_attack: bool = true
@onready var attack_area: Area2D = $AttackArea
@onready var team_comp: TeamComponent = $"../TeamComponent"

func _ready() -> void:
	if not attack_area:
		push_error("CombatComponent需要一个名为AttackArea的Area2D子节点")
		return
		
	if not team_comp:
		push_error("CombatComponent需要一个同级的TeamComponent节点")
		return
		
	# 设置攻击范围
	var collision_shape := attack_area.get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = attack_range
	else:
		push_error("AttackArea缺少CircleShape2D或CollisionShape2D")
	
	# 连接信号
	attack_area.body_entered.connect(_on_body_entered)
	attack_area.body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return
		
	if auto_attack and (not target or not is_instance_valid(target)):
		find_nearest_target()
		
	if target and can_attack:
		perform_attack()

func _on_body_entered(body: Node2D) -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return
		
	if can_attack_target(body):
		if not auto_attack:
			set_target(body)
		elif not target:  # 如果是自动攻击且当前没有目标，寻找最近的目标
			find_nearest_target()

func _on_body_exited(body: Node2D) -> void:
	if body == target:
		clear_target()
		if auto_attack:  # 如果目标离开范围，自动寻找新目标
			find_nearest_target()

func can_attack_target(potential_target: Node2D) -> bool:
	# 检查目标是否有必要的组件
	if not potential_target.has_node("TeamComponent") or not potential_target.has_node("HealthComponent"):
		return false
	# 检查目标是否是敌人
	return team_comp.is_enemy(potential_target)

func find_nearest_target() -> void:
	var bodies := attack_area.get_overlapping_bodies()
	var nearest_target: Node2D = null
	var nearest_distance: float = INF
	var owner_position: Vector2 = get_parent().global_position
	
	for body in bodies:
		if can_attack_target(body):
			var distance: float = owner_position.distance_squared_to(body.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_target = body
	
	if nearest_target != target:
		set_target(nearest_target)

func set_target(new_target: Node2D) -> void:
	if target == new_target:
		return
		
	target = new_target
	if target:
		target_acquired.emit(target)
	else:
		target_lost.emit()

func clear_target() -> void:
	set_target(null)

func perform_attack() -> void:
	if not target or not can_attack:
		return
		
	can_attack = false
	attack_started.emit(target)
	
	# 获取目标的 HealthComponent
	var health_comp: HealthComponent = target.get_node_or_null("HealthComponent")
	if health_comp:
		health_comp.take_damage(attack_damage, get_parent())
	else:
		push_error("目标缺少HealthComponent: " + target.name)
	
	attack_completed.emit(target)
	
	# 设置攻击冷却
	await get_tree().create_timer(1.0 / attack_speed).timeout
	can_attack = true

func disable() -> void:
	process_mode = PROCESS_MODE_DISABLED
	clear_target()
	can_attack = false

func enable() -> void:
	process_mode = PROCESS_MODE_INHERIT
	can_attack = true 