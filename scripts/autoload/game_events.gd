# 此脚本需要在项目设置中添加为自动加载单例
# Project Settings -> AutoLoad -> 添加此脚本并命名为 GameEvents

extends Node

# 战斗事件
signal unit_damaged(unit: Node2D, damage: float, source: Node2D)
signal unit_healed(unit: Node2D, amount: float)
signal unit_died(unit: Node2D)
signal unit_respawned(unit: Node2D)

# 移动事件
signal unit_started_moving(unit: Node2D, target: Vector2)
signal unit_stopped_moving(unit: Node2D)

# 技能事件
signal skill_cast_started(unit: Node2D, skill_name: String)
signal skill_cast_ended(unit: Node2D, skill_name: String)
signal projectile_hit(projectile: Node, target: Node2D)

# 游戏状态事件
signal game_paused
signal game_resumed
signal game_ended(winner_team: String)

# 单位选择事件
signal unit_selected(unit: Node2D)
signal unit_deselected(unit: Node2D)

# 组件事件
signal component_added(unit: Node2D, component: Node)
signal component_removed(unit: Node2D, component: Node)
signal component_enabled(unit: Node2D, component: Node)
signal component_disabled(unit: Node2D, component: Node)
