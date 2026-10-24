class_name Leaf
extends RigidBody2D

const SCENE_PATH = "res://scenes/leaf.tscn"
const SPRITE_HEIGHT: int = 192
const LINEAR_VELOCITY = {
	"from" = {
		"min": -150.0,
		"max": 150.0
	},
	"to" = {
		"min": 50.0,
		"max": 150.0
	}
}
const ANGULAR_VELOCITY = {
	"min": -2.0,
	"max": 2.0
}

var isDragging: bool = false
var screenSize: Vector2
var collisionLayer: int
var collisionMask: int

func _ready() -> void:
	screenSize = get_viewport_rect().size
	collisionLayer = collision_layer
	collisionMask = collision_mask

static func create(pos: Vector2, rot: float) -> Leaf:
	var leaf = load(SCENE_PATH).instantiate()
	leaf.position = pos
	leaf.rotation = rot
	
	return leaf
	
static func getShape() -> PackedVector2Array:
	# Instanciate a leaf then release it, in order to get the shape
	var leaf = load(SCENE_PATH).instantiate()
	var shape = leaf.get_node("Collision").polygon
	
	leaf.free()
	
	return shape

func animate() -> void:
	var linearVelocityFrom = randf_range(LINEAR_VELOCITY["from"]["min"], LINEAR_VELOCITY["from"]["max"])
	var linearVelocityTo = randf_range(LINEAR_VELOCITY["to"]["min"], LINEAR_VELOCITY["to"]["max"])
	linear_velocity = Vector2(linearVelocityFrom, linearVelocityTo)
	angular_velocity = randf_range(ANGULAR_VELOCITY["min"], ANGULAR_VELOCITY["max"])

# Function called when the sprite itself has an user input
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	var isLeftMouseClick = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
	var isTouch = event is InputEventScreenTouch
	if (not isLeftMouseClick and not isTouch):
		return
	if not event.pressed:
		return
		
	isDragging = true
	freeze = true # Temporarly disable gravity/movement for the drag to be smooth
	# Pass through the other leaves while dragged instead of shoving them around
	collision_layer = 0
	collision_mask = 0

# Function called whenever there is an input on the screen
func _input(event: InputEvent) -> void:
	if not isDragging:
		return
	
	var isMouseEvent = event is InputEventMouseButton
	var isTouchEvent = event is InputEventScreenTouch
	if ((isMouseEvent or isTouchEvent) and not event.pressed):
		release()
		return
	
	var target_pos = getNewPosition(event)
	if (target_pos == Vector2.INF): # Non relevant event 
		return
	
	global_position = target_pos

func getNewPosition(event: InputEvent) -> Vector2:
	var target_pos: Vector2
	if event is InputEventMouseMotion:
		target_pos = get_global_mouse_position()
	elif event is InputEventScreenDrag:
		target_pos = event.position
	else:
		return Vector2.INF # Invalid value if the event is not relevant
	
	var spriteHalfHeight = SPRITE_HEIGHT / 2
	var maxHeight = screenSize.y - spriteHalfHeight
	target_pos.y = clamp(target_pos.y, spriteHalfHeight, maxHeight) # Does not allow to go under the screen size
	
	return target_pos	

func release() -> void:
	isDragging = false
	collision_layer = collisionLayer
	collision_mask = collisionMask
	if isOutOfBounds():
		queue_free() # Sprite is destroyed as not on the screen anymore
	else:
		freeze = false # Case if the sprite is released somewhere on the screen
	

func isOutOfBounds() -> bool:
	var viewport = get_viewport_rect()
	return not viewport.has_point(global_position); # Sprite is not on the viewport
