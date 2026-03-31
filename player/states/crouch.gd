class_name PlayStateCrouch extends PlayerState

# 松开下方向到该阈值以下时尝试起身。
const STAND_UP_INPUT_THRESHOLD: float = 0.5

@export var deceleration_rate: float = 500.0
@export var one_way_drop_distance: float = 1.0


func init() -> void:
	# 预留初始化入口：后续可扩展为滑铲/匍匐等能力配置。
	pass

func enter() -> void:
	# 进入 Crouch：启用矮碰撞体，禁用站立碰撞体。
	player.collision_stand.disabled = true
	player.collision_crouch.disabled = false


func exit() -> void:
	# 退出 Crouch：恢复站立碰撞体。
	player.collision_stand.disabled = false
	player.collision_crouch.disabled = true


func handle_input(event: InputEvent) -> PlayerState:
	# Crouch 中按跳跃：若脚下是单向平台则执行下落，否则正常起跳。
	if event.is_action_pressed("jump"):
		if player.one_way_platform_raycast.is_colliding():
			player.position.y += one_way_drop_distance
			return fall
		return jump
	return null


func process(_delta: float) -> PlayerState:
	# 只有在输入允许且头顶有空间时才回到 Idle，防止顶住天花板时强制起身。
	if player.direction.y <= STAND_UP_INPUT_THRESHOLD:
		return idle
	return null


func physics_update(delta: float) -> void:
	# 蹲下状态下水平速度逐步衰减，避免突然停住造成手感突兀。
	player.velocity.x = move_toward(player.velocity.x, 0.0, deceleration_rate * delta)


func physics_transition(_delta: float) -> PlayerState:
	# move_and_slide 后若离地则进入 Fall。
	if not player.is_on_floor():
		return fall
	return null
