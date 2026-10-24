extends Node2D

const Y_START = -96.0
const X_RANGE = {
	"min": 0.0,
	"max": 710.0
}
const ROTATION_RANGE = {
	"min": -1.5,
	"max": 1.5
}
# Bottom half of the screen, inside the walls
const INITIAL_PILE_AREA = { 
	"min": Vector2(0.0, 640.0),
	"max": Vector2(710.0, 1280.0)
}
# Consecutive rejected placements before the pile is considered full
const MAX_FAILED_ATTEMPTS = 300
# Seconds the yard must stay clear before the game is won
const CLEAR_HOLD_DURATION = 1.0

@onready var clearCheck = $ClearCheck
@onready var gameOverHUD = $GameOverHUD

var clearHoldElapsed: float = 0.0
var hasWon: bool = false

func _ready() -> void:
	createInitialLeaves()

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

func restart() -> void:
	get_tree().reload_current_scene()
	
func instanciateLeaf() -> void:
	var pos = Vector2(randf_range(X_RANGE["min"], X_RANGE["max"]), Y_START)
	var rot = randf_range(ROTATION_RANGE["min"], ROTATION_RANGE["max"])
	var leaf = Leaf.create(pos, rot)
	add_child(leaf)
	leaf.animate()

# Randomly places non-overlapping leaves at the bottom of the screen until area is full
func createInitialLeaves() -> void:
	var area = PackedVector2Array([
		INITIAL_PILE_AREA["min"],
		Vector2(INITIAL_PILE_AREA["max"].x, INITIAL_PILE_AREA["min"].y),
		INITIAL_PILE_AREA["max"],
		Vector2(INITIAL_PILE_AREA["min"].x, INITIAL_PILE_AREA["max"].y)
	])
	var shape = Leaf.getShape()
	var placedLeaves: Array[PackedVector2Array] = []
	var failures = 0
	
	while failures < MAX_FAILED_ATTEMPTS:
		var pos = Vector2(
			randf_range(INITIAL_PILE_AREA["min"].x, INITIAL_PILE_AREA["max"].x),
			randf_range(INITIAL_PILE_AREA["min"].y, INITIAL_PILE_AREA["max"].y)
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
