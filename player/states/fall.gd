class_name PlayStateFall extends PlayerState

# 离开下落状态后恢复到默认重力倍率。
const DEFAULT_GRAVITY_SCALE: float = 1.0

@export var coyote_time: float = 0.4
@export var fall_gravity_scale: float = 1.165
@export var jump_buffer_time: float = 0.2

var coyote_timer: float = 0.0
var buffer_timer: float = 0.0


func init() -> void:
	# 预留初始化入口：后续可扩展不同地形/能力下的下落参数。
	pass


func enter() -> void:
	# 下落阶段提升重力倍率，让手感更利落。
	player.gravity_scale = fall_gravity_scale
	# 如果刚从 Jump 进入 Fall，则不再给土狼时间；否则给予短暂补偿窗口。
	if player.is_history_state(jump):
		coyote_timer = 0.0
	else:
		coyote_timer = coyote_time
	# 每次进入 Fall 重置输入缓冲，避免跨状态残留。
	buffer_timer = 0.0


func exit() -> void:
	# 离开 Fall 后恢复默认重力倍率。
	player.gravity_scale = DEFAULT_GRAVITY_SCALE
	player.add_debug_jump_indicator(Color.RED)


func handle_input(event: InputEvent) -> PlayerState:
	# Fall 中按下跳跃：优先吃土狼时间，否则写入跳跃缓冲。
	if event.is_action_pressed("jump"):
		if coyote_timer > 0.0:
			return jump
		else:
			buffer_timer = jump_buffer_time
	return null


func process(delta: float) -> PlayerState:
	# 计时器只递减到 0，避免负值带来判断噪音。
	coyote_timer = max(coyote_timer - delta, 0.0)
	buffer_timer = max(buffer_timer - delta, 0.0)
	return null


func physics_update(_delta: float) -> void:
	# 空中持续应用横向控制。
	player.velocity.x = player.direction.x * player.move_speed


func physics_transition(_delta: float) -> PlayerState:
	# move_and_slide 后若落地，优先消费跳跃缓冲，否则回到 Idle。
	if player.is_on_floor():
		if buffer_timer > 0.0:
			return jump
		return idle
	return null
