class_name Component extends Node

# 组件所属的单位
var unit: UnitBase

# 组件初始化信号
signal initialized
# 组件启用/禁用信号
signal enabled
signal disabled

var _is_enabled: bool = true

# 虚函数：组件初始化
func initialize(p_unit: UnitBase) -> void:
	unit = p_unit
	_on_initialize()
	initialized.emit()

# 虚函数：组件启用
func enable() -> void:
	if not _is_enabled:
		_is_enabled = true
		_on_enable()
		enabled.emit()

# 虚函数：组件禁用
func disable() -> void:
	if _is_enabled:
		_is_enabled = false
		_on_disable()
		disabled.emit()

# 获取组件状态
func is_enabled() -> bool:
	return _is_enabled

# 以下是子类需要实现的虚函数
func _on_initialize() -> void:
	pass

func _on_enable() -> void:
	pass

func _on_disable() -> void:
	pass 