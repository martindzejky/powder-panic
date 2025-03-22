extends Node
class_name RotateSlopeSprite

@export var character: CharacterBody2D
@export var rotation_node: Node2D

func _physics_process(_delta):
  if character.is_on_floor():
    rotation_node.rotation = character.get_floor_normal().angle() + PI / 2
