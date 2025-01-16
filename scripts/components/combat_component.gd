class_name CombatComponent extends Node

signal target_acquired(target: Node2D)
signal target_lost()
signal attack_started(target: Node2D)
signal attack_completed(target: Node2D)

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
	
	# 连接信号
	attack_area.body_entered.connect(_on_body_entered)
	attack_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return
		
	if can_attack_target(body):
		set_target(body)

func _on_body_exited(body: Node2D) -> void:
	if body == target:
		clear_target()

func _physics_process(_delta: float) -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return
		
	if target and can_attack:
		perform_attack()

func can_attack_target(potential_target: Node2D) -> bool:
	return team_comp.is_enemy(potential_target)

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
	
	# 对目标造成伤害
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
	
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