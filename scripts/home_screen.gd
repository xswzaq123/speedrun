extends Control

const MAIN_SCENE: String = "res://scenes/main.tscn"
@export var buttons: Array[Button] = []

func _ready() -> void:
  for button in buttons:
    match button.get_meta("action"):
      "play":
        play()
      "leaderboard":
          leaderboard()
      "quit":
        quit()
      _:
        pass

func quit() -> void:
  get_tree().quit()

func play() -> void:
  get_tree().change_scene_to_file(MAIN_SCENE)

func leaderboard() -> void:
  get_tree().change_scene_to_file(MAIN_SCENE)


