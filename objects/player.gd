extends CharacterBody2D

@export var forward_speed = 300.0
@export var gravity = 1000.0
@export var max_fall_speed = 1000.0
@export var slope_snap_force = 200.0     # Force pushing player onto slopes
@export var max_slope_angle = 60.0

@export var sprite: Sprite2D

var slope_normal = Vector2.UP
var last_safe_normal = Vector2.UP

func _physics_process(delta):
  if is_on_floor():
    # Check if slope is too steep
    var slope_angle = abs(rad_to_deg(slope_normal.angle_to(Vector2.UP)))
    if slope_angle > max_slope_angle:
      # Too steep! Treat as air
      velocity.y += gravity * delta
      velocity.y = min(velocity.y, max_fall_speed)
      # Launch in a direction based on last good slope
      velocity = velocity.slide(last_safe_normal)
    else:
      # Safe slope, remember it
      last_safe_normal = slope_normal
      # Normal ground movement
      var desired_velocity = Vector2.RIGHT * forward_speed
      desired_velocity = desired_velocity.slide(slope_normal)
      desired_velocity += slope_normal * -slope_snap_force
      velocity = desired_velocity

  else:
    # In air - keep horizontal momentum and apply gravity
    velocity.y += gravity * delta
    velocity.y = min(velocity.y, max_fall_speed)

  move_and_slide()

  if is_on_floor():
    # Store the new slope normal if we're on ground
    slope_normal = get_floor_normal()

    # Rotate the sprite to match the slope
    sprite.rotation = slope_normal.angle() + PI / 2
