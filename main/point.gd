extends Control

var cluster_id := -1

func _ready() -> void:
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	$PanelContainer.hide()


func _on_mouse_entered() -> void:
	$PanelContainer.show()
