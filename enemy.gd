extends Node2D

@export var word: String = ""
var typed_letters: int = 0
var speed := 100.0

@onready var label = $RichTextLabel

func _ready():
	label.bbcode_enabled = true
	label.text = word
	add_to_group("Enemies")

func _physics_process(delta):
	position.x -= speed * delta

func type_letter(letter: String) -> bool:
	if typed_letters < word.length() and word[typed_letters].to_lower() == letter.to_lower():
		typed_letters += 1

		label.text = "[color=green]" + word.substr(0, typed_letters) + "[/color]" + word.substr(typed_letters)

		return typed_letters == word.length()

	return false

func set_focused(focused: bool):
	if focused:
		modulate = Color(1, 1, 1, 1)  # Normal brightness
	else:
		modulate = Color(0.5, 0.5, 0.5, 1)  # Dimmed to show not focused
