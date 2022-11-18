extends Control

class_name Point

var cluster_releations := {}
# cluster_id : probability

func _ready() -> void:
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	$PanelContainer.hide()


func _on_mouse_entered() -> void:
	$PanelContainer.show()
