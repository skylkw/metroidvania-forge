class_name Player extends CharacterBody2D

# 项目配置键名：读取 Godot 项目设置中的默认 2D 重力。
const PROJECT_GRAVITY_SETTING_PATH: String = "physics/2d/default_gravity"
# 起身检测时只需要知道是否命中，查询 1 个结果即可。
const STAND_UP_QUERY_MAX_RESULTS: int = 1
# 调试跳跃指示器存在时长。
const DEBUG_INDICATOR_LIFETIME_SECONDS: float = 3.0
# 状态历史至少保留 1 条，避免配置为 0 时逻辑异常。
const MIN_STATE_HISTORY_CAPACITY: int = 1
# 历史查询层级：1 表示上一个状态，2 表示上上个状态。
const HISTORY_LEVEL_START: int = 1
const DEBUG_JUMP_INDICATOR = preload("uid://bipj6qgwefvf")

# === 可调参数（Inspector） ===
@export var move_speed: float = 100.0
@export var debug_state_indicators: bool = true
# 状态历史容量，默认保留最近 8 次状态切换记录。
@export_range(1, 32, 1) var state_history_capacity: int = 8

# === 运行时状态 ===
var state_nodes: Array[PlayerState] = []
var current_state: PlayerState = null
var state_history: Array[PlayerState] = []

var direction: Vector2 = Vector2.ZERO
var gravity: float = float(ProjectSettings.get_setting(PROJECT_GRAVITY_SETTING_PATH))
var gravity_scale: float = 1.0

# === 关键节点缓存 ===
@onready var collision_stand: CollisionShape2D = $CollisionStand
@onready var collision_crouch: CollisionShape2D = $CollisionCrouch
@onready var one_way_platform_raycast: RayCast2D = $OneWayPlatformRaycast
@onready var states_root: Node = $States
@onready var state_label: Label = $Label


func _ready() -> void:
	# 启动时构建状态列表并进入初始状态。
	initialize_states()


func _process(delta: float) -> void:
	# 先读取输入方向，再让当前状态处理逐帧逻辑。
	update_direction()
	if current_state == null:
		return
	change_state(current_state.process(delta))


func _physics_process(delta: float) -> void:
	# 物理帧采用两阶段：
	# 1) 先更新速度参数；2) move_and_slide 后再基于最新碰撞做状态切换。
	if current_state == null:
		return
	velocity.y += gravity * delta * gravity_scale
	current_state.physics_update(delta)
	move_and_slide()
	change_state(current_state.physics_transition(delta))


func _unhandled_input(event: InputEvent) -> void:
	# 输入事件优先交由当前状态决定是否切换。
	if current_state == null:
		return
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
	state_label.text = current_state.name
	current_state.enter()


func change_state(new_state: PlayerState) -> void:
	# 空状态或重复状态不切换。
	if new_state == null or new_state == current_state:
		return

	# 先退出旧状态，再进入新状态，保证生命周期顺序稳定。
	if current_state != null:
		current_state.exit()
		_record_state_history(current_state)

	current_state = new_state
	current_state.enter()
	state_label.text = current_state.name


func get_history_state(level: int = HISTORY_LEVEL_START) -> PlayerState:
	# level=1 表示上一个状态，level=2 表示上上个状态，以此类推。
	if level < HISTORY_LEVEL_START:
		push_warning("State history level must be >= 1.")
		return null

	var history_index: int = level - HISTORY_LEVEL_START
	if history_index >= state_history.size():
		return null
	return state_history[history_index]


func is_history_state(state: PlayerState, level: int = HISTORY_LEVEL_START) -> bool:
	# 便捷判断：检查指定层级的历史状态是否等于目标状态。
	if state == null:
		return false
	return get_history_state(level) == state


func get_state_history_count() -> int:
	# 返回当前已记录的历史条目数量。
	return state_history.size()


func get_state_history_snapshot(max_count: int = -1) -> Array[PlayerState]:
	# 返回历史快照副本，避免外部误改内部数组；可选限制返回数量。
	var snapshot: Array[PlayerState] = state_history.duplicate()
	if max_count < 0:
		return snapshot
	if max_count == 0:
		return []
	if max_count >= snapshot.size():
		return snapshot
	snapshot.resize(max_count)
	return snapshot


func clear_state_history() -> void:
	# 在关卡重置、角色复活等场景下可主动清空历史。
	state_history.clear()


func _record_state_history(state: PlayerState) -> void:
	if state == null:
		return

	state_history.push_front(state)
	var history_capacity: int = max(state_history_capacity, MIN_STATE_HISTORY_CAPACITY)
	if state_history.size() > history_capacity:
		state_history.resize(history_capacity)


func update_direction() -> void:
	# 统一通过输入映射读取二维方向输入。
	var x_axis: float = Input.get_axis("left", "right")
	var y_axis: float = Input.get_axis("up", "down")
	direction = Vector2(x_axis, y_axis)


func add_debug_jump_indicator(color: Color = Color.RED) -> void:
	# 关闭调试开关时不生成任何调试节点。
	if not debug_state_indicators:
		return

	# 生成临时调试标记，便于观察状态切换时机。
	var indicator := DEBUG_JUMP_INDICATOR.instantiate()
	get_tree().root.add_child(indicator)
	indicator.global_position = global_position
	indicator.modulate = color
	await get_tree().create_timer(DEBUG_INDICATOR_LIFETIME_SECONDS).timeout
	indicator.queue_free()
