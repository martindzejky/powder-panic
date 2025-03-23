extends Node
class_name RotateSlopeSprite

@export var character: CharacterBody2D
@export var rotation_node: Node2D
@export var physics: SlopePhysics

func _physics_process(_delta):
  if physics.is_on_floor:
    rotation_node.rotation = physics.floor_normal.angle() + PI / 2
