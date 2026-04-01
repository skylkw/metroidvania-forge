class_name PlayStateFall extends PlayerState



var coyote_timer: float = 0.0
var buffer_timer: float = 0.0
var _old_gravity: float = 1.0


func init() -> void:
	pass


func enter() -> void:
	player.animation_player.play("jump")
	player.animation_player.pause()
	# 记录并增加下落重力。
	_old_gravity = player.gravity_scale
	player.gravity_scale = player.fall_gravity_scale
	# 如果刚从 Jump 进入 Fall，则不再给土狼时间；否则给予短暂补偿窗口。
	if player.is_history_state(jump):
		coyote_timer = 0.0
	else:
		coyote_timer = player.coyote_time
	# 每次进入 Fall 重置输入缓冲，避免跨状态残留。
	buffer_timer = 0.0


func exit() -> void:
	# 还原重力。
	player.gravity_scale = _old_gravity
	buffer_timer = 0.0
	player.add_debug_jump_indicator(Color.RED)


func handle_input(event: InputEvent) -> PlayerState:
	# Fall 中按下跳跃：优先吃土狼时间，否则写入跳跃缓冲。
	if event.is_action_pressed("jump"):
		if coyote_timer > 0.0:
			return jump
		else:
			buffer_timer = player.jump_buffer
	return null


func process(delta: float) -> PlayerState:
	# 计时器只递减到 0，避免负值带来判断噪音。
	coyote_timer = max(coyote_timer - delta, 0.0)
	buffer_timer = max(buffer_timer - delta, 0.0)
	set_jump_frame()
	return null


func physics_update(_delta: float) -> void:
	# 空中持续应用横向控制。
	player.velocity.x = player.direction.x * player.move_speed


func physics_transition(_delta: float) -> PlayerState:
	# move_and_slide 后若落地，优先消费跳跃缓冲，否则回到 Idle。
	if player.is_on_floor():
		if buffer_timer > 0.0:
			return jump
		return idle
	return null


func set_jump_frame() -> void:
	var frame: float = remap(player.velocity.y,  0.0,player.max_fall_speed, 0.5, 1.0)
	player.animation_player.seek(frame, true)
