@tool
extends Resource
class_name GameBalance

# 调试选项
@export_group("Debug", "show_")
@export var show_attack_range_indicator: bool = false

# 防御塔参数
@export_group("Tower")
@export var tower_attack_range: float = 300.0
@export var tower_attack_damage: float = 50.0
@export var tower_attack_speed: float = 1.0  # 每秒攻击次数
@export var tower_max_health: float = 1000.0

# 英雄参数
@export_group("Hero")
@export var hero_attack_range: float = 150.0
@export var hero_attack_damage: float = 65.0
@export var hero_attack_speed: float = 1.2  # 每秒攻击次数
@export var hero_max_health: float = 800.0
@export var hero_move_speed: float = 200.0  # 像素/秒
@export var hero_respawn_time: float = 2.0  # 秒

# 基地参数
@export_group("Base")
@export var base_max_health: float = 2000.0

# 兵线参数
@export_group("CreepLine")
@export var creep_line_hero_push_force: float = 1.0  # 英雄推线力度
@export var creep_line_tower_push_force: float = 0.5  # 防御塔推线力度

# 兵线物理系统
@export var creep_line_max_velocity: float = 1.0  # 兵线最大速度
@export var creep_line_max_acceleration: float = 0.5  # 兵线最大加速度
@export var creep_line_force_to_acceleration_factor: float = 0.1  # 力转换为加速度的系数

func _init():
	resource_name = "GameBalance" 