extends Node2D

@export var sprite: Sprite2D
@export var chance_to_spawn = 0.7
@export var random_rotation_range = PI / 14

func _ready():
  # Randomize the sprite in the sprite sheet
  sprite.frame = randi() % sprite.hframes
  sprite.flip_h = randf() < 0.5

  # Randomize the rotation a bit
  rotation += randf_range(-random_rotation_range, random_rotation_range)
