extends Node
class_name DeleteWhenFarAway

@export var what_to_delete: Node

var distance_to_delete = 1000

func _process(_delta):
  var player = get_tree().get_first_node_in_group("player")
  if player:
    if what_to_delete.global_position.x < player.global_position.x - distance_to_delete:
      what_to_delete.queue_free()
