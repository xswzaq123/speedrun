class_name Cactus extends Node2D

@onready var hurtbox: Area2D = $Hurtbox
@export var knockBackStrength := 900.0
@onready var timer: Timer = $Timer

func _ready() -> void:
  hurtbox.body_entered.connect(knockBack)
  timer.timeout.connect(enableCollision)

func knockBack(body: RigidBody2D) -> void:
  hurtbox.set_collision_mask_value(2, false)
  timer.start()
  var direction := body.global_position.x - global_position.x
  var dir: Vector2
  if direction > 0:
    dir = Vector2.RIGHT
  else:
    dir = Vector2.LEFT
  Global.KnockBack.emit(dir, knockBackStrength)

func enableCollision() -> void:
  hurtbox.set_collision_mask_value(2, true)
