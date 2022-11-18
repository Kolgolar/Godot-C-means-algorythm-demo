extends Node

const _FUZZY_PARAMETR := 1.5
const _MAX_EXECUTION_CYCLES := 10000
const _EPSILON := 0.0001


func _ready() -> void:
	randomize()


func distribute_over_matrix_u(points : Array, clusters_q : int, fuzzy_parameter : float = _FUZZY_PARAMETR) -> Dictionary:
	var iter_q := 0
	var min_max_coords : Array = _get_min_max_corrds(points)
	var clusters : Array = _gen_clusters_with_rnd_centers(clusters_q, min_max_coords[0], min_max_coords[1])
	var matrix_u : Array = _gen_u_matrix(points.size(), clusters_q)
	
	var previous_decision_value : float = 0
	var current_decision_value : float = 1

	var clusters_coords := []

	var a := 0
	# TODO: Move it to process
	while a < _MAX_EXECUTION_CYCLES and abs(previous_decision_value - current_decision_value) > _EPSILON:
		iter_q += 1
		previous_decision_value = current_decision_value
		clusters_coords = _calculate_new_clusters_coords(matrix_u, points, clusters_q)
		
		var point_idx = 0
		for matrix_row in matrix_u:
			var cluster_idx = 0
			for u in matrix_row:
				var distance = points[point_idx].rect_global_position.distance_to(clusters_coords[cluster_idx])
				u = _prepare_u(distance)
				cluster_idx += 1
			
				matrix_row = _normalize_u_matrix_row(matrix_row)
			point_idx += 1
		
		current_decision_value = calculate_decision_function(points, clusters_coords, matrix_u)
		a += 1
	print("Iterations quantity: " + str(iter_q))
	return {"matrix_u" : matrix_u, "clusters_coords" : clusters_coords}


# Matrix row = массив принадлежности данной точки к каждому кластеру

func calculate_decision_function(points : Array, clusters_coords : Array, matrix_u : Array) -> float:
	var sum : float = 0
	
	var point_idx := 0
	for matrix_row in matrix_u:
		var cluster_idx := 0
		for u in matrix_row:
			sum += u * clusters_coords[cluster_idx].distance_to(points[point_idx].rect_global_position)
	
	return sum


func _prepare_u(distance : float, fuzzy_parameter : float = _FUZZY_PARAMETR) -> float:
	return pow(1 / distance, 2 / (fuzzy_parameter - 1))


func _calculate_new_clusters_coords(matrix_u : Array, points : Array, clusters_q : int, fuzzy_parameter : float = _FUZZY_PARAMETR) -> Array:
	var new_cluster_coords := []
	for cluster_idx in clusters_q:
		var temp_ax := 0.0
		var temp_bx := 0.0
		var temp_ay := 0.0
		var temp_by := 0.0

		var key := 0
		for matrix_row in matrix_u:
			temp_ax += pow(matrix_row[cluster_idx], fuzzy_parameter)
			temp_bx += pow(matrix_row[cluster_idx], fuzzy_parameter) * points[key].rect_global_position.x

			temp_ay += pow(matrix_row[cluster_idx], fuzzy_parameter)
			temp_by += pow(matrix_row[cluster_idx], fuzzy_parameter) * points[key].rect_global_position.y
			key += 1
		
		new_cluster_coords.append(Vector2(temp_bx / temp_ax, temp_by / temp_ay))

	return new_cluster_coords


func _normalize_u_matrix_row(matrix_row : Array) -> Array:
	var sum : float = 0
	for u in matrix_row:
		sum += u
	for u in matrix_row:
		u = u / sum
	return(matrix_row)


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


func _gen_clusters_with_rnd_centers(q : int, min_c : Vector2, max_c : Vector2) -> Array:
	var clusters := []
	for i in q:
		var new_center = Vector2(
			rand_range(min_c.x, max_c.y),
			rand_range(min_c.y, max_c.y)
		)
		var new_cluster = Cluster.new()
		new_cluster.id = i
		new_cluster.center = new_center
		clusters.append(new_cluster)
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
		elif p_pos.y < top_left.y:
			top_left.y = p_pos.y
		elif p_pos.y > bottom_right.y:
			bottom_right.y = p_pos.y
	
	return [top_left, bottom_right]
