class_name Player extends CharacterBody2D
# 全局层级已由 Layers 类管理。

# 调试跳跃指示器存在时长。
const DEBUG_LIFE: float = 3.0
const DEBUG_JUMP_INDICATOR = preload("uid://bipj6qgwefvf")

# === 可调参数（Inspector） ===
@export_group("Movement")
@export var move_speed: float = 100.0
@export var jump_speed: float = 450.0
@export var short_hop_scale: float = 0.5
@export var fall_gravity_scale: float = 1.165
@export var gravity_scale: float = 1.0
@export var crouch_deceleration: float = 500.0
@export var gravity: float = 980.0
@export var max_fall_speed: float = 600

@export_group("Control")
@export var crouch_threshold: float = 0.5
@export var coyote_time: float = 0.4
@export var jump_buffer: float = 0.2

@export_group("System")
@export var debug: bool = true
# 状态历史容量，默认保留最近 8 次状态切换记录。
@export_range(1, 32, 1) var state_history_capacity: int = 8

# === 运行时状态 ===
var state_nodes: Array[PlayerState] = []
var current_state: PlayerState = null
var state_history: Array[PlayerState] = []

var direction: Vector2 = Vector2.ZERO

# === 关键节点缓存 ===
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_stand: CollisionShape2D = $CollisionStand
@onready var collision_crouch: CollisionShape2D = $CollisionCrouch
@onready var one_way_platform_raycast: RayCast2D = $OneWayPlatformRaycast
@onready var states_root: Node = $States
@onready var state_label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	# 启动时构建状态。
	if state_label:
		state_label.visible = debug
	initialize_states()


func _process(delta: float) -> void:
	# 先读取输入方向，再让当前状态处理逐帧逻辑。
	update_direction()
	change_state(current_state.process(delta))


func _physics_process(delta: float) -> void:
	# 物理帧采用两阶段：更新速度，然后基于碰撞结果切换。
	velocity.y += gravity * delta * gravity_scale
	velocity.y = clampf(velocity.y,-1000.0,max_fall_speed)
	current_state.physics_update(delta)
	move_and_slide()
	change_state(current_state.physics_transition(delta))


func _unhandled_input(event: InputEvent) -> void:
	# 输入事件优先交由当前状态决定是否切换。
	change_state(current_state.handle_input(event))


func initialize_states() -> void:
	# 收集 States 节点下的全部 PlayerState，并注入 player 引用。
	state_nodes.clear()
	state_history.clear()
	for child in states_root.get_children():
		if child is PlayerState:
			var state := child as PlayerState
			state_nodes.append(state)
			state.player = self

	# 没有状态节点时给出警告并直接返回。
	if state_nodes.is_empty():
		push_warning("Player has no PlayerState children under States.")
		return

	# 允许各状态在这里做一次性初始化。
	for state in state_nodes:
		state.init()

	# 默认取第一个状态作为初始状态。
	current_state = state_nodes.front()
	if debug and state_label:
		state_label.text = current_state.name
	current_state.enter()


func change_state(new_state: PlayerState) -> void:
	# 空状态或重复状态不切换。
	if new_state == null or new_state == current_state:
		return

	# 先退出旧状态，再进入新状态，保证生命周期顺序稳定。
	current_state.exit()
	record_state_history(current_state)

	current_state = new_state
	current_state.enter()
	if debug and state_label:
		state_label.text = current_state.name


func get_history_state(offset: int = 0) -> PlayerState:
	# offset=0 表示上一个状态，offset=1 表示上上个状态，以此类推。
	if offset < 0:
		push_warning("State history offset must be >= 0.")
		return null

	if offset >= state_history.size():
		return null
	return state_history[offset]


func is_history_state(state: PlayerState, offset: int = 0) -> bool:
	# 便捷判断：检查指定偏移量的历史状态是否等于目标状态。
	if state == null:
		return false
	return get_history_state(offset) == state


func record_state_history(state: PlayerState) -> void:
	state_history.push_front(state)
	if state_history.size() > state_history_capacity:
		state_history.pop_back()


func update_direction() -> void:
	var pre_direction :Vector2= direction
	# 统一通过输入映射读取二维方向输入。
	var x_axis: float = Input.get_axis("left", "right")
	var y_axis: float = Input.get_axis("up", "down")
	direction = Vector2(x_axis, y_axis)
	if pre_direction.x != direction.x:
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0 :
			sprite.flip_h = false
	


func add_debug_jump_indicator(color: Color = Color.RED) -> void:
	# 关闭调试开关时不生成任何调试节点。
	if not debug:
		return

	# 生成临时调试标记，便于观察状态切换时机。
	var indicator := DEBUG_JUMP_INDICATOR.instantiate()
	get_tree().root.add_child(indicator)
	indicator.global_position = global_position
	indicator.modulate = color
	await get_tree().create_timer(DEBUG_LIFE).timeout
	indicator.queue_free()
