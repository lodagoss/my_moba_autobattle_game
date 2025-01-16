extends Node

# 团队标识符
const LEFT_TEAM := "left"
const RIGHT_TEAM := "right"

# 团队颜色（静态定义）
const TEAM_COLORS := {
	LEFT_TEAM: Color(1.0, 0.3, 0.3, 1.0),  # 红色
	RIGHT_TEAM: Color(0.3, 0.3, 1.0, 1.0)  # 蓝色
}

# 获取团队颜色
func get_team_color(team: String) -> Color:
	return TEAM_COLORS.get(team, Color.WHITE)

# 获取敌对团队
func get_enemy_team(team: String) -> String:
	return RIGHT_TEAM if team == LEFT_TEAM else LEFT_TEAM

# 检查两个单位是否是敌人
func are_enemies(unit1: Node, unit2: Node) -> bool:
	return unit1.is_in_group(LEFT_TEAM + "_team") and unit2.is_in_group(RIGHT_TEAM + "_team") or \
		   unit1.is_in_group(RIGHT_TEAM + "_team") and unit2.is_in_group(LEFT_TEAM + "_team") 