extends CharacterBody2D

@export var current_speed = 800
@export var gravity = 1000.0
@export var slope_snap_distance = 1.0  # Distance to snap to slope
@export var jump_strength = 500.0

@export var sprite: Sprite2D

var slope_normal = Vector2.UP

func _physics_process(delta):
  if Input.is_action_just_pressed("jump") and is_on_floor():
    handle_jump()
  elif is_on_floor():
    handle_slope_movement()
  else:
    handle_air_movement(delta)

  move_and_slide()

  if !is_on_floor():
    snap_to_slope()

  if is_on_floor():
    slope_normal = get_floor_normal()
    update_sprite_rotation()

    # TODO: just for debug purposes
    sprite.modulate = Color.RED
  else:
    sprite.modulate = Color.GREEN

func handle_slope_movement():
  # Movement aligned with slope
  var slope_direction = slope_normal.rotated(PI/2)  # 90 degrees from normal
  velocity = slope_direction * current_speed

func handle_jump():
  velocity.y = -jump_strength

func handle_air_movement(delta):
  # Apply gravity to change direction
  velocity.y += gravity * delta

  # Normalize to maintain constant speed
  velocity = velocity.normalized() * current_speed

func update_sprite_rotation():
  # Rotate the sprite to match the slope
  sprite.rotation = slope_normal.angle() + PI / 2

func snap_to_slope():
  # Test movement downward
  var test_motion = Vector2(0, slope_snap_distance)
  var collision = move_and_collide(test_motion, true) # true = test only

  if collision:
    # We found a slope!
    slope_normal = collision.get_normal()

    # Move to the snap position
    velocity = test_motion
    move_and_slide()

    # Restore the proper velocity for next frame
    velocity = slope_normal.rotated(PI/2) * current_speed
