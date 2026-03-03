class_name MobBody extends CharacterBody3D

@export var speed: float = 2.0
@export var move_direction: float = -1.0 # -1 = left, 1 = right
@onready var mob_sprite: MobSprite = %MobSprite

var target_player: PlayerBody = null
var _hit: bool = false


func _ready() -> void:
	mob_sprite.hit_animation_ended.connect(_on_hit_animation_finished)

func _physics_process(delta: float) -> void:
	
	if _hit:
		return
	
	if target_player:

		# Direction toward player (ignore height difference)
		var direction: Vector3 = target_player.global_position - global_position
		direction.y = 0
		direction = direction.normalized()


		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0

	# Gravity
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	move_and_slide()


	_update_facing()
	_update_animation()
	
func _update_facing() -> void:
	if velocity.x > 0:
		mob_sprite.flip_h = false
	elif velocity.x < 0:
		mob_sprite.flip_h = true

func get_hit()->void:
	print("Get Hit called ")
	mob_sprite.is_hit()

func _on_hit_animation_finished()->void:
	_hit = false

func _update_animation() -> void:
	if not is_on_floor():
		mob_sprite.play("idle")
		return
	
	if abs(velocity.x) > 0.1:
		if mob_sprite.animation != "walk":
			mob_sprite.play("walk")
	else:
		if mob_sprite.animation != "idle":
			mob_sprite.play("idle")
