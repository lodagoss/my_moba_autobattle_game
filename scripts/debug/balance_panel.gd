@tool
extends Control
class_name BalancePanel

# 在Godot编辑器中需要进行以下操作：
# 1. 创建一个新的Control节点，附加此脚本
# 2. 添加一个ScrollContainer作为子节点
# 3. 在ScrollContainer中添加一个VBoxContainer
# 4. 为每个参数创建一个HBoxContainer，包含Label和SpinBox
# 5. 设置适当的布局和样式

@export var game_balance: GameBalance

@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer

var _property_controls: Dictionary = {}

func _ready() -> void:
	if not game_balance:
		push_error("Game balance resource not assigned!")
		return
	
	if not container:
		push_error("VBoxContainer not found! Make sure the node path is correct.")
		return
	
	_setup_controls()

func _setup_controls() -> void:
	# 清除现有控件
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	_property_controls.clear()
	
	# 获取所有属性
	var properties := game_balance.get_property_list()
	
	# 添加调试选项组标题
	var debug_label := Label.new()
	debug_label.text = "Debug Options"
	debug_label.add_theme_color_override("font_color", Color(0.2, 0.6, 1.0))
	container.add_child(debug_label)
	
	# 添加调试选项
	_add_bool_control("show_attack_range_indicator", "Show Attack Range")
	
	# 添加其他参数组标题
	var params_label := Label.new()
	params_label.text = "\nGame Parameters"
	params_label.add_theme_color_override("font_color", Color(0.2, 0.6, 1.0))
	container.add_child(params_label)
	
	for property in properties:
		var property_name: String = property.name
		var property_type: int = property.type
		
		# 跳过内部属性和已处理的调试选项
		if property_name.begins_with("_") or property_name in ["resource_path", "resource_name", "script", "resource_local_to_scene", "show_attack_range_indicator"]:
			continue
			
		# 只处理数值类型的属性
		if not property_type in [TYPE_FLOAT, TYPE_INT]:
			continue
		
		var current_value = game_balance.get(property_name)
		if current_value == null:
			push_warning("Skipping property %s because its value is null" % property_name)
			continue
		
		_add_number_control(property_name, current_value)

func _add_bool_control(property_name: String, display_name: String) -> void:
	var hbox := HBoxContainer.new()
	var label := Label.new()
	var checkbox := CheckBox.new()
	
	# 设置标签
	label.text = display_name
	label.custom_minimum_size.x = 200
	label.add_theme_color_override("font_color", Color.BLACK)
	
	# 设置CheckBox
	checkbox.button_pressed = game_balance.get(property_name)
	checkbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# 添加到界面
	hbox.add_child(label)
	hbox.add_child(checkbox)
	container.add_child(hbox)
	
	_property_controls[property_name] = checkbox
	checkbox.toggled.connect(_on_bool_changed.bind(property_name))

func _add_number_control(property_name: String, current_value: float) -> void:
	var hbox := HBoxContainer.new()
	var label := Label.new()
	var spinbox := SpinBox.new()
	
	# 设置标签
	label.text = property_name.capitalize().replace("_", " ")
	label.custom_minimum_size.x = 200
	label.add_theme_color_override("font_color", Color.BLACK)
	
	# 设置SpinBox
	spinbox.min_value = 0.0
	spinbox.max_value = 10000.0
	spinbox.step = 0.0001
	spinbox.value = current_value
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spinbox.custom_arrow_step = 0.01
	spinbox.set_meta("_editor_description", "4 decimal places")
	spinbox.get_line_edit().set_max_length(10)
	
	# 设置显示小数位数为4位
	spinbox.get_line_edit().set("step", 0.0001)
	spinbox.get_line_edit().set("decimal_places", 4)
	
	# 添加到界面
	hbox.add_child(label)
	hbox.add_child(spinbox)
	container.add_child(hbox)
	
	_property_controls[property_name] = spinbox
	spinbox.value_changed.connect(_on_value_changed.bind(property_name))

func _on_bool_changed(value: bool, property: String) -> void:
	if game_balance and property in _property_controls:
		game_balance.set(property, value)

func _on_value_changed(value: float, property: String) -> void:
	if game_balance and property in _property_controls:
		game_balance.set(property, value)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		if game_balance and ResourceLoader.exists(game_balance.resource_path):
			ResourceSaver.save(game_balance) 
