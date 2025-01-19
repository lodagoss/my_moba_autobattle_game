# 此脚本需要在 Godot 编辑器中进行以下配置：
# 1. 将此脚本挂载到继承自 Area2D 的场景根节点
# 2. 添加以下子节点：
#    - Sprite2D
#    - CollisionShape2D（配置为圆形碰撞形状）

class_name StunProjectile extends Projectile

var stun_duration: float

func set_stun_duration(p_stun_duration: float) -> void:
	stun_duration = p_stun_duration

func _on_body_entered(body: Node2D) -> void:
	if body == source:  # 忽略与发射源的碰撞
		return
		
	# 检查是否击中有效目标
	var health_comp := body.get_node_or_null("HealthComponent") as HealthComponent
	if health_comp:
		health_comp.take_damage(damage, source)
		
		# 添加晕眩效果
		var status_comp := body.get_node_or_null("StatusComponent")
		if status_comp:
			status_comp.add_status("stunned", stun_duration)
		
		GameEvents.projectile_hit.emit(self, body)
	
	# 销毁投射物
	queue_free() 
