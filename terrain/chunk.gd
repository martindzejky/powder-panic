extends Node2D
class_name Chunk

@export var path: Path2D
@export var line: Line2D
@export var shape: CollisionPolygon2D

const BOTTOM_OFFSET = 1000

func _ready():
  # Initialize the line and the shape collider based on the path curve
  var points := path.curve.tessellate(4, 2) # TODO: play with this value
  var polygon_points = points.duplicate()

  line.points = points

  # Add 2 bottom points to the shape collider to make it a closed polygon.
  # Let's make it BOTTOM_OFFSET units below the last point.
  polygon_points.append(points[-1] + Vector2.DOWN * BOTTOM_OFFSET)
  polygon_points.append(points[0] + Vector2.DOWN * BOTTOM_OFFSET)

  shape.polygon = polygon_points

func get_start_point():
  return path.curve.get_point_position(0)

func get_end_point():
  return path.curve.get_point_position(path.curve.get_point_count() - 1)
