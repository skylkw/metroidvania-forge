class_name PlayStateIdle extends PlayerState

# 下蹲输入阈值，避免直接在逻辑中写 0.5 这样的魔法数字。
const CROUCH_INPUT_THRESHOLD: float = 0.5


func init() -> void:
	# 预留初始化入口：后续可在这里缓存节点、注册信号或读取配置。
	pass


func enter() -> void:
	# 预留进入状态入口：后续可接入动画、特效、音效等。
	pass


func exit() -> void:
	# 预留离开状态入口：后续可在这里做收尾逻辑。
	pass


func handle_input(event: InputEvent) -> PlayerState:
	# 待机状态按下跳跃，立即切换到 Jump。
	if event.is_action_pressed("jump"):
		return jump
	return null


func process(_delta: float) -> PlayerState:
	# 只要有水平输入就切换到 Run。
	if player.direction.x != 0.0:
		return run
	# 下方向输入超过阈值则进入 Crouch。
	if player.direction.y > CROUCH_INPUT_THRESHOLD:
		return crouch
	return null


func physics_update(_delta: float) -> void:
	# 待机状态将水平速度归零，确保角色稳定站立。
	player.velocity.x = 0.0


func physics_transition(_delta: float) -> PlayerState:
	# move_and_slide 后若失去地面接触，切换到 Fall。
	if not player.is_on_floor():
		return fall
	return null
