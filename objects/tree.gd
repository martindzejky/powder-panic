extends Node2D

@export var sprite: Sprite2D
@export var chance_to_spawn = 0.7

func _ready():
  # Randomize the sprite in the sprite sheet
  sprite.frame = randi() % sprite.hframes
  sprite.flip_h = randf() < 0.5

  # Randomize the rotation a bit
  rotation += randf_range(-PI / 8, PI / 8)
