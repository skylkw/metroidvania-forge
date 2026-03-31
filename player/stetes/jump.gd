class_name PlayStateJump extends PlayerState

@export var jump_speed: float = 450.0


func init() -> void:
	pass


func enter() -> void:
	player.add_debug_jump_indicator(Color.GREEN)
	player.velocity.y = -jump_speed
	pass


func exit() -> void:
	player.add_debug_jump_indicator(Color.YELLOW)
	pass


func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_released("jump"):
		player.velocity.y *= 0.5
		return fall
	return next_state


func process(delta: float) -> PlayerState:
	return next_state


func physics_process(delta: float) -> PlayerState:
	if player.is_on_floor():
		return idle
	elif player.velocity.y >= 0:
		return fall
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
