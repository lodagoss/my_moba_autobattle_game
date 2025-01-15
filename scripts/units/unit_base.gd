class_name UnitBase extends CharacterBody2D

# 组件字典，用于存储和管理组件
var _components: Dictionary = {}

# 添加组件
func add_component(component: Component) -> void:
	var component_name := component.get_class()
	if _components.has(component_name):
		push_warning("Component %s already exists on %s" % [component_name, name])
		return
		
	add_child(component)
	_components[component_name] = component
	component.initialize(self)

# 移除组件
func remove_component(component_name: String) -> void:
	if not _components.has(component_name):
		push_warning("Component %s does not exist on %s" % [component_name, name])
		return
		
	var component = _components[component_name]
	_components.erase(component_name)
	component.queue_free()

# 获取组件
func get_component(component_name: String) -> Component:
	if not _components.has(component_name):
		push_warning("Component %s does not exist on %s" % [component_name, name])
		return null
		
	return _components[component_name]

# 检查是否有某个组件
func has_component(component_name: String) -> bool:
	return _components.has(component_name)

# 启用组件
func enable_component(component_name: String) -> void:
	var component = get_component(component_name)
	if component:
		component.enable()

# 禁用组件
func disable_component(component_name: String) -> void:
	var component = get_component(component_name)
	if component:
		component.disable()

# 获取所有组件
func get_all_components() -> Array[Component]:
	return _components.values() 