class_name PlayStateJump extends PlayerState


func init() -> void:
	# 预留初始化入口：后续可扩展为多段跳配置加载。
	pass


func enter() -> void:
	player.animation_player.play("jump")
	player.animation_player.pause()
	# 进入 Jump 时应用向上的初速度。
	player.add_debug_jump_indicator(Color.GREEN)
	player.velocity.y = - player.jump_speed
	
	# 检查是否是缓冲区跳跃
	if player.get_history_state(0) == fall and not Input.is_action_pressed("jump"):
		player.velocity.y *= player.short_hop_scale
	

func exit() -> void:
	# 离开 Jump 时保留调试可视化，便于观察状态切换点。
	player.add_debug_jump_indicator(Color.YELLOW)


func handle_input(event: InputEvent) -> PlayerState:
	# 松开跳跃键时触发短跳，但不立即切换到 Fall。
	# 这样状态切换统一由 physics_process 的速度判断驱动。
	if event.is_action_released("jump"):
		player.velocity.y *= player.short_hop_scale
		return null
	return null


func process(_delta: float) -> PlayerState:
	set_jump_frame()
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
	
func set_jump_frame() -> void:
	var frame: float = remap(player.velocity.y, -player.jump_speed, 0.0, 0.0, 0.5)
	player.animation_player.seek(frame, true)
