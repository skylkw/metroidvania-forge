@icon("res://player/states/state.svg")
class_name PlayerState extends Node

var player: Player
var next_state: PlayerState

@onready var idle: PlayStateIdle = %Idle
@onready var run: PlayStateRun = %Run
@onready var jump: PlayStateJump = %Jump
@onready var fall: PlayStateFall = %Fall
@onready var crouch: PlayStateCrouch = %Crouch


func init() -> void:
	print("init", name)


func enter() -> void:
	pass


func exit() -> void:
	pass


func handle_input(event: InputEvent) -> PlayerState:
	return next_state


func process(delta: float) -> PlayerState:
	return next_state


func physics_process(delta: float) -> PlayerState:
	return next_state
