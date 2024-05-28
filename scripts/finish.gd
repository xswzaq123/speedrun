class_name Finish extends Area2D

func _ready() -> void:
  self.body_entered.connect(gameOver)

func gameOver(_body: Node2D) -> void:
  set_collision_mask_value(2, false)
  Global.GameOver.emit()
