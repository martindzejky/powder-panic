extends Node
class_name SlopeAcceleration

@export var character: CharacterBody2D
@export var acceleration: float = 80.0
@export var physics: SlopePhysics

func _physics_process(delta):
  if physics.is_on_floor:
    character.velocity.x += acceleration * delta
