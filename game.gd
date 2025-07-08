extends Node2D

func _trans() -> void:
	$fade_transition/AnimationPlayer.play("fade_out")

@export var enemy_scene: PackedScene
@export var word_list: Array[String] = ["apple", "ghost", "sword", "magic"]
@export var sprite_list: Array[Texture2D]
@export var spawn_y_lanes: Array[int] = [100, 200, 300, 400]

var enemies: Array[Node] = []
var current_input: String = ""
var used_words := {}  # Set to keep track of active words

@onready var spawn_timer := Timer.new()

func _ready():
	spawn_enemy()
	
	spawn_timer.wait_time = 2.0
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.timeout.connect(spawn_enemy)

func spawn_enemy():
	# Create a pool of available words (not currently used)
	var available_words = word_list.filter(func(w): return !used_words.has(w))

	if available_words.is_empty():
		print("No available unique words to spawn!")
		return

	var enemy = enemy_scene.instantiate()
	var screen_width = get_window().size.x
	var y = spawn_y_lanes.pick_random()

	enemy.global_position = Vector2(screen_width + 100, y)

	var new_word = available_words.pick_random()
	enemy.word = new_word
	used_words[new_word] = true  # Track as used

	if enemy.has_node("Sprite2D"):
		enemy.get_node("Sprite2D").texture = sprite_list.pick_random()

	enemy.speed = randf_range(80.0, 120.0)
	add_child(enemy)
	enemies.append(enemy)

func _contact():
	$Wall.connect("game_over", Callable(self, "_on_game_over"))
	
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(spawn_enemy)

	spawn_enemy()

func _on_game_over():
	get_tree().paused = true
	print("GAME OVER!")
	# You can also change scene, show UI, etc.
	
var current_enemy: Node = null

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		var char := OS.get_keycode_string(event.keycode).to_lower()

		# If no enemy is currently targeted, find one
		if current_enemy == null:
			for enemy in enemies:
				if enemy.word.begins_with(char):
					current_enemy = enemy

					for e in enemies:
						if e.has_method("set_focused"):
							e.set_focused(e == current_enemy)

					if current_enemy.has_method("type_letter"):
						var completed: bool = current_enemy.type_letter(char)

						# ✅ Typing sound
						if $TypeSound.playing:
							$TypeSound.stop()
						$TypeSound.play()

						if completed:
							# ✅ Defeat sound
							if $DefeatSound.playing:
								$DefeatSound.stop()
							$DefeatSound.play()

							used_words.erase(current_enemy.word)
							enemies.erase(current_enemy)
							current_enemy.queue_free()
							current_enemy = null
							spawn_enemy()

							for e in enemies:
								if e.has_method("set_focused"):
									e.set_focused(false)

					return

		# Already focused: normal typing
		elif current_enemy.has_method("type_letter"):
			var completed: bool = current_enemy.type_letter(char)

			# ✅ Typing sound
			if $TypeSound.playing:
				$TypeSound.stop()
			$TypeSound.play()

			if completed:
				# ✅ Defeat sound
				if $DefeatSound.playing:
					$DefeatSound.stop()
				$DefeatSound.play()

				used_words.erase(current_enemy.word)
				enemies.erase(current_enemy)
				current_enemy.queue_free()
				current_enemy = null
				spawn_enemy()

				for e in enemies:
					if e.has_method("set_focused"):
						e.set_focused(false)
