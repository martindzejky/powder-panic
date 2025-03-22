extends CharacterBody2D

@export var current_speed = 80
@export var gravity = 100.0
@export var jump_strength = 50.0
@export var rotation_speed = 3.2
@export var passive_rotation_speed = 0.3
@export var crash_tolerance = 1.3

@export var rotation_node: Node2D
@export var crash_timer: Timer

var slope_normal = Vector2.UP

var time_in_air = 0.0 # In seconds
var air_jump_time_limit = 0.3 # How long the player can be off the floor before still allowed to jump (coyote time)
var was_in_air = false # Tracks if player was in the air in the previous frame
var is_crashed = false # Tracks if the player has crashed

func _physics_process(delta):
  if is_crashed:
    handle_crashed()
    return

  if Input.is_action_just_pressed('jump') and time_in_air < air_jump_time_limit:
    handle_jump()
  elif is_on_floor():
    handle_slope_movement(delta)
  else:
    handle_air_movement(delta)

  move_and_slide()

  # Check for landing
  if was_in_air and is_on_floor():
    on_landed()

  if is_on_floor():
    slope_normal = get_floor_normal()
    update_floor_rotation()
    time_in_air = 0.0
    was_in_air = false
  else:
    time_in_air += delta
    update_air_rotation(delta)
    was_in_air = true

func handle_jump():
  velocity.y -= jump_strength

  # Normalize to maintain constant speed
  velocity = velocity.normalized() * current_speed

  # Rotate the sprite back slightly
  rotation_node.rotation = slope_normal.angle() + PI / 2 - 0.2

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

func update_floor_rotation():
  # Rotate the sprite to match the slope
  rotation_node.rotation = slope_normal.angle() + PI / 2

func update_air_rotation(delta):
  if Input.is_action_pressed('jump'):
    rotation_node.rotation -= rotation_speed * delta
  else:
    rotation_node.rotation += passive_rotation_speed * delta

func on_landed():
  # This will be called when the player lands on the ground
  var proper_landing_angle = slope_normal.angle() + PI / 2
  var current_angle = rotation_node.rotation

  # Normalize angles for comparison
  current_angle = wrapf(current_angle, -PI, PI)
  proper_landing_angle = wrapf(proper_landing_angle, -PI, PI)

  # Calculate the difference between angles
  var angle_diff = abs(current_angle - proper_landing_angle)
  if angle_diff > PI:
    angle_diff = 2 * PI - angle_diff

  # If the difference is too large, the player has is_crashed
  if angle_diff > crash_tolerance:
    crash()

func crash():
  # Handle the crash scenario
  is_crashed = true
  crash_timer.start()

func handle_crashed():
  # Rotate the player upside down while is_crashed
  rotation_node.rotation = slope_normal.angle() - PI / 2

  # Stop the player
  velocity = Vector2.ZERO
  move_and_slide()

func _on_crash_timer_timeout():
  is_crashed = false
  # Reset player rotation
  rotation_node.rotation = slope_normal.angle() + PI / 2
