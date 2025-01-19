class_name AttackSkill
extends Skill

var is_ranged: bool
var projectile_speed: float

func _init(p_is_ranged: bool, p_attack_range: float, p_attack_damage: float, 
		p_attack_speed: float, p_projectile_speed: float = 300.0) -> void:
	super._init("attack", 1.0 / p_attack_speed, p_attack_range, p_attack_damage)
	is_ranged = p_is_ranged
	projectile_speed = p_projectile_speed

func cast(target: Node2D) -> bool:
	if not super.cast(target):
		return false
	
	if is_ranged:
		_create_projectile(target)
	else:
		_apply_melee_damage(target)
	
	return true

func _create_projectile(target: Node2D) -> void:
	# 获取项目根节点
	var root := owner_unit.get_tree().get_first_node_in_group("arena")
	if not root:
		push_error("找不到arena节点")
		return
	
	# 实例化投射物场景
	var projectile_scene := preload("res://scenes/projectile.tscn")
	var projectile: Projectile = projectile_scene.instantiate()
	
	# 设置投射物属性
	projectile.setup(owner_unit, target, damage, projectile_speed)
	
	# 将投射物添加到场景树
	root.add_child(projectile)

func _apply_melee_damage(target: Node2D) -> void:
	var health_comp := target.get_node_or_null("HealthComponent") as HealthComponent
	if health_comp:
		health_comp.take_damage(damage, owner_unit) 
