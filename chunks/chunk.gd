@tool
extends Node2D
class_name Chunk

@export var path: Path2D
@export var line: Line2D
@export var polygon: Polygon2D
@export var shape: CollisionPolygon2D

@export_tool_button('Snap angles') var snap_angles_button := snap_angles

const BOTTOM_OFFSET = 500

func _ready():
  update_shape()

func update_shape():
  # Do NOT run in the editor
  if Engine.is_editor_hint():
    return

  # Initialize the line and the shape collider based on the path curve
  var points := path.curve.tessellate(4, 2) # TODO: play with this value
  var polygon_points = points.duplicate()

  # Add 2 bottom points to the shape collider to make it a closed polygon.
  # Let's make it BOTTOM_OFFSET units below the last point.
  polygon_points.append(points[-1] + Vector2.DOWN * BOTTOM_OFFSET)
  polygon_points.append(points[0] + Vector2.DOWN * BOTTOM_OFFSET)

  line.points = points
  polygon.polygon = polygon_points
  shape.polygon = polygon_points

func get_start_point():
  return path.curve.get_point_position(0)

func get_start_angle():
  var start_dir = path.curve.get_point_out(0)
  var start_angle = rad_to_deg(start_dir.angle())
  var start_angle_180 = fmod(start_angle + 180.0, 360.0) - 180.0
  return roundf(start_angle_180 * 100) / 100

func get_end_point():
  return path.curve.get_point_position(path.curve.get_point_count() - 1)

func get_end_angle():
  var end_dir = path.curve.get_point_in(path.curve.get_point_count() - 1)
  var end_angle = rad_to_deg(end_dir.angle()) + 180.0
  var end_angle_180 = fmod(end_angle + 180.0, 360.0) - 180.0
  return roundf(end_angle_180 * 100) / 100

func snap_angles():
  # This is a tool function which snaps both the start and end angles
  # of the chunk to the nearest 20 degree angle
  var start_dir = path.curve.get_point_out(0)
  var end_dir = path.curve.get_point_in(path.curve.get_point_count() - 1)

  # Current angles
  var start_angle = rad_to_deg(start_dir.angle())
  var end_angle = rad_to_deg(end_dir.angle())

  # Snapped angles
  var start_angle_snapped = roundf(start_angle / 20) * 20
  var end_angle_snapped = roundf(end_angle / 20) * 20

  # New directions
  var start_dir_new = Vector2.RIGHT.rotated(deg_to_rad(start_angle_snapped)) * start_dir.length()
  var end_dir_new = Vector2.RIGHT.rotated(deg_to_rad(end_angle_snapped)) * end_dir.length()

  # Update the path
  path.curve.set_point_out(0, start_dir_new)
  path.curve.set_point_in(path.curve.get_point_count() - 1, end_dir_new)
