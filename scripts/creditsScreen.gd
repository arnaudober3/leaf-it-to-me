extends CanvasLayer

signal closed

const APPEAR_DURATION = 0.25
# Pixels per second the end titles scroll up
const ROLL_SPEED = 101.5
const LEAF_TEXTURE = preload("res://assets/leaf.png")
# Leaves fall from above the screen to below it
const LEAF_FALL = {
	"from": -258.0,
	"to": 1735.0
}
const LEAF_SWAY = 63.0
const LEAF_ROCK_ANGLE = 0.436 # 25 degrees each way
const LEAF_ROCK_DURATION = 3.2
# Offsets are in seconds, so the leaves do not move in step
const LEAVES = [
	{ "x": 554.0, "scale": 0.31, "fallDuration": 11.0, "fallOffset": 0.0, "rockOffset": 0.0, "swayDirection": 1.0 },
	{ "x": 111.0, "scale": 0.24, "fallDuration": 13.0, "fallOffset": 4.0, "rockOffset": 1.0, "swayDirection": -1.0 },
	{ "x": 369.0, "scale": 0.2, "fallDuration": 11.0, "fallOffset": 7.0, "rockOffset": 2.0, "swayDirection": 1.0 },
	{ "x": 628.0, "scale": 0.27, "fallDuration": 13.0, "fallOffset": 9.5, "rockOffset": 0.5, "swayDirection": -1.0 },
	{ "x": 222.0, "scale": 0.29, "fallDuration": 11.0, "fallOffset": 2.5, "rockOffset": 1.6, "swayDirection": 1.0 }
]

@onready var screen: Control = $Screen
@onready var leaves: Node2D = $Screen/Leaves
@onready var rollMask: Control = $Screen/RollMask
@onready var roll: Control = $Screen/RollMask/Viewport/Roll

var elapsed: float = 0.0
var isClosing: bool = false

func _ready() -> void:
	screen.gui_input.connect(onScreenInput)
	for leaf in LEAVES:
		var sprite = Sprite2D.new()
		sprite.texture = LEAF_TEXTURE
		sprite.scale = Vector2(leaf["scale"], leaf["scale"])
		leaves.add_child(sprite)

# Fades the screen in and starts the end titles from below the mask
func appear() -> void:
	visible = true
	isClosing = false
	roll.position.y = rollMask.size.y
	screen.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(screen, "modulate:a", 1.0, APPEAR_DURATION)

func close() -> void:
	if isClosing:
		return
	isClosing = true

	var tween = create_tween()
	tween.tween_property(screen, "modulate:a", 0.0, APPEAR_DURATION)
	await tween.finished
	visible = false
	closed.emit()

func _process(delta: float) -> void:
	if not visible:
		return

	elapsed += delta
	# Start over from the bottom once the last credit has left the top
	roll.position.y -= ROLL_SPEED * delta
	if roll.position.y < -roll.size.y:
		roll.position.y = rollMask.size.y

	for i in LEAVES.size():
		animateLeaf(leaves.get_child(i), LEAVES[i])

func animateLeaf(sprite: Sprite2D, leaf: Dictionary) -> void:
	var fall = fmod(elapsed + leaf["fallOffset"], leaf["fallDuration"]) / leaf["fallDuration"]
	var rock = (elapsed + leaf["rockOffset"]) / LEAF_ROCK_DURATION
	sprite.position = Vector2(
		leaf["x"] + sin(fall * TAU * 2) * LEAF_SWAY * leaf["swayDirection"],
		lerp(LEAF_FALL["from"], LEAF_FALL["to"], fall)
	)
	sprite.rotation = -cos(rock * TAU) * LEAF_ROCK_ANGLE

# Tapping anywhere closes the credits
func onScreenInput(event: InputEvent) -> void:
	var isPress = event is InputEventMouseButton or event is InputEventScreenTouch
	if isPress and event.pressed:
		close()

func onClosePressed() -> void:
	close()
