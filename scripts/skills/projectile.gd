# 此脚本需要在 Godot 编辑器中进行以下配置：
# 1. 将此脚本挂载到继承自 Area2D 的场景根节点
# 2. 添加以下子节点：
#    - Sprite2D
#    - CollisionShape2D（配置为圆形碰撞形状）

class_name Projectile extends Area2D

var source: Node2D  # 发射源
var target: Node2D  # 目标
var damage: float   # 伤害值
var speed: float    # 移动速度
var direction: Vector2  # 移动方向

func _ready() -> void:
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)
	
	# 如果目标已经无效，则自动销毁
	if not target or not is_instance_valid(target):
		queue_free()
		return
		
	# 计算初始方向
	direction = (target.global_position - global_position).normalized()
	
	# 设置初始旋转
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# 如果目标无效，继续沿原方向移动
	position += direction * speed * delta
	
	# 检查是否已经飞行太远（超过1000像素）
	if position.length() > 1000:
		queue_free()

# 设置投射物属性
func setup(p_source: Node2D, p_target: Node2D, p_damage: float, p_speed: float) -> void:
	source = p_source
	target = p_target
	damage = p_damage
	speed = p_speed
	
	# 设置初始位置
	global_position = source.global_position

# 碰撞检测
func _on_body_entered(body: Node2D) -> void:
	if body == source:  # 忽略与发射源的碰撞
		return
		
	# 检查是否击中有效目标
	var health_comp := body.get_node_or_null("HealthComponent") as HealthComponent
	if health_comp:
		health_comp.take_damage(damage, source)
		GameEvents.projectile_hit.emit(self, body)
	
	# 销毁投射物
	queue_free() 
