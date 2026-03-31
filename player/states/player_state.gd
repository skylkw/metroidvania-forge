@icon("res://player/states/state.svg")
class_name PlayerState extends Node

# Player 运行时注入的拥有者引用，子状态通过它访问角色数据。
var player: Player

# 通过 unique_name_in_owner 获取到的同级状态引用，便于直接返回目标状态。
@onready var idle: PlayStateIdle = %Idle
@onready var run: PlayStateRun = %Run
@onready var jump: PlayStateJump = %Jump
@onready var fall: PlayStateFall = %Fall
@onready var crouch: PlayStateCrouch = %Crouch


func init() -> void:
	# 预留初始化入口：子类可在这里缓存节点、读取参数、连接信号。
	pass


func enter() -> void:
	# 预留进入状态入口：子类可在这里设置动画、速度、特效等。
	pass


func exit() -> void:
	# 预留退出状态入口：子类可在这里做资源回收和状态清理。
	pass


func handle_input(_event: InputEvent) -> PlayerState:
	# 默认不切换状态，子类按需返回目标状态。
	return null


func process(_delta: float) -> PlayerState:
	# 默认不切换状态，子类可实现逐帧逻辑。
	return null


func physics_update(_delta: float) -> void:
	# 物理阶段前半段：用于更新速度等运动参数，不做状态切换。
	pass


func physics_transition(_delta: float) -> PlayerState:
	# 物理阶段后半段：move_and_slide 后基于最新碰撞结果做状态切换。
	return null
