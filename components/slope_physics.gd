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
  is_on_floor = false
  floor_normal = Vector2.UP

  var remaining_motion = character.velocity * delta

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
