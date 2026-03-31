class_name PlayStateFall extends PlayerState

@export var coyote_time: float = 0.4
@export var fall_gravity_scale: float = 1.165
@export var jump_buffer_time: float = 0.2

var coyote_timer: float = 0.0
var buffer_timer: float = 0.0


func init() -> void:
	pass


func enter() -> void:
	player.gravity_scale = fall_gravity_scale
	if player.previous_state == jump:
		coyote_timer = 0.0
	else:
		coyote_timer = coyote_time


func exit() -> void:
	player.gravity_scale = 1.0
	player.add_debug_jump_indicator(Color.RED)


func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_pressed("jump"):
		if coyote_timer > 0:
			return jump
		else:
			buffer_timer = jump_buffer_time
	return next_state


func process(delta: float) -> PlayerState:
	coyote_timer -= delta
	buffer_timer -= delta
	return next_state


func physics_process(delta: float) -> PlayerState:
	if player.is_on_floor():
		if buffer_timer > 0:
			return jump
		return idle
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
