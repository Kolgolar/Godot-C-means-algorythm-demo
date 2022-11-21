extends ColorRect

export(PackedScene) var _point

var should_create_points := false
# var _points_q := 0
var _points_per_click := 1


onready var _points_container = $Points

signal point_created


func _ready() -> void:
	# $Button.mouse_filter = MOUSE_FILTER_STOP
	pass


func clasterization_done() -> void:
	$Button.mouse_filter = MOUSE_FILTER_PASS


func clear() -> void:
	var points = get_tree().get_nodes_in_group("points")
	for p in points:
		p.queue_free()
	# _points_q = 0


func draw_point(pos : Vector2 = Vector2(-1, -1)) -> Point:
	if pos == Vector2(-1, -1):
		pos = Vector2(rand_range(0, rect_size.x), rand_range(0, rect_size.y)) + rect_global_position
	var new_point = _point.instance()
	_points_container.add_child(new_point)
	new_point.rect_global_position = pos
	return new_point


func _on_Clusterer_iteration_passed(data : Array) -> void:
	var matrix_u = data[0]
	# var clusters_coords = data[1]
	var points = get_tree().get_nodes_in_group("points")
	var point_idx := 0
	for matrix_row in matrix_u:
		points[point_idx].cluster_releations = matrix_row
		point_idx += 1


func _on_Clusterer_clusterization_complete(data : Array) -> void:
	var dict : Dictionary = data[0]
	var matrix_u = dict["matrix_u"]
	var clusters_coords = dict["clusters_coords"]
	
	var point_idx := 0
	for matrix_row in matrix_u:
		var max_u := 0
		for u_idx in matrix_row.size():
			if matrix_row[u_idx] > matrix_row[max_u]:
				max_u = u_idx
		# get_tree().get_nodes_in_group("points")[point_idx].get_node("Label").text = str(max_u)
		point_idx += 1
	
	
	# var id := 0
	# for cluster in clusters_coords:
	# 	var point = draw_point(cluster)
	# 	point.modulate = Color.red
	# 	# point.get_node("Label").text = str(id)
	# 	id += 1



func _on_Button_pressed() -> void:
	var max_shift = 50
	for i in _points_per_click:
		var rnd_shift = Vector2(rand_range(-max_shift, max_shift), rand_range(-max_shift, max_shift))
		draw_point(get_global_mouse_position() + rnd_shift)
	# var new_point = _point.instance()
	# _points_container.add_child(new_point)
	# new_point.rect_global_position = get_global_mouse_position()
	# _points_q += 1
	# emit_signal("point_created", _points_q)


func _on_HSlider_value_changed(value : float) -> void:
	_points_per_click = value
