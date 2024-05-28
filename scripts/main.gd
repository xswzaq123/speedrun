extends Node2D

@onready var timeLabel: Timer = $CanvasLayer/Label

func _ready() -> void:
  timer.timeout.connect(time)

func _process(_delta: float) -> void:
  var timeElapsed := Time.get_ticks_msec() / 1000.0
  timeLabel.text = str(timeElapsed)

