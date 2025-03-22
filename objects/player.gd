extends CharacterBody2D

@export var current_speed = 800
@export var gravity = 1000.0
@export var jump_strength = 500.0

@export var sprite: Sprite2D

var slope_normal = Vector2.UP

var time_in_air = 0.0 # In seconds
var air_jump_time_limit = 0.3 # How long the player can be off the floor before still allowed to jump (coyote time)

func _physics_process(delta):
  if Input.is_action_just_pressed('jump') and time_in_air < air_jump_time_limit:
    handle_jump()
  elif is_on_floor():
    handle_slope_movement(delta)
  else:
    handle_air_movement(delta)

  move_and_slide()

  if is_on_floor():
    slope_normal = get_floor_normal()
    update_sprite_rotation()
    time_in_air = 0.0
  else:
    time_in_air += delta

func handle_jump():
  velocity.y = -jump_strength

  # Normalize to maintain constant speed
  velocity = velocity.normalized() * current_speed

func handle_slope_movement(delta):
  # Movement aligned with slope
  var slope_direction = slope_normal.rotated(PI/2)  # 90 degrees from normal
  velocity = slope_direction * current_speed

  # Add gravity to snap to slope
  velocity.y += gravity * delta

func handle_air_movement(delta):
  # Apply gravity to change direction
  velocity.y += gravity * delta

  # Normalize to maintain constant speed
  velocity = velocity.normalized() * current_speed

func update_sprite_rotation():
  # Rotate the sprite to match the slope
  sprite.rotation = slope_normal.angle() + PI / 2
