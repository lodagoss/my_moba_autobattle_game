"""
# 游戏速度控制器
# 需要在编辑器中：
# 1. 创建一个 HBoxContainer 节点，添加五个按钮：暂停、正常、2倍速、4倍速、8倍速
# 2. 将此脚本挂载到 HBoxContainer 节点上
# 3. 在按钮的pressed信号中连接对应的函数
# 4. 为每个按钮添加快捷键：1-暂停，2-正常，3-2倍速，4-4倍速，5-8倍速
""" 
extends HBoxContainer

const PAUSE_SPEED: float = 0.0
const NORMAL_SPEED: float = 1.0
const DOUBLE_SPEED: float = 2.0
const QUADRUPLE_SPEED: float = 4.0
const OCTUPLE_SPEED: float = 8.0

# 当前速度
var current_speed: float = NORMAL_SPEED

func _ready() -> void:
	Engine.time_scale = current_speed

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed():
		match event.keycode:
			KEY_1:
				pause_game()
			KEY_2:
				normal_speed()
			KEY_3:
				double_speed()
			KEY_4:
				quadruple_speed()
			KEY_5:
				octuple_speed()

func pause_game() -> void:
	current_speed = PAUSE_SPEED
	Engine.time_scale = current_speed

func normal_speed() -> void:
	current_speed = NORMAL_SPEED
	Engine.time_scale = current_speed

func double_speed() -> void:
	current_speed = DOUBLE_SPEED
	Engine.time_scale = current_speed

func quadruple_speed() -> void:
	current_speed = QUADRUPLE_SPEED
	Engine.time_scale = current_speed

func octuple_speed() -> void:
	current_speed = OCTUPLE_SPEED
	Engine.time_scale = current_speed
