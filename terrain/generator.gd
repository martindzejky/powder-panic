extends Node

@export var chunks: Array[PackedScene]

var min_chunks = 20
var current_chunk: Node2D
var chunk_instances: Array[Chunk] = []

func _ready():
  assert(get_child_count() > 0, 'The generator should start with at least one child chunk!')

  current_chunk = get_child(0)
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
  # Count current chunks (all children are assumed to be chunks)
  var chunk_count = get_child_count()

  # Spawn chunks until we have at least min_chunks
  while chunk_count < min_chunks:
    spawn_chunk()
    chunk_count += 1

func spawn_chunk():
  var last_chunk_end_angle = current_chunk.get_end_angle()

  # Filter which chunks match the last chunk's end angle
  var matching_chunks: Array[Chunk] = chunk_instances.filter(func(chunk): return chunk.get_start_angle() == last_chunk_end_angle)
  assert(matching_chunks.size() > 0, 'No chunks to spawn for the end angle: ' + str(last_chunk_end_angle) + '°')

  # Choose a random chunk from the array
  var new_chunk = matching_chunks.pick_random().duplicate()

  # Get the end point of the current chunk
  var last_point = current_chunk.get_end_point()

  # Add the new chunk as a child
  add_child(new_chunk)

  # Position the new chunk so that its start point aligns with the end point of the last chunk
  # This requires us to offset the new chunk by the difference between these points
  var start_point = new_chunk.get_start_point()
  new_chunk.position = current_chunk.position + last_point - start_point

  # Update the current chunk reference
  current_chunk = new_chunk
