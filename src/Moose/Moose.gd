extends KinematicBody2D

signal request_screen_shake

export(float) var Max_Speed = 0
export(float) var Acc_and_Fric = 0 # Not traditional (Applied to input instead of velocity)
export(float) var Dash_Speed = 0

export(float) var Max_Jump_Height = 0
export(float) var Min_Jump_Height = 0
export(float) var Max_Fall_Speed = 0
export(float) var Gravity_Scaler = 1
export(float) var Jump_Duration = 0.0
export(float) var Coyote_Timer_Duration = 0.0

var camera_origin = Vector2.ZERO

var Max_Jump_Speed = 0
var Min_Jump_Speed = 0
var Is_Jumping = false

var Is_Dashing = false
var dash_velocity = Vector2.ZERO

var coyote_timer = Timer.new()

var input_vector: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var gravity = 0

onready var sprite = $Sprite
onready var cam_pivot = $CameraPosition2D
onready var anim_player = $AnimationPlayer

onready var swipe_detector = $SwipeDetector
onready var accelerometer = $Accelerometer
onready var dash_timer = $DashTimer
onready var dash_cool_down = $DashCoolDown

func _ready() -> void:
	gravity = Gravity_Scaler * Max_Jump_Height / pow(max(Jump_Duration, 0.00000001), 2)
	Max_Jump_Speed = -sqrt(2 * gravity * Max_Jump_Height)
	Min_Jump_Speed = -sqrt(2 * gravity * Min_Jump_Height)
	
	coyote_timer.one_shot = true
	coyote_timer.wait_time = Coyote_Timer_Duration
	add_child(coyote_timer)
	camera_origin = cam_pivot.position

func _physics_process(delta: float) -> void:
	if !Is_Dashing:
		get_input(delta)
		update_anims(delta)
		
		apply_x_input(delta)
		apply_gravity(delta)
		
		move(delta)
	else:
		dash_velocity = move_and_slide(dash_velocity, Vector2.UP)

func update_anims(delta):
	if input_vector.length() > 0:
		anim_player.play("move")
		if input_vector.x != 0:
			sprite.flip_h = input_vector.x < 0
	else:
		anim_player.play("idle")

func get_input(delta: float) -> void:
	if not Input.get_accelerometer():
		input_vector.x = move_toward(input_vector.x, int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")), Acc_and_Fric * delta)
	
	if Input.is_action_just_pressed("dash"):
		if input_vector.x != 0 and dash_cool_down.time_left <= 0:
			dash(sign(input_vector.x))
	
	if Input.is_action_just_pressed("space"):
		jump()
	
	if Input.is_action_just_released("space"):
		check_for_stopped_jumping()

func apply_gravity(delta):
	if coyote_timer.is_stopped():
		velocity.y = move_toward(velocity.y, Max_Fall_Speed, gravity * delta)
		if velocity.y >= 0:
			Is_Jumping = false

func apply_x_input(delta):
	velocity.x = input_vector.x * Max_Speed
	cam_pivot.position = cam_pivot.position.move_toward(camera_origin * (input_vector + Vector2(0,1)), delta * Acc_and_Fric * 2)

func move(delta):
	var was_on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if not is_on_floor() and was_on_floor and not Is_Jumping:
		coyote_timer.start()
		velocity.y = 0

func dash(direction: int) -> void:
	Is_Dashing = true
	velocity = Vector2.ZERO
	dash_velocity.x = direction * Dash_Speed
	dash_timer.start()

func jump(speed: float = Max_Jump_Speed) -> void:
	if is_on_floor() || not coyote_timer.is_stopped():
		coyote_timer.stop()
		velocity.y = speed
		Is_Jumping = true
	if is_on_wall() && not is_on_floor() && velocity.y > Min_Jump_Speed:
		coyote_timer.stop()
		velocity.y = speed
		Is_Jumping = true

func check_for_stopped_jumping():
	if velocity.y < Min_Jump_Speed:
			velocity.y = Min_Jump_Speed

func touch_jump(jump_speed_ratio = 1.0, custom_speed = Max_Jump_Speed) -> void:
	if is_on_floor() || not coyote_timer.is_stopped():
		coyote_timer.stop()
		velocity.y = clamp(custom_speed * jump_speed_ratio, Min_Jump_Speed, Max_Jump_Speed)
		Is_Jumping = true
	if is_on_wall() && not is_on_floor() && velocity.y > Min_Jump_Speed:
		coyote_timer.stop()
		velocity.y = clamp(custom_speed * jump_speed_ratio, Min_Jump_Speed, Max_Jump_Speed)
		Is_Jumping = true

func die():
	queue_free()

func _on_Stats_health_is_gone() -> void:
	die()

func _on_SwipeDetector_swiped(direction, length_ratio) -> void:
	if direction == Vector2.UP:
		touch_jump(length_ratio)
	
	if direction.x != 0 && input_vector.x != 0 \
	and dash_cool_down.time_left <= 0:
		dash(sign(direction.x))

func _on_Accelerometer_tilt_detected_on_x_axis(acceleration) -> void:
	if Input.get_accelerometer() != Vector3.ZERO:
		input_vector.x = acceleration

func _on_DashTimer_timeout() -> void:
	dash_velocity = Vector2.ZERO
	dash_cool_down.start()

func _on_DashCoolDown_timeout() -> void:
	Is_Dashing = false
