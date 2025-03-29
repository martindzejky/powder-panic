@tool
extends Node2D
class_name ChunkDebug

@export var chunk: Chunk:
  set(value):
    chunk = value
    update_configuration_warnings()

@onready var default_font = ThemeDB.fallback_font

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []

  if chunk == null:
    warnings.append("Chunk is not set")

  return warnings

func _process(_delta) -> void:
  if not Engine.is_editor_hint():
    return

  if chunk == null:
    return

  queue_redraw()

func _draw() -> void:
  if not Engine.is_editor_hint():
    return

  if chunk == null:
    return

  # Get the start and end points of the chunk
  var start_point = chunk.get_start_point()
  var start_angle = chunk.get_start_angle()
  var start_angle_rad = deg_to_rad(start_angle)
  var end_point = chunk.get_end_point()
  var end_angle = chunk.get_end_angle()
  var end_angle_rad = deg_to_rad(end_angle)

  var arrow_length = 40
  var offset = Vector2(0, -16)

  # Draw an arrows
  draw_line(start_point, start_point + Vector2.LEFT.rotated(start_angle_rad) * arrow_length, Color.RED, 2)
  draw_line(end_point, end_point + Vector2.RIGHT.rotated(end_angle_rad) * arrow_length, Color.RED, 2)

  # Display the angles
  draw_string(default_font, start_point + offset, str(start_angle) + '°', HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.RED)
  draw_string(default_font, end_point + offset, str(end_angle) + '°', HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.RED)
