extends Node
class_name RotateSlopeSprite

@export var character: CharacterBody2D
@export var rotation_node: Node2D
@export var physics: SlopePhysics

var smoothing_speed: float = 40.0

func _physics_process(delta):
  if physics.is_on_floor:
    var target_rotation = physics.floor_normal.angle() + PI / 2
    rotation_node.rotation = lerp_angle(rotation_node.rotation, target_rotation, smoothing_speed * delta)
