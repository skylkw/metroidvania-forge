class_name PlayStateRun extends PlayerState

# 下蹲输入阈值，统一与其他状态一致，避免魔法数字散落。
const CROUCH_INPUT_THRESHOLD: float = 0.5


func init() -> void:
	# 预留初始化入口：后续可扩展为跑步状态的参数准备。
	pass


func enter() -> void:
	# 预留进入入口：后续可触发跑步动画或粒子效果。
	pass


func exit() -> void:
	# 预留退出入口：后续可做冲刺残留状态清理。
	pass


func handle_input(event: InputEvent) -> PlayerState:
	# 跑步时按下跳跃，切换到 Jump。
	if event.is_action_pressed("jump"):
		return jump
	return null


func process(_delta: float) -> PlayerState:
	# 丢失水平输入，回到待机。
	if player.direction.x == 0.0:
		return idle
	# 向下输入达到阈值时进入下蹲。
	if player.direction.y > CROUCH_INPUT_THRESHOLD:
		return crouch
	return null


func physics_update(_delta: float) -> void:
	# 跑步状态持续刷新水平速度。
	player.velocity.x = player.direction.x * player.move_speed


func physics_transition(_delta: float) -> PlayerState:
	# move_and_slide 后若失去地面接触，切换到 Fall。
	if not player.is_on_floor():
		return fall
	return null
