class_name Player extends RigidBody2D

# NOTE: dependencies
@onready var arrowAxis := $ArrowAxis as Node2D
@onready var arrowTip := $ArrowAxis/Arrow/ArrowMarker as Marker2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var flashTimer: Timer = $FlashTimer
@onready var ray: RayCast2D = $RayCast2D
@onready var ray2: RayCast2D = $RayCast2D2
@onready var ray3: RayCast2D = $RayCast2D3

# NOTE: gravity vars
@export_group("Gravity")
@export var defaultGravity = 1.5
@export var gravityOnPeak = 3.0

# NOTE: bounce vars
@export_group("Bounce")
@export var defaultBounce = 0.8
@export var fallBounce = 0.04

# NOTE: bounce vars
@export_group("Friction")
@export var defaultFriction = 0.4
@export var noFriction = 0.0

# NOTE: jump vars
@export_group("Jump")
@export var jumpStrengthBar: TextureProgressBar
@export var minJumpStrength: float = 100
@export var maxJumpStrength: float = 1000
@export var jumpStrengthMultiplier: float = 600.0

# NOTE: arrow vars
@export_group("Arrow")
@export var arrowRotationSpeed := 150.0
@export var hideArrowOnJump: bool = false

# NOTE: debug vars
@export_group("Debug")
@export var debugVisible := false
@export var debug: Control


# NOTE: script vars
var velocity: Vector2
var canPush: bool = false
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

  Global.KnockBack.connect(knockBack)
  flashTimer.timeout.connect(revertFlash)

func _process(_delta: float) -> void:
  if !debugVisible:
    $CanvasLayer/Debug.visible = false
  else:
    $CanvasLayer/Debug.visible = true
    debug.get_child(0).text = "isOnFloor: " + str(isOnFloor())
    debug.get_child(1).text = "isRising: " + str(isRising())
    debug.get_child(2).text = "isFalling: " + str(isFalling())
    debug.get_child(3).text = "Velocity: " + str("x: %.02f y: %.02f" % [velocity.x, velocity.y])

func _physics_process(delta: float) -> void:
  if ray.is_colliding() or ray2.is_colliding()  or ray3.is_colliding():
    physics_material_override.bounce = fallBounce
    physics_material_override.friction = defaultFriction
  else:
    physics_material_override.friction = noFriction
    physics_material_override.bounce = defaultBounce


  if Input.is_action_pressed("moveLeft"):
    arrowRotation -= 1 * arrowRotationSpeed * delta
    arrowAxis.rotation_degrees = arrowRotation

  if Input.is_action_pressed("moveRight"):
    arrowRotation += 1 * arrowRotationSpeed * delta
    arrowAxis.rotation_degrees = arrowRotation

  if Input.is_action_pressed("jump"):
    anim.scale.y -= 0.5 * delta
    anim.scale.y = clamp(anim.scale.y, 0.1, 1)
    jumpStrength += jumpStrengthMultiplier * delta
    jumpStrengthBar.value = jumpStrength

  velocity = linear_velocity
  if isFalling():
    #physics_material_override.friction = defaultFriction
    gravity_scale = gravityOnPeak
    #physics_material_override.bounce = fallBounce
  if isOnFloor() or isRising():
    await get_tree().create_timer(0.2).timeout
    gravity_scale = defaultGravity
    #physics_material_override.bounce = defaultBounce
  #if isRising():
    #physics_material_override.friction = noFriction
  #if isOnFloor():
    #physics_material_override.friction = defaultFriction

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("jump") and isOnFloor():
      handleJump()

    if event.is_action_pressed("toggle_debug"):
      debugVisible = !debugVisible

func getDirection() -> Vector2:
  var from := self.global_position
  var to := arrowTip.global_position
  var direction := Vector2(from - to).normalized() * -1
  return direction

func handleJump() -> void:
  var dir := getDirection()
  # print_debug("Vector to {x: %.1f,y: %.1f}" % [dir.x, dir.y])
  apply_impulse(dir * jumpStrength)
  resetJumpStrength()

func resetJumpStrength() -> void:
  var scaleTween = create_tween()
  scaleTween.tween_property(anim, "scale", Vector2(1, 1), 0.1)
  jumpStrength = minJumpStrength
  jumpStrengthBar.value = jumpStrength

func isRising() -> bool:
  return true if velocity.y < -0.5 else false

func isFalling() -> bool:
  return true if velocity.y > 0.5 else false

func isOnFloor() -> bool:
  return not isRising() and not isFalling()

func knockBack(dir: Vector2, kbStr: float) -> void:
  flashTimer.start()
  anim.material.set_shader_parameter("progress", 0.8)
  apply_impulse(dir * kbStr)

func revertFlash() -> void:
  anim.material.set_shader_parameter("progress", 0.0)



