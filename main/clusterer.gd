extends Node

const _FUZZY_PARAMETER := 1.5
const _MAX_EXECUTION_CYCLES := 100
const _EPSILON := 0.01

signal clusterization_complete
signal iteration_passed

var _points : Array
var _clusters_q : int
var _min_max_coords : Array
var _clusters_coords : Array
var _previous_decision_value : float
var _current_decision_value : float
var _iter_num : int
var _matrix_u : Array

var _is_busy := false


func _ready() -> void:
	randomize()


func _process(delta: float) -> void:
	if _is_busy:
		_iter_num += 1
		# print("Iteration #" + str(_iter_num))
		_previous_decision_value = _current_decision_value
		_clusters_coords = _calculate_new_clusters_coords(_matrix_u, _points, _clusters_q)
		var point_idx = 0
		for matrix_row in _matrix_u:
			var cluster_idx = 0
			for i in matrix_row.size():
				var distance : float = _points[point_idx].rect_global_position.distance_to(_clusters_coords[cluster_idx])
				matrix_row[i] = _prepare_u(distance) # Changing "u"
				cluster_idx += 1
			matrix_row = _normalize_u_matrix_row(matrix_row)
			_matrix_u[point_idx] = matrix_row
			point_idx += 1
		_current_decision_value = _calculate_decision_function(_points, _clusters_coords, _matrix_u)
		emit_signal("iteration_passed", [_matrix_u, _clusters_coords, _iter_num])
		
		if _iter_num >= _MAX_EXECUTION_CYCLES or abs(_previous_decision_value - _current_decision_value) < _EPSILON:
			emit_signal("clusterization_complete", [{"matrix_u" : _matrix_u, "clusters_coords" : _clusters_coords}])
			_is_busy = false


func distribute_over_matrix_u(points : Array, clusters_q : int, fuzzy_parameter : float = _FUZZY_PARAMETER) -> void:
	_points = points
	_clusters_q = clusters_q
	_min_max_coords = _get_min_max_corrds(_points)
	_clusters_coords = _gen_rnd_clusters_centers(clusters_q, _min_max_coords[0], _min_max_coords[1])
	_matrix_u = _gen_u_matrix(_points.size(), clusters_q)
	_previous_decision_value = 0
	_current_decision_value = 1
	_iter_num = 0
	_is_busy = true


func _calculate_decision_function(points : Array, clusters_coords : Array, matrix_u : Array) -> float:
	var sum : float = 0
	
	var point_idx := 0
	for matrix_row in matrix_u:
		var cluster_idx := 0
		for u in matrix_row:
			sum += u * clusters_coords[cluster_idx].distance_to(points[point_idx].rect_global_position)
			cluster_idx += 1
		point_idx += 1
	return sum


func _prepare_u(distance : float, fuzzy_parameter : float = _FUZZY_PARAMETER) -> float:
	if distance == 0:
		return 1.0
	return 1 / pow(distance, 2 / (fuzzy_parameter - 1))


func _calculate_new_clusters_coords(matrix_u : Array, points : Array, clusters_q : int, fuzzy_parameter : float = _FUZZY_PARAMETER) -> Array:
	var new_cluster_coords := []
	for cluster_idx in clusters_q:
		var temp_a := 0.0
		var temp_bx := 0.0
		var temp_by := 0.0

		var point_idx := 0
		for matrix_row in matrix_u:
			temp_a += pow(matrix_row[cluster_idx], fuzzy_parameter)
			temp_bx += pow(matrix_row[cluster_idx], fuzzy_parameter) * points[point_idx].rect_global_position.x
			temp_by += pow(matrix_row[cluster_idx], fuzzy_parameter) * points[point_idx].rect_global_position.y
			point_idx += 1
		
		new_cluster_coords.append(Vector2(temp_bx / temp_a, temp_by / temp_a))

	return new_cluster_coords


func _normalize_u_matrix_row(matrix_row : Array) -> Array:
	# print(matrix_row)
	var arr := []
	var sum : float = 0
	for u in matrix_row:
		sum += u
	for u in matrix_row:
		arr.append(u / sum)
	return(arr)


func _gen_u_matrix(points_q : int, clusters_q : int):
	var x_size := points_q
	var y_size := clusters_q
	var matrix := []
	for x in x_size:
		matrix.append([])
		for y in range(y_size):
			matrix[x].append(rand_range(0, 1))
		matrix[x] = _normalize_u_matrix_row(matrix[x])
	return matrix


func _gen_rnd_clusters_centers(q : int, min_c : Vector2, max_c : Vector2) -> Array:
	var clusters := []
	for i in q:
		var new_center = Vector2(
			rand_range(min_c.x, max_c.y),
			rand_range(min_c.y, max_c.y)
		)
		var new_cluster = Cluster.new()
		new_cluster.id = i
		new_cluster.center = new_center
		clusters.append(new_cluster.center)
	return clusters


func _get_min_max_corrds(points : Array) -> Array:
	var top_left = Vector2(10000, 10000)
	var bottom_right = Vector2(0, 0)
	for p in points:
		var p_pos = p.rect_global_position
		if p_pos.x < top_left.x:
			top_left.x = p_pos.x
		elif p_pos.x > bottom_right.x:
			bottom_right.x = p_pos.x
		if p_pos.y < top_left.y:
			top_left.y = p_pos.y
		elif p_pos.y > bottom_right.y:
			bottom_right.y = p_pos.y
	
	return [top_left, bottom_right]
