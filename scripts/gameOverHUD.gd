extends CanvasLayer

signal playAgainPressed
signal creditsPressed

const APPEAR_DURATION = 0.25
const CARD_START_SCALE = Vector2(0.9, 0.9)

@onready var screen: Control = $Screen
@onready var card: Control = $Screen/Card

# Fades the screen in with a small pop on the card
func appear() -> void:
	visible = true
	screen.modulate.a = 0.0
	card.scale = CARD_START_SCALE

	var tween = create_tween().set_parallel()
	tween.tween_property(screen, "modulate:a", 1.0, APPEAR_DURATION)
	tween.tween_property(card, "scale", Vector2.ONE, APPEAR_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func onPlayAgainPressed() -> void:
	playAgainPressed.emit()

func onCreditsPressed() -> void:
	creditsPressed.emit()
