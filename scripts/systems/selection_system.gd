# 此脚本需要在 Godot 编辑器中进行以下配置：
# 1. 将此脚本挂载到场景根节点下的 SelectionSystem 节点上
# 2. 确保场景中的所有可选择单位都有 CollisionShape2D 组件
# 3. 确保英雄单位被添加到 "Hero" 组中

class_name SelectionSystem extends Node

var selected_unit: Node2D = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			handle_selection(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and selected_unit:
			handle_movement(event.position)

func handle_selection(click_position: Vector2) -> void:
	# 从当前场景获取 world_2d
	var space = get_tree().root.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = click_position  # 不需要调整点击位置，因为物理系统会自动处理相对位置
	query.collide_with_bodies = true  # 检测物理实体
	query.collide_with_areas = false  # 不检测 Area2D
	
	var result = space.intersect_point(query)
	if result.size() > 0:
		var clicked_object = result[0].collider
		if clicked_object is Node2D and clicked_object.is_in_group("Hero"):
			if selected_unit != clicked_object:
				if selected_unit:
					GameEvents.unit_deselected.emit(selected_unit)
				selected_unit = clicked_object
				GameEvents.unit_selected.emit(selected_unit)

func handle_movement(target_position: Vector2) -> void:
	if selected_unit and selected_unit.has_method("move_to"):
		selected_unit.move_to(target_position)  # 不需要调整目标位置，因为移动系统使用的是全局坐标
