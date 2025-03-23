extends Node
class_name SlopePhysics

@export var character: CharacterBody2D

var gravity = 200.0
var ground_friction = 0.02
var air_friction = 0.007

var is_on_floor = false
var floor_normal = Vector2.UP
var time_in_air = 0.0

func _physics_process(delta):
  apply_physics(delta)
  handle_movement(delta)

func apply_physics(delta):
  if is_on_floor:
    # Calculate the downslope direction (perpendicular to normal)
    var down_slope_direction = Vector2(-floor_normal.y, floor_normal.x)

    # Calculate how much gravity to apply based on the slope angle
    # steeper slope = more force (dot product with DOWN vector)
    var slope_factor = Vector2.DOWN.dot(down_slope_direction)

    # Apply the force to the player, scaled by the slope angle
    character.velocity += down_slope_direction * gravity * slope_factor * delta

    # Apply ground friction (stronger when going faster)
    var friction_force = character.velocity * ground_friction * character.velocity.length()
    character.velocity -= friction_force * delta

    # Reset time in air
    time_in_air = 0.0
  else:
    # Apply gravity in air
    character.velocity.y += gravity * delta

    # Apply air resistance
    var air_resistance = character.velocity * air_friction * character.velocity.length()
    character.velocity -= air_resistance * delta

    # Track time in air
    time_in_air += delta

func handle_movement(delta):
  # Perform the movement with collision detection
  var collision = character.move_and_collide(character.velocity * delta)

  # Update floor state based on collision
  is_on_floor = false

  if collision:
    # Get collision normal
    floor_normal = collision.get_normal()

    # Calculate the slide direction
    var slide_velocity = character.velocity.slide(floor_normal)

    # Apply the sliding motion
    character.velocity = slide_velocity

    is_on_floor = true
    time_in_air = 0.0
  else:
    is_on_floor = false
    floor_normal = Vector2.UP
