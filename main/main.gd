extends Control


onready var _board = $HBoxContainer/Control/Board
onready var _clusterer = $Clusterer


func _ready() -> void:
	_board.should_create_points = true


func _on_Start_pressed() -> void:
	var points : Array = get_tree().get_nodes_in_group("points")
	var clusters_q = $HBoxContainer/Panel/VBoxContainer/ClustersQ.get_value()
	if points.size() >= clusters_q:
		var clasters_q : int = clusters_q
		_clusterer.distribute_over_matrix_u(points, clasters_q)


func _on_Clear_pressed() -> void:
	_board.clear()


func _on_Board_point_created(points_q) -> void:
	# $HBoxContainer/Panel/VBoxContainer/ClustersQ.set_max(points_q)
	pass


func _on_Auto_pressed() -> void:
	_board.clear()
	var points_q = $HBoxContainer/Panel/VBoxContainer/PointsQ.get_value()
	for p in points_q:
		_board.draw_point()


func _on_Clusterer_iteration_passed(data : Array) -> void:
	$HBoxContainer/Panel/VBoxContainer/IterationsQ.text = "Количество итерация:\n" + str(data[2])
