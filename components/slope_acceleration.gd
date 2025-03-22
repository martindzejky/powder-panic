extends Node
class_name SlopeAcceleration

@export var character: CharacterBody2D
@export var acceleration: float = 80.0

func _physics_process(delta):
  if character.is_on_floor():
    character.velocity.x += acceleration * delta
