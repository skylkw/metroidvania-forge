class_name PlayStateCrouch extends PlayerState


func init() -> void:
	# 预留初始化入口：后续可扩展为滑铲/匍匐等能力配置。
	pass

func enter() -> void:
	# 进入 Crouch：启用矮碰撞体，禁用站立碰撞体。
	player.collision_stand.disabled = true
	player.collision_crouch.disabled = false
	player.animation_player.play("crouch")


func exit() -> void:
	# 退出 Crouch：恢复站立碰撞体。
	player.collision_stand.disabled = false
	player.collision_crouch.disabled = true


func handle_input(event: InputEvent) -> PlayerState:
	# Crouch 中按跳跃：若脚下是单向平台则执行下落，否则正常起跳。
	if event.is_action_pressed("jump"):
		if player.one_way_platform_raycast.is_colliding():
			drop_through_platform()
			return fall
		return jump
	return null


func process(_delta: float) -> PlayerState:
	# 只有在输入允许且头顶有空间时才回到 Idle。
	if player.direction.y <= player.crouch_threshold:
		return idle
	return null


func physics_update(delta: float) -> void:
	# 水平速度衰减。
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.crouch_deceleration * delta)


func physics_transition(_delta: float) -> PlayerState:
	# move_and_slide 后若离地则进入 Fall。
	if not player.is_on_floor():
		return fall
	return null


func drop_through_platform() -> void:
	# 临时屏蔽全局单向平台层级，然后自然下坠。
	player.set_collision_mask_value(Layers.ID.ONE_WAY, false)
	await get_tree().create_timer(0.2).timeout
	player.set_collision_mask_value(Layers.ID.ONE_WAY, true)
