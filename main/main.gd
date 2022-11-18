extends Control


onready var _board = $HBoxContainer/Control/Board
onready var _clusterer = $Clusterer

func _ready() -> void:
	_board.should_create_points = true


func _on_Start_pressed() -> void:
	var points : Array = get_tree().get_nodes_in_group("points")
	var clasters_q : int = $HBoxContainer/Panel/VBoxContainer/ClastersQ/SpinBox.value
	var dict = _clusterer.distribute_over_matrix_u(points, clasters_q)
	var matrix_u = dict["matrix_u"]
	var clusters_coords = dict["clusters_coords"]
	# print(matrix_u)
	
	var point_idx := 0
	for matrix_row in matrix_u:
		var max_u := 0
		for u_idx in matrix_row.size():
			if matrix_row[u_idx] > matrix_row[max_u]:
				max_u = u_idx
		points[point_idx].get_node("Label").text = str(max_u)
		point_idx += 1
	
	
	var id := 0
	for cluster in clusters_coords:
		var point = $HBoxContainer/Control/Board.draw_point(cluster)
		point.modulate = Color.red
		point.get_node("Label").text = str(id)
		id += 1



func _on_Clear_pressed() -> void:
	_board.clear()


func _on_Board_point_created(points_q) -> void:
	$HBoxContainer/Panel/VBoxContainer/ClastersQ.set_max(points_q)
