class_name StunBoltSkill extends Skill

var stun_duration: float
var projectile_speed: float

func _init(p_range: float, p_damage: float, p_cooldown: float, 
		p_stun_duration: float, p_projectile_speed: float = 400.0) -> void:
	super._init("stun_bolt", p_cooldown, p_range, p_damage)
	stun_duration = p_stun_duration
	projectile_speed = p_projectile_speed

func cast(target: Node2D) -> bool:
	if not super.cast(target):
		return false
	
	_create_projectile(target)
	return true

func _create_projectile(target: Node2D) -> void:
	# 获取项目根节点
	var root := owner_unit.get_tree().get_first_node_in_group("arena")
	if not root:
		push_error("找不到arena节点")
		return
	
	# 实例化投射物场景
	var projectile_scene := preload("res://scenes/stun_projectile.tscn")
	var projectile: StunProjectile = projectile_scene.instantiate()
	
	# 设置投射物属性
	projectile.setup(owner_unit, target, damage, projectile_speed)
	projectile.set_stun_duration(stun_duration)
	
	# 将投射物添加到场景树
	root.add_child(projectile) 
