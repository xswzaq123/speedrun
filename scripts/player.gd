class_name Player extends RigidBody2D

# NOTE: dependencies
@onready var arrowAxis := $ArrowAxis as Node2D
@onready var arrowTip := $ArrowAxis/Arrow/ArrowMarker as Marker2D
@onready var groundCheck := $GroundCheck as Area2D

# NOTE: gravity vars
@export_group("Gravity")
@export var defaultGravity = 1.5
@export var gravityOnPeak = 2.3

# NOTE: bounce vars
@export_group("Bounce")
@export var defaultBounce = 0.8
@export var fallBounce = 0.04

# NOTE: jump vars
@export_group("Jump")
@export var jumpStrengthBar: TextureProgressBar
@export var minJumpStrength: float = 100
@export var maxJumpStrength: float = 1000
@export var jumpStrengthMultiplier: float = 10.0

# NOTE: arrow vars
@export_group("Arrow")
@export var arrowRotationSpeed := 2.0
@export var hideArrowOnJump: bool = false

# NOTE: debug vars
@export_group("Debug")
@export var debugVisible := false
@export var debug: Control


# NOTE: script vars
var velocity: Vector2
var arrowRotation: float:
  set(value):
    arrowRotation = clamp(value, -180, 0)

var jumpStrength: float = minJumpStrength:
  set(value):
    jumpStrength = clamp(value, minJumpStrength, maxJumpStrength)

func _ready() -> void:
  arrowRotation = arrowAxis.rotation_degrees

  # jump
  jumpStrengthBar.min_value = minJumpStrength
  jumpStrengthBar.max_value = maxJumpStrength
  jumpStrengthBar.value = jumpStrength

  # gravity
  gravity_scale = defaultGravity

  # ground check
  # groundCheck.body_entered.connect(handleGroundCheck.bind(true))
  # groundCheck.body_exited.connect(handleGroundCheck.bind(false))

func _process(_delta: float) -> void:
  if !debugVisible:
    $CanvasLayer/Debug.visible = false
  else:
    $CanvasLayer/Debug.visible = true
    debug.get_child(0).text = "isOnFloor: " + str(isOnFloor())
    debug.get_child(1).text = "isRising: " + str(isRising())
    debug.get_child(2).text = "isFalling: " + str(isFalling())
    debug.get_child(3).text = "Velocity: " + str("x: %.02f y: %.02f" % [velocity.x, velocity.y])

func _physics_process(_delta: float) -> void:
  if Input.is_action_pressed("moveLeft"):
    arrowRotation -= 1 * arrowRotationSpeed
    arrowAxis.rotation_degrees = arrowRotation

  if Input.is_action_pressed("moveRight"):
    arrowRotation += 1 * arrowRotationSpeed
    arrowAxis.rotation_degrees = arrowRotation

  if Input.is_action_pressed("jump"):
    jumpStrength += jumpStrengthMultiplier
    jumpStrengthBar.value = jumpStrength

  velocity = linear_velocity
  if isFalling():
    gravity_scale = gravityOnPeak
    physics_material_override.bounce = fallBounce
  if isOnFloor() or isRising():
    await get_tree().create_timer(0.2).timeout
    gravity_scale = defaultGravity
    physics_material_override.bounce = defaultBounce

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("jump") and isOnFloor():
      var dir := getDirection()
      # print_debug("Vector to {x: %.1f,y: %.1f}" % [dir.x, dir.y])
      apply_impulse(dir * jumpStrength)
      resetJumpStrength()

    if event.is_action_pressed("toggle_debug"):
      debugVisible = !debugVisible

func getDirection() -> Vector2:
  var from := self.global_position
  var to := arrowTip.global_position
  var direction := Vector2(from - to).normalized() * -1
  return direction

func resetJumpStrength() -> void:
  jumpStrength = minJumpStrength
  jumpStrengthBar.value = jumpStrength

func isRising() -> bool:
  return true if velocity.y < -0.5 else false

func isFalling() -> bool:
  return true if velocity.y > 0.5 else false

func isOnFloor() -> bool:
  return not isRising() and not isFalling()
