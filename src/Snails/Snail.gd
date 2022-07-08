extends KinematicBody2D

enum TextureId {
	RED=0,
	GREEN=1,
	BLUE=2,
	YELLOW=3
}
enum Direction {
	LEFT=-1,
	RIGHT=1
}

export(TextureId) var Snail_Color = TextureId.RED
export(Direction) var Snail_Direction = Direction.RIGHT
export var speed : float = 40.0
export var snail_distance : float = 3

onready var floor_finder = $RayCast2D
onready var anim_player = $AnimationPlayer
onready var sprite = $PaletteSprite
onready var wall_detect = $WallDetector

const ray_cast_origin = 14

const gravity = 98.0
var velocity : Vector2 = Vector2.ZERO
var sign_d = 1

func _ready() -> void:
	sprite.Snail_Color = int(Snail_Color)
	
	sign_d = int(Snail_Direction)
	sprite.flip_h = sign_d == -1
	floor_finder.position.x = ray_cast_origin * sign(sign_d)
	wall_detect.position.x *= -1
	wall_detect.cast_to.x *= -1

func _physics_process(delta: float) -> void:
	velocity.y += 98.0 * delta
	velocity = move_and_slide(velocity)

func turn():
	sign_d *= -1
	floor_finder.position.x = ray_cast_origin * sign(sign_d)
	velocity.x = 0
	anim_player.play("turn")
	wall_detect.position.x *= -1
	wall_detect.cast_to.x *= -1

func move():
	velocity.x = sign_d * snail_distance/(0.430 - 0.350)

func move_done():
	velocity.x = 0

func _on_RayCastTimer_timeout() -> void:
	if !floor_finder.is_colliding() || wall_detect.is_colliding():
		turn()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "turn":
		sprite.flip_h = sign_d == -1
		anim_player.play("move")
		anim_player.seek(0, true) ## Fixes flicker
