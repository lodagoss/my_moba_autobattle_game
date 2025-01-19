class_name SkillComponent extends Node

signal skill_added(skill_name: String)
signal skill_removed(skill_name: String)
signal skill_cast_started(skill_name: String)
signal skill_cast_completed(skill_name: String)
signal skill_cast_failed(skill_name: String, reason: String)

var skills: Dictionary = {}  # 存储技能实例的字典
@onready var owner_unit: Node2D = get_parent()

func _ready() -> void:
	if not owner_unit:
		push_error("SkillComponent需要一个父节点作为技能拥有者")
		return

# 添加技能
func add_skill(skill: Skill) -> void:
	if skill.skill_name in skills:
		push_warning("技能 %s 已存在，将被替换" % skill.skill_name)
	
	skills[skill.skill_name] = skill
	skill.owner_unit = owner_unit
	skill.skill_component = self
	skill_added.emit(skill.skill_name)

# 移除技能
func remove_skill(skill_name: String) -> void:
	if skill_name in skills:
		skills.erase(skill_name)
		skill_removed.emit(skill_name)

# 获取技能
func get_skill(skill_name: String) -> Skill:
	return skills.get(skill_name)

# 尝试释放技能
func try_cast_skill(skill_name: String, target: Node2D = null) -> bool:
	if not skill_name in skills:
		skill_cast_failed.emit(skill_name, "技能不存在")
		return false
		
	var skill: Skill = skills[skill_name]
	if not skill.can_cast():
		skill_cast_failed.emit(skill_name, "技能冷却中")
		return false
		
	skill_cast_started.emit(skill_name)
	var success: bool = skill.cast(target)
	if success:
		skill_cast_completed.emit(skill_name)
	else:
		skill_cast_failed.emit(skill_name, "释放失败")
	return success

# 禁用组件
func disable() -> void:
	process_mode = PROCESS_MODE_DISABLED

# 启用组件
func enable() -> void:
	process_mode = PROCESS_MODE_INHERIT 
