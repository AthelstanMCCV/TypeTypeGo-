extends Area2D

signal game_over

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.name.begins_with("Enemy") or body.is_in_group("Enemies"):
		print("Enemy touched wall — Game Over!")
		emit_signal("game_over")
