# Moba自走棋项目设计文档 (GDD)——第二期

## 1. 重构目标

第二期的主要目标是将游戏系统重构为基于组件的架构，引入事件系统，并实现技能系统。这将为后续的扩展和维护打下更好的基础。

## 2. 核心系统设计

### 2.1 组件系统

#### UnitBase 类

- 职责：作为所有单位的基础类，管理组件生命周期
- 核心功能：
  - 组件的添加、移除和获取
  - 组件间的通信协调
  - 单位基础属性的管理

#### 核心组件

1. HealthComponent

```gdscript
属性：
- current_health: float
- max_health: float

信号：
- health_changed(new_health: float, old_health: float)
- died()

功能：
- take_damage(amount: float)
- heal(amount: float)
```

2.MovementComponent

```gdscript
属性：
- move_speed: float
- target_position: Vector2
- is_moving: bool

信号：
- movement_started(target: Vector2)
- movement_ended()

功能：
- move_to(position: Vector2)
- stop_moving()
```

3.SkillComponent

```gdscript
属性：
- skill_list: Array[Skill]
- auto_attack_skill: AutoAttackSkill

信号：
- skill_started(skill: Skill)
- skill_ended(skill: Skill)

功能：
- cast_skill(skill_index: int)
- can_cast(skill_index: int) -> bool
```

4.CombatComponent

```gdscript
属性：
- attack_range: float
- can_attack: bool

信号：
- target_acquired(target: Node)
- target_lost()

功能：
- update_target()
- get_target() -> Node
```

5.RespawnComponent

```gdscript
属性：
- respawn_time: float
- is_respawning: bool
- spawn_point: Vector2

信号：
- respawn_started()
- respawn_completed()

功能：
- start_respawn()
- cancel_respawn()
- set_spawn_point(point: Vector2)
```

### 2.2 技能系统

#### Skill 基础类

```gdscript
属性：
- cooldown: float
- range: float
- damage: float
- projectile_scene: PackedScene

功能：
- cast(source: Node, target: Node)
- interrupt()
```

#### AutoAttackSkill 类

```gdscript
特性：
- attack_speed: float
- auto_cast: bool

功能：
- update_attack_speed()
```

#### Projectile 类

```gdscript
属性：
- speed: float
- damage: float
- source_unit: Node
- target_unit: Node

功能：
- move_to_target()
- apply_damage()
```

### 2.3 事件系统（GameEvents）

#### 核心事件

1.战斗事件

```gdscript
- unit_damaged(unit: Node, damage: float, source: Node)
- unit_died(unit: Node)
- unit_respawned(unit: Node)
```

2.移动事件

```gdscript
- unit_started_moving(unit: Node, target: Vector2)
- unit_stopped_moving(unit: Node)
```

3.技能事件

```gdscript
- skill_cast_started(unit: Node, skill: Skill)
- skill_cast_ended(unit: Node, skill: Skill)
- projectile_hit(projectile: Node, target: Node)
```

## 3. 重构步骤

### 3.1 基础架构重构

1. 创建组件基类和核心组件
2. 实现UnitBase类
3. 建立事件系统单例

### 3.2 单位改造

1. 调整Hero场景结构
2. 改造Tower场景
3. 修改Base场景
4. 更新CreepLine系统

### 3.3 技能系统实现

1. 创建基础技能类
2. 实现自动攻击技能
3. 开发投射物系统

### 3.4 系统整合

1. 将原有攻击系统迁移到技能系统
2. 重构通信机制为事件驱动
3. 添加必要的事件监听器

## 4. 测试计划

### 4.1 单元测试

- 组件功能测试
- 技能系统测试
- 事件系统测试

### 4.2 集成测试

- 组件间通信测试
- 技能连击测试
- 事件响应测试

### 4.3 系统测试

- 完整战斗流程测试
- 性能压力测试
- 内存泄漏测试

## 5. 注意事项

1. 组件设计原则
   - 单一职责
   - 低耦合高内聚
   - 可扩展性优先

2. 事件系统使用规范
   - 事件命名统一
   - 避免事件风暴
   - 合理使用事件参数

3. 性能考虑
   - 组件缓存优化
   - 事件派发优化
   - 对象池复用
