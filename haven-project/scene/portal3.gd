extends Area2D

@export_file("*.tscn") var target_scene: String = "res://winlevel.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player") or body.has_method("respawn"):
		get_tree().change_scene_to_file(target_scene)
