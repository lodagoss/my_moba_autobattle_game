class_name HeroData extends Resource

# 基础属性
@export var hero_name: String = ""
@export var max_health: float = 800.0
@export var move_speed: float = 200.0
@export var respawn_time: float = 2.0

# 普通攻击属性
@export var is_ranged: bool = false
@export var attack_range: float = 100.0
@export var attack_damage: float = 65.0
@export var attack_speed: float = 1.2
@export var projectile_speed: float = 300.0

# 技能配置列表
@export var skill_configs: Array[Dictionary] = []

# 创建技能实例
func create_skills() -> Array[Skill]:
	var skills: Array[Skill] = []
	
	# 创建普通攻击技能
	var attack := AttackSkill.new(
		is_ranged,
		attack_range,
		attack_damage,
		attack_speed,
		projectile_speed
	)
	skills.append(attack)
	
	# 根据配置创建其他技能
	for config in skill_configs:
		var skill: Skill
		match config.type:
			"stun_bolt":
				skill = StunBoltSkill.new(
					config.range,
					config.damage,
					config.cooldown,
					config.stun_duration,
					config.projectile_speed
				)
			# 在这里添加更多技能类型的处理
		
		if skill:
			skills.append(skill)
	
	return skills 
