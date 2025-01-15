# 此脚本需要在项目设置中添加为自动加载单例
# Project Settings -> AutoLoad -> 添加此脚本并命名为 GameEvents

extends Node

# 战斗事件
signal unit_damaged(unit: UnitBase, damage: float, source: UnitBase)
signal unit_healed(unit: UnitBase, amount: float)
signal unit_died(unit: UnitBase)
signal unit_respawned(unit: UnitBase)

# 移动事件
signal unit_started_moving(unit: UnitBase, target: Vector2)
signal unit_stopped_moving(unit: UnitBase)

# 技能事件
signal skill_cast_started(unit: UnitBase, skill_name: String)
signal skill_cast_ended(unit: UnitBase, skill_name: String)
signal projectile_hit(projectile: Node, target: UnitBase)

# 游戏状态事件
signal game_paused
signal game_resumed
signal game_ended(winner_team: int)

# 单位选择事件
signal unit_selected(unit: UnitBase)
signal unit_deselected(unit: UnitBase)

# 组件事件
signal component_added(unit: UnitBase, component: Component)
signal component_removed(unit: UnitBase, component: Component)
signal component_enabled(unit: UnitBase, component: Component)
signal component_disabled(unit: UnitBase, component: Component) 