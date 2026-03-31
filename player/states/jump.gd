class_name PlayStateJump extends PlayerState

# 提前松开跳跃键时的纵向速度缩放系数，用于短跳。
const SHORT_HOP_RELEASE_MULTIPLIER: float = 0.5

@export var jump_speed: float = 450.0


func init() -> void:
	# 预留初始化入口：后续可扩展为多段跳配置加载。
	pass


func enter() -> void:
	# 进入 Jump 时给一个向上的初速度。
	player.add_debug_jump_indicator(Color.GREEN)
	player.velocity.y = - jump_speed


func exit() -> void:
	# 离开 Jump 时保留调试可视化，便于观察状态切换点。
	player.add_debug_jump_indicator(Color.YELLOW)


func handle_input(event: InputEvent) -> PlayerState:
	# 松开跳跃键时触发短跳，但不立即切换到 Fall。
	# 这样状态切换统一由 physics_process 的速度判断驱动。
	if event.is_action_released("jump"):
		player.velocity.y *= SHORT_HOP_RELEASE_MULTIPLIER
		return null
	return null


func process(_delta: float) -> PlayerState:
	# 预留逐帧逻辑入口，当前 Jump 逻辑主要在 physics_process 中处理。
	pass
	return null


func physics_update(_delta: float) -> void:
	# 空中保留横向控制。
	player.velocity.x = player.direction.x * player.move_speed


func physics_transition(_delta: float) -> PlayerState:
	# move_and_slide 后若已重新接触地面，直接回到 Idle。
	if player.is_on_floor():
		return idle
	# 上升速度耗尽后切换到 Fall。
	if player.velocity.y >= 0.0:
		return fall
	return null
