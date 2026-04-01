class_name PlayStateIdle extends PlayerState


func init() -> void:
	# 预留初始化入口：后续可在这里缓存节点、注册信号或读取配置。
	pass


func enter() -> void:
	player.animation_player.play("idle")


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
	# 向下输入达到阈值进入 Crouch。
	if player.direction.y > player.crouch_threshold:
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
