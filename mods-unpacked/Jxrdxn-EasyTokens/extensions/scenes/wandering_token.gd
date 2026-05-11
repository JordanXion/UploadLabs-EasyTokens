extends "res://scenes/wandering_token.gd"

const MOD_NAME := "Jxrdxn-EasyTokens"


func _get_config_value(key: String, fallback: Variant) -> Variant:
	var config := ModLoaderConfig.get_current_config(MOD_NAME)
	if config == null or not config.data.has(key):
		return fallback

	return config.data[key]


func _ready() -> void:
	if _get_config_value("auto_collect_tokens", false):
		claim()
		return

	scale = Vector2(0, 0)
	modulate.a = 0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 1, 0.2)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)

	position = Globals.camera_center + Vector2(-2000 + (randi() % 41) * 50, -2000 + (randi() % 41) * 50)
	position = position.clamp(Vector2(500, 500), Vector2(9500, 9500))

	Signals.create_pointer.emit($VisibleOnScreenNotifier2D)

	if !_get_config_value("mute_token_sound", true):
		Sound.play("popup")

	if _get_config_value("disable_token_despawn", true):
		var timeout_callable := Callable(self, "_on_timer_timeout")
		if $Timer.timeout.is_connected(timeout_callable):
			$Timer.timeout.disconnect(timeout_callable)


func claim() -> void:
	claimed = true

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 0, 0.2)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween.finished.connect(queue_free)

	var amount: float = 5 * Attributes.get_attribute("token_multiplier") * _get_config_value("token_value_multiplier", 10)
	Globals.currencies["token"] += amount
	Globals.stats.max_tokens += amount
	Globals.stats.tokens_collected += 1

	Signals.currency_popup.emit("token", amount)
	Signals.currency_popup_particle.emit("token", Utils.world_to_screen_pos(global_position))

	if !_get_config_value("mute_token_sound", true):
		Sound.play("claim")
