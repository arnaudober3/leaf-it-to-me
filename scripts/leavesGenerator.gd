extends Node2D

const Y_START = -96.0
const WALL_THICKNESS = 57.0
const ROTATION_RANGE = {
	"min": -1.5,
	"max": 1.5
}
# Consecutive rejected placements before the pile is considered full
const MAX_FAILED_ATTEMPTS = 300
# Seconds the yard must stay clear before the game is won
const CLEAR_HOLD_DURATION = 1.0

@onready var clearCheck = $ClearCheck
@onready var gameOverHUD = $GameOverHUD
@onready var creditsScreen = $CreditsScreen
@onready var leftWall: CollisionShape2D = $Constraints/LeftWall
@onready var rightWall: CollisionShape2D = $Constraints/RightWall
@onready var bottomWall: CollisionShape2D = $Constraints/BottomWall

var clearHoldElapsed: float = 0.0
var hasWon: bool = false

func _ready() -> void:
	# The viewport expands to the device aspect ratio, so the yard follows its size
	layoutWalls()
	get_viewport().size_changed.connect(layoutWalls)
	createInitialLeaves()

# Places the walls just outside the left, right and bottom edges of the screen
func layoutWalls() -> void:
	var screenSize = get_viewport_rect().size
	var halfThickness = WALL_THICKNESS / 2
	leftWall.shape.size = Vector2(WALL_THICKNESS, screenSize.y)
	bottomWall.shape.size = Vector2(screenSize.x + WALL_THICKNESS * 2, WALL_THICKNESS)
	leftWall.position = Vector2(-halfThickness, screenSize.y / 2)
	rightWall.position = Vector2(screenSize.x + halfThickness, screenSize.y / 2)
	bottomWall.position = Vector2(screenSize.x / 2, screenSize.y + halfThickness)

func _process(delta: float) -> void:
	if hasWon:
		return

	if not isYardClear():
		clearHoldElapsed = 0.0
		clearCheck.hideCheck()
		return

	clearHoldElapsed += delta
	clearCheck.setProgress(clearHoldElapsed / CLEAR_HOLD_DURATION)
	if clearHoldElapsed >= CLEAR_HOLD_DURATION:
		win()

# Leaves still falling above the screen do not count until they enter it
func isYardClear() -> bool:
	for child in get_children():
		if child is Leaf and (child.isDragging or not child.isOutOfBounds()):
			return false

	return true

func win() -> void:
	hasWon = true
	$FallingLeavesTimer.stop()
	# Leaves still falling above the screen would otherwise drop in behind the win screen
	for child in get_children():
		if child is Leaf:
			child.queue_free()
	clearCheck.hideCheck()
	gameOverHUD.appear()

# The win card is hidden so it does not show through the credits
func openCredits() -> void:
	gameOverHUD.visible = false
	creditsScreen.appear()

func closeCredits() -> void:
	gameOverHUD.appear()

func restart() -> void:
	get_tree().reload_current_scene()
	
func instanciateLeaf() -> void:
	var pos = Vector2(randf_range(0.0, get_viewport_rect().size.x), Y_START)
	var rot = randf_range(ROTATION_RANGE["min"], ROTATION_RANGE["max"])
	var leaf = Leaf.create(pos, rot)
	add_child(leaf)
	leaf.animate()

# Randomly places non-overlapping leaves at the bottom of the screen until area is full
func createInitialLeaves() -> void:
	# Bottom half of the screen, inside the walls
	var screenSize = get_viewport_rect().size
	var pileMin = Vector2(0.0, screenSize.y / 2)
	var pileMax = screenSize
	var area = PackedVector2Array([
		pileMin,
		Vector2(pileMax.x, pileMin.y),
		pileMax,
		Vector2(pileMin.x, pileMax.y)
	])
	var shape = Leaf.getShape()
	var placedLeaves: Array[PackedVector2Array] = []
	var failures = 0
	
	while failures < MAX_FAILED_ATTEMPTS:
		var pos = Vector2(
			randf_range(pileMin.x, pileMax.x),
			randf_range(pileMin.y, pileMax.y)
		)
		var rot = randf_range(ROTATION_RANGE["min"], ROTATION_RANGE["max"])
		var candidate = Transform2D(rot, pos) * shape
		
		if isInsideArea(candidate, area) and not isOverlapping(candidate, placedLeaves):
			var leaf = Leaf.create(pos, rot)
			add_child(leaf)
			leaf.animate()
			placedLeaves.append(candidate)
			
			failures = 0
		else:
			failures += 1

func isInsideArea(sprite: PackedVector2Array, area: PackedVector2Array) -> bool:
	return Geometry2D.clip_polygons(sprite, area).is_empty() 

func isOverlapping(sprite: PackedVector2Array, placedSprites: Array[PackedVector2Array]) -> bool:
	for placedSprite in placedSprites:
		if not Geometry2D.intersect_polygons(sprite, placedSprite).is_empty():
			return true
	
	return false
