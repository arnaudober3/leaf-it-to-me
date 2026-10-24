extends CanvasLayer

const RING_RADIUS = 78.0
const RING_WIDTH = 18.0
const RING_TRACK_COLOR = Color("#FBE3C8")
const RING_FILL_COLOR = Color("#C9561F")

@onready var ring: Panel = $Content/Ring

var progress: float = 0.0

func _ready() -> void:
	ring.draw.connect(drawRing)

# Shows the check with the ring filled from 0.0 to 1.0
func setProgress(value: float) -> void:
	progress = clamp(value, 0.0, 1.0)
	visible = true
	ring.queue_redraw()

func hideCheck() -> void:
	progress = 0.0
	visible = false

func drawRing() -> void:
	var center = ring.size / 2
	ring.draw_arc(center, RING_RADIUS, 0.0, TAU, 64, RING_TRACK_COLOR, RING_WIDTH, true)
	if progress <= 0.0:
		return

	var start = -PI / 2 # 12 o'clock
	var end = start + TAU * progress
	ring.draw_arc(center, RING_RADIUS, start, end, 64, RING_FILL_COLOR, RING_WIDTH, true)
	# Round caps on both ends of the filled arc
	ring.draw_circle(center + Vector2.from_angle(start) * RING_RADIUS, RING_WIDTH / 2, RING_FILL_COLOR, true, -1.0, true)
	ring.draw_circle(center + Vector2.from_angle(end) * RING_RADIUS, RING_WIDTH / 2, RING_FILL_COLOR, true, -1.0, true)
