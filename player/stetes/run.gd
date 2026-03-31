class_name PlayStateRun extends PlayerState


func init() -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass


func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed('jump'):
		return jump
	return next_state


func process(delta: float) -> PlayerState:
	if player.direction.x == 0:
		return idle
	elif player.direction.y > 0.5:
		return crouch
	return next_state


func physics_process(delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * player.move_speed
	if not player.is_on_floor():
		return fall
	return next_state
