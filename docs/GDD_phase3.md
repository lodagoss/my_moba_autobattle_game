# Moba自走棋项目设计文档 (GDD)——第三期

## 1. 重构目标

第三期的主要目标是重构战斗系统,将原有的直接攻击改为基于技能组件的方式,并重做兵线系统。这将为后续添加更多技能类型打下基础。

### 1.1 技能系统重构

#### skill_component类

- **职责**:管理单位的技能列表,处理技能释放
- **核心技能**:
  - `melee_attack`: 近战普攻
  - `range_attack`: 远程普攻
  - `stun_bolt`: 晕锤技能

#### projectile类

- **职责**:实现投射物的移动和碰撞检测
- **应用**:用于实现range_attack和stun_bolt等远程技能
- **核心功能**:
  - 移动逻辑
  - 碰撞检测
  - 伤害应用
  - 特效管理

### 1.2 战斗系统重构

#### combat_component重构

- 移除直接攻击逻辑
- 通过skill_component实现攻击和技能释放
- 保留目标检测和选择逻辑

#### hero类重构

- 改为hero_base类,作为所有英雄的基类
- 支持动态安装技能
- 实现两种基础英雄:
  - `melee_base_hero`: 近战英雄
  - `range_base_hero`: 远程英雄
  - 两种英雄都具有stun_bolt技能，区别是一个安装了近战攻击，一个安装了远程攻击。

### 1.3 兵线系统重构

#### Minion类设计

- 分为近战和远程小兵
- 继承自CharacterBody2D
- **核心组件**:
  - HealthComponent
  - TeamComponent
  - CombatComponent
  - MovementComponent
  - SkillComponent

#### MinionAI类设计

- **实现状态机**:
  - IDLE: 待机状态
  - MOVE: 移动状态
  - ATTACK: 攻击状态
  - FOLLOW: 跟随状态
- 使用Navigation2D和NavigationAgent2D实现寻路
- **实现攻击逻辑**:
  - 在攻击范围内有敌方单位，则攻击最近的敌方单位
  - 偏离兵线一定范围后，优先回到兵线

#### MinionSpawner设计

- 定时在双方基地生成小兵
- 控制小兵生成数量和时间间隔
