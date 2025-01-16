class_name TeamComponent extends Node

@export_enum("left", "right") var team: String = TeamManager.LEFT_TEAM:
	set(value):
		team = value
		_update_team()

@onready var sprite: Sprite2D = $"../Sprite2D"

func _ready() -> void:
	_update_team()

func _update_team() -> void:
	# 更新团队组
	owner.remove_from_group(TeamManager.LEFT_TEAM + "_team")
	owner.remove_from_group(TeamManager.RIGHT_TEAM + "_team")
	owner.add_to_group(team + "_team")
	
	# 更新颜色
	if sprite:
		sprite.modulate = TeamManager.get_team_color(team)

# 获取敌对团队
func get_enemy_team() -> String:
	return TeamManager.get_enemy_team(team)

# 检查是否是敌人
func is_enemy(other_unit: Node) -> bool:
	return TeamManager.are_enemies(owner, other_unit) 