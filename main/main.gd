extends Control


onready var _board = $HBoxContainer/Control/Board
onready var _clusterer = $Clusterer

func _ready() -> void:
	_board.should_create_points = true


func _on_Start_pressed() -> void:
	var points : Array = get_tree().get_nodes_in_group("points")
	var clasters_q : int = $HBoxContainer/Panel/VBoxContainer/ClastersQ/SpinBox.value
	_clusterer.start_clasterization(clasters_q, points)


func _on_Clear_pressed() -> void:
	_board.clear()


func _on_Board_point_created(points_q) -> void:
	$HBoxContainer/Panel/VBoxContainer/ClastersQ.set_max(points_q)
