@tool
extends Node2D
class_name Chunk

@export var path: Path2D
@export var polygon: Polygon2D
@export var shape: CollisionPolygon2D

@export_tool_button('Snap angles') var snap_angles_button := snap_angles
@export_tool_button('Update shape') var update_shape_button := update_shape

const BOTTOM_OFFSET = 500

func _ready():
  # Do NOT run in the editor
  if Engine.is_editor_hint():
    return

  update_shape()

func update_shape():
  # Initialize the line and the shape collider based on the path curve
  var points := path.curve.tessellate(4, 2) # TODO: play with this value
  var polygon_points := points.duplicate()

  # Copy the line to the bottom of the polygon but in reverse order,
  # so we essentially get a super thick "line".
  var points_reversed := points.duplicate()
  points_reversed.reverse()

  for point in points_reversed:
    polygon_points.append(point + Vector2.DOWN * BOTTOM_OFFSET)

  # Assign the points to the line and the polygon
  polygon.polygon = polygon_points
  shape.polygon = polygon_points

  # Now generate the UV coordinates for the polygon.
  # Each point on the top line should be between 0,0 and 1,0 (left to right).
  # The points on the bottom line should be between 0,1 and 1,1 (left to right).
  var uv_points: PackedVector2Array = []
  var x_min = points[0].x
  var x_max = points[-1].x
  var texture_width = polygon.texture.get_width()
  var texture_height = polygon.texture.get_height()

  # UVs for the top line
  for point in points:
    uv_points.append(Vector2((point.x - x_min) / (x_max - x_min) * texture_width, 0))
    print(uv_points[-1])

  # UVs for the bottom line
  for point in points_reversed:
    uv_points.append(Vector2((point.x - x_min) / (x_max - x_min) * texture_width, texture_height))
    print(uv_points[-1])

  polygon.uv = uv_points

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
