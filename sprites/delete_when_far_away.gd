extends Node
class_name DeleteWhenFarAway

@export var distance_to_delete = 10000
@export var what_to_delete: Node

func _process(_delta):
  var player = get_tree().get_first_node_in_group("player")
  if player:
    if what_to_delete.global_position.x < player.global_position.x - distance_to_delete:
      print("Deleting ", what_to_delete.name)
      print("Distance: ", what_to_delete.global_position.x - player.global_position.x)
      what_to_delete.queue_free()
