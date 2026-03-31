class_name PlayStateCrouch extends PlayerState
@export var deceleration_rate: float = 500

func init() -> void:
	pass


func enter() -> void:
	player.collision_stand.disabled = true	
	player.collision_crouch.disabled = false
	pass


func exit() -> void:
	player.collision_stand.disabled = false	
	player.collision_crouch.disabled = true
	pass


func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("jump"):
		if player.one_way_platform_raycast.is_colliding():
			player.position.y += 1
			print('fall')
			return fall
		return jump
	return next_state


func process(delta: float) -> PlayerState:
	if player.direction.y <= 0.5:
		return idle


	return next_state


func physics_process(delta: float) -> PlayerState:
	player.velocity.x = move_toward(player.velocity.x, 0, deceleration_rate * delta)


	if not player.is_on_floor():
		return fall
	return next_state
