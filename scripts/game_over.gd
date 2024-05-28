class_name GameOver extends Control

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var timeLabel: RichTextLabel = $Node2D/Label2
@onready var btn1: Button = $Node2D2/Button
@onready var btn2: Button = $Node2D2/Button2


var finishTime: String = ""

func _ready() -> void:
  btn1.scale = Vector2(1.5, 1.5)
  btn2.scale = Vector2(1.5, 1.5)
  print(btn1.theme)
  timeLabel.text = "[center]Your Time: %s [/center]" % finishTime
  position.y = -500.0
  modulate.a = 0.0
  var tween = create_tween()
  tween.set_parallel(true)
  tween.tween_property(self, "position", Vector2(0, 0), 0.2)
  tween.tween_property(self, "modulate:a", 1.0, 0.3)
  tween.set_parallel(false)
  await tween.finished
  animator.play("pop")
  await animator.animation_finished
  #tween.tween_property(btn1, "scale", Vector2(1, 1), 0.3)
  #tween.tween_property(btn2, "scale", Vector2(1, 1), 0.3)
  #await tween.finished
  #tween.stop()


