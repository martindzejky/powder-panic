extends Node
class_name SlopePhysics

@export var character: CharacterBody2D

var gravity = 200.0
var ground_friction = 0.01
var air_friction = 0.007
var max_slides = 5

var is_on_floor = false
var floor_normal = Vector2.UP
var time_in_air = 0.0

func _physics_process(delta):
  apply_physics(delta)
  handle_movement(delta)

func apply_physics(delta):
  # Apply gravity
  character.velocity.y += gravity * delta

  if is_on_floor:
    # Apply ground friction (stronger when going faster)
    var friction_force = character.velocity * ground_friction * character.velocity.length()
    character.velocity -= friction_force * delta

    # Reset time in air
    time_in_air = 0.0
  else:
    # Apply air resistance
    var air_resistance = character.velocity * air_friction * character.velocity.length()
    character.velocity -= air_resistance * delta

    # Track time in air
    time_in_air += delta

func handle_movement(delta):
  var was_on_floor = is_on_floor
  var original_velocity = character.velocity
  var remaining_motion = character.velocity * delta

  is_on_floor = false

  for i in range(max_slides):
    # Stop if no more meaningful motion left
    if remaining_motion.is_zero_approx():
      break

    var collision = character.move_and_collide(remaining_motion)

    if not collision:
      # No collision, we're done
      break

    # Get collision normal and update floor status
    floor_normal = collision.get_normal()
    is_on_floor = true

    # Calculate remaining motion after slide
    remaining_motion = collision.get_remainder().slide(floor_normal)

    # Update velocity for next frame
    character.velocity = character.velocity.slide(floor_normal)

  # If not on floor after movement, try snapping to the floor
  if was_on_floor and not is_on_floor and original_velocity.y > 0:
    # Dynamic snap distance based on velocity magnitude and gravity
    var snap_vector = Vector2.DOWN * character.velocity.length() * delta
    var snap_collision = character.move_and_collide(snap_vector, true)

    if snap_collision:
      # Found floor beneath us, snap to it
      character.position += snap_vector.normalized() * snap_collision.get_travel()
      floor_normal = snap_collision.get_normal()
      is_on_floor = true

      # Align velocity with the floor
      character.velocity = character.velocity.slide(floor_normal)
