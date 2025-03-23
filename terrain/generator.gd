extends Node

@export var chunks: Array[PackedScene]

var min_chunks = 20
var current_chunk: Node2D

func _ready():
  current_chunk = get_child(0)
  ensure_minimum_chunks()

func _process(_delta):
  ensure_minimum_chunks()

func ensure_minimum_chunks():
  # Count current chunks (all children are assumed to be chunks)
  var chunk_count = get_child_count()

  # Spawn chunks until we have at least min_chunks
  while chunk_count < min_chunks:
    spawn_chunk()
    chunk_count += 1

func spawn_chunk():
  # Choose a random chunk from the array
  var new_chunk_scene = chunks.pick_random()
  var new_chunk = new_chunk_scene.instantiate()

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
