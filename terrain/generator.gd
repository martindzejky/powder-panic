@tool
extends Node
class_name Generator

@export var chunks: Array[PackedScene]
@export var n_chunks_to_spawn: int = 1

@export_tool_button('Reset chunks') var reset_chunks_button = reset_chunks
@export_tool_button('Spawn chunk') var spawn_chunk_button = spawn_chunk
@export_tool_button('Spawn n chunks') var spawn_n_chunks_button = spawn_n_chunks

var min_chunks_in_game = 20
var chunk_instances: Array[Chunk] = []

func _ready():
  create_chunk_instances()
  ensure_minimum_chunks()

func _process(_delta):
  ensure_minimum_chunks()

func create_chunk_instances():
  # We need to pre-create all chunks so we can access their start and end angles
  for chunk in chunks:
    var chunk_instance = chunk.instantiate()
    chunk_instances.append(chunk_instance)

func ensure_minimum_chunks():
  # Do NOT run in the editor
  if Engine.is_editor_hint():
    return

  # Spawn chunks until we have at least min_chunks_in_game
  while get_child_count() < min_chunks_in_game:
    spawn_chunk()

func spawn_n_chunks():
  for _i in range(n_chunks_to_spawn):
    spawn_chunk()

func reset_chunks():
  # Delete all chunks except the first one
  for chunk in get_children():
    if chunk != get_child(0):
      chunk.queue_free()

func spawn_chunk():
  assert(get_child_count() > 0, 'The generator should always have at least one child chunk!')

  var current_chunk = get_child(-1)
  var last_chunk_end_angle = current_chunk.get_end_angle()

  if Engine.is_editor_hint():
    print('Spawning a new chunk after the last chunk "' + current_chunk.name + '" with end angle: ' + str(last_chunk_end_angle) + '°')

  # Filter which chunks match the last chunk's end angle
  var considered_chunks = []
  var matching_chunks = []

  # First collect all chunks with their angles
  for chunk in chunk_instances:
    considered_chunks.append([chunk.get_start_angle(), chunk])

  # Then find matching chunks
  for entry in considered_chunks:
    var angle = entry[0]
    var chunk = entry[1]
    if abs(angle - last_chunk_end_angle) < 0.1:
      matching_chunks.append(chunk)

  if matching_chunks.size() == 0:
    push_error('No chunks to spawn for the end angle: ' + str(last_chunk_end_angle) + '°')
    push_error('Considered chunks:')
    for entry in considered_chunks:
      push_error(str(entry[0]) + '°: ' + entry[1].name)

    # Crash the game
    assert(false, 'No chunks to spawn for the end angle: ' + str(last_chunk_end_angle) + '°')

  # Choose a random chunk from the array
  var new_chunk = matching_chunks.pick_random().duplicate()

  # Get the end point of the current chunk
  var last_point = current_chunk.get_end_point()

  # Add the new chunk as a child
  add_child(new_chunk)

  # In editor, we need to set the owner
  if Engine.is_editor_hint():
    new_chunk.owner = owner

  # Position the new chunk so that its start point aligns with the end point of the last chunk
  # This requires us to offset the new chunk by the difference between these points
  var start_point = new_chunk.get_start_point()
  new_chunk.position = current_chunk.position + last_point - start_point
