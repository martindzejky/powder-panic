@tool
extends Node2D
class_name ChunkDebug

@export var chunk: Chunk:
  set(value):
    chunk = value
    update_configuration_warnings()

@export var path: Path2D:
  set(value):
    path = value
    update_configuration_warnings()

@onready var default_font = ThemeDB.fallback_font

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []

  if chunk == null:
    warnings.append("Chunk is not set")

  if path == null:
    warnings.append("Path is not set")

  return warnings

func _process(_delta) -> void:
  if not Engine.is_editor_hint():
    return

  if chunk == null or path == null:
    return

  queue_redraw()

func _draw() -> void:
  if not Engine.is_editor_hint():
    return

  if chunk == null or path == null:
    return

  # Get the start and end points of the chunk
  var start_point = path.curve.get_point_position(0)
  var start_dir = path.curve.get_point_out(0)
  var end_point = path.curve.get_point_position(path.curve.get_point_count() - 1)
  var end_dir = path.curve.get_point_in(path.curve.get_point_count() - 1)

  # Draw an arrows
  draw_line(start_point, start_point - start_dir, Color.RED, 2)
  draw_line(end_point, end_point - end_dir, Color.RED, 2)

  # Display the angles
  var start_angle_rounded = calculate_start_angle(start_dir)
  var end_angle_rounded = calculate_end_angle(end_dir)
  var offset = Vector2(0, -16)

  draw_string(default_font, start_point + offset, str(start_angle_rounded) + '°', HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.RED)
  draw_string(default_font, end_point + offset, str(end_angle_rounded) + '°', HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.RED)

func calculate_start_angle(direction: Vector2) -> float:
  var angle = rad_to_deg(direction.angle())
  var angle_180 = fmod(angle + 180.0, 360.0) - 180.0
  return roundf(angle_180 * 100) / 100

func calculate_end_angle(direction: Vector2) -> float:
  var angle = rad_to_deg(direction.angle()) + 180.0
  var angle_180 = fmod(angle + 180.0, 360.0) - 180.0
  return roundf(angle_180 * 100) / 100