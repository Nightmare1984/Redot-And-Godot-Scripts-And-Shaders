extends Area3D

@export var audio_player: AudioStreamPlayer3D
@export var player: Node3D  # Add this to reference the player directly
var has_played = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body == player and not has_played:  # Check if the body is the player we specified
		if audio_player:
			audio_player.play()
			has_played = true
