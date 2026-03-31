class_name PlayStateCrouch extends PlayerState
@export var deceleration_rate: float = 500

func init() -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass


func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("jump"):
		return jump
	return next_state


func process(delta: float) -> PlayerState:
	if player.direction.y <= 0.5:
		return idle


	return next_state


func physics_process(delta: float) -> PlayerState:
	player.velocity.x = move_toward(player.velocity.x, 0, deceleration_rate * delta)
	print(player.velocity.x)

	if not player.is_on_floor():
		return fall
	return next_state
