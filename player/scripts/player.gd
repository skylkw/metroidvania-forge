class_name Player extends CharacterBody2D
const DEBUG_JUMP_INDICATOR = preload("uid://bipj6qgwefvf")

@export var move_speed: float = 100

var states: Array[PlayerState]
var cuttent_state: PlayerState:
	get: return states.front()
var previous_state: PlayerState:
	get: return states[1]

var direction: Vector2 = Vector2.ZERO
var gravity: float = 980.0
var gravity_scale: float = 1.0


func _ready() -> void:
	initialize_states()


func _process(delta: float) -> void:
	update_direction()
	change_state(cuttent_state.process(delta))


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta * gravity_scale
	move_and_slide()
	change_state(cuttent_state.physics_process(delta))


func _unhandled_input(event: InputEvent) -> void:
	change_state(cuttent_state.handle_input(event))


func initialize_states() -> void:
	states = []
	for c in $States.get_children():
		if c is PlayerState:
			states.append(c)
			c.player = self
	if states.is_empty():
		return

	for state in states:
		state.init()
	$Label.text = cuttent_state.name
	change_state(cuttent_state)


func change_state(new_state: PlayerState) -> void:
	if new_state == null:
		return
	elif new_state == cuttent_state:
		return
	if cuttent_state:
		cuttent_state.exit()
	states.push_front(new_state)
	cuttent_state.enter()
	states.resize(3)
	$Label.text = cuttent_state.name


func update_direction() -> void:
	#var prev_direction: Vector2 = direction
	var x_axis = Input.get_axis("left", "right")
	var y_axis = Input.get_axis("up", "down")
	direction = Vector2(x_axis, y_axis)

	pass


func add_debug_jump_indicator(color: Color = Color.RED) -> void:
	var indicator = DEBUG_JUMP_INDICATOR.instantiate()
	get_tree().root.add_child(indicator)
	indicator.global_position = global_position
	indicator.modulate = color
	await get_tree().create_timer(3).timeout
	indicator.queue_free()
