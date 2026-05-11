extends Node

const MOD_NAME : String = "Jxrdxn-EasyTokens"

func _init():
	ModLoaderLog.info("EasyTokens loaded!", MOD_NAME)
	install_script_extensions()


func install_script_extensions() -> void:
	ModLoaderMod.install_script_extension('res://mods-unpacked/Jxrdxn-EasyTokens/extensions/scenes/wandering_token.gd')
