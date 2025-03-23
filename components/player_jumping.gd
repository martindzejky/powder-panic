extends Node
class_name PlayerJumping

@export var character: CharacterBody2D
@export var rotation_node: Node2D
@export var physics: SlopePhysics

var jump_force: float = 100.0
var backflip_rotation: float = deg_to_rad(140)
var auto_forward_rotation: float = deg_to_rad(40)

var time_in_air: float = 0.0


func _physics_process(delta):
  if physics.is_on_floor:
    time_in_air = 0.0
  else:
    time_in_air += delta

  if time_in_air < 0.3 and Input.is_action_just_pressed('jump'):
    character.velocity.y -= jump_force

    # Rotate the sprite back slightly
    rotation_node.rotation -= deg_to_rad(10)

  if not physics.is_on_floor:
    # When in air, perform backflip when the jump action is held, otherwise rotate forward
    if Input.is_action_pressed('jump'):
      rotation_node.rotation -= backflip_rotation * delta
    else:
      rotation_node.rotation += auto_forward_rotation * delta
