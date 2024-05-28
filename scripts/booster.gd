class_name Booster extends Node2D

@onready var hurtbox: Area2D = $Hurtbox
@onready var animation: AnimationPlayer = $AnimationPlayer
@export var appearAfterTime: float = 0.8
var explodeEnded: bool

func _ready() -> void:
  hurtbox.body_entered.connect(boost)
  #animation.animation_finished.connect(reset)
  Global.PlayerGrounded.connect(setCollision)

func boost(body: RigidBody2D) -> void:
  var dir := (body.global_position - global_position).normalized()
  if dir.y < -0.1: return

  body.apply_impulse(body.linear_velocity.normalized() * 900)
  animation.play("explode")
  hurtbox.set_collision_mask_value(2, false)
  explodeEnded = true

#func reset(anim: StringName) -> void:
  #await get_tree().create_timer(appearAfterTime).timeout
  #if anim == "explode":
    #animation.play("reveal")
    #explodeEnded = true

func setCollision(grounded: bool) -> void:
  if grounded and explodeEnded:
    explodeEnded = false
    hurtbox.set_collision_mask_value(2, true)
    animation.play("reveal")

