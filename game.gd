extends Node2D

func _ready() -> void:
	$fade_transition/AnimationPlayer.play("fade_out")
