extends Node
class_name SlopePhysics

@export var gravity = 200.0
@export var character: CharacterBody2D
@export var ground_friction = 0.01  # Lower = more slippery
@export var air_friction = 0.005     # Air resistance while jumping

func _physics_process(delta):
  if character.is_on_floor():
    # Get normalized floor normal
    var slope_normal = character.get_floor_normal()

    # Calculate the downslope direction (perpendicular to normal)
    var down_slope_direction = Vector2(-slope_normal.y, slope_normal.x)

    # Calculate how much gravity to apply based on the slope angle
    # steeper slope = more force (dot product with DOWN vector)
    var slope_factor = Vector2.DOWN.dot(down_slope_direction)

    # Apply the force to the player, scaled by the slope angle
    character.velocity += down_slope_direction * gravity * slope_factor * delta

    # Apply ground friction (stronger when going faster)
    var friction_force = character.velocity * ground_friction * character.velocity.length()
    character.velocity -= friction_force * delta
  else:
    # Apply gravity in air
    character.velocity.y += gravity * delta

    # Apply air resistance
    var air_resistance = character.velocity * air_friction * character.velocity.length()
    character.velocity -= air_resistance * delta

  # MOVE
  character.move_and_slide()
