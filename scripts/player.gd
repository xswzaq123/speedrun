class_name Player extends RigidBody2D

# NOTE: dependencies
@onready var arrowAxis := $ArrowAxis as Node2D
@onready var arrowTip := $ArrowAxis/Arrow/ArrowMarker as Marker2D
@onready var groundCheck := $GroundCheck as Area2D

# NOTE: gravity vars
@export var defaultGravity = 1.5
@export var gravityOnPeak = 2.3

# NOTE: jump vars
@export var jumpStrengthBar: ProgressBar
@export var minJumpStrength: float = 100
@export var maxJumpStrength: float = 1000
@export var jumpStrengthMultiplier: float = 10.0

# NOTE: arrow vars
@export_group("Arrow")
@export var arrowRotationSpeed := 2.0
@export var hideArrowOnJump: bool = false

# NOTE: script vars
var isOnFloor: bool
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
	groundCheck.body_entered.connect(handleGroundCheck.bind(true))
	groundCheck.body_exited.connect(handleGroundCheck.bind(false))

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

	var velocity = linear_velocity
	if velocity.y > 0:
		gravity_scale = gravityOnPeak
		physics_material_override.bounce = 0.1
	else:
		gravity_scale = defaultGravity
		physics_material_override.bounce = 0.4

func _unhandled_input(event: InputEvent) -> void:
		if event.is_action_released("jump") and isOnFloor:
			var dir := getDirection()
			# print_debug("Vector to {x: %.1f,y: %.1f}" % [dir.x, dir.y]) 
			apply_impulse(dir * jumpStrength)
			resetJumpStrength()

func getDirection() -> Vector2:
	var from := self.global_position
	var to := arrowTip.global_position
	var direction := Vector2(from - to).normalized() * -1
	return direction

func handleGroundCheck(_body: Node2D, isGrounded: bool) -> void:
	# set isOnFloor, true if colliding with floor else false
	# hide arrow on jump
	if hideArrowOnJump:
		arrowAxis.visible = true if isGrounded else false
	isOnFloor = isGrounded

func resetJumpStrength() -> void:
	jumpStrength = minJumpStrength
	jumpStrengthBar.value = jumpStrength

