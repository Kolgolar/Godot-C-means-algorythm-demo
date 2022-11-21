extends Node

const _FUZZY_PARAMETER := 1.5
const _MAX_EXECUTION_CYCLES := 1000
const _EPSILON := 0.001


func _ready() -> void:
	randomize()


func distribute_over_matrix_u(points : Array, clusters_q : int, fuzzy_parameter : float = _FUZZY_PARAMETER) -> Dictionary:
	var min_max_coords : Array = _get_min_max_corrds(points)
	var clusters_coords : Array = _gen_rnd_clusters_centers(clusters_q, min_max_coords[0], min_max_coords[1])
	var matrix_u : Array = _gen_u_matrix(points.size(), clusters_q)
	# print(matrix_u)
	
	var previous_decision_value : float = 0
	var current_decision_value : float = 1

	var iter_num := 0
	print("Points coords:")
	# TODO: Move it to process
	while iter_num < _MAX_EXECUTION_CYCLES and abs(previous_decision_value - current_decision_value) > _EPSILON:
		iter_num += 1
		print("Iteration #" + str(iter_num))
		previous_decision_value = current_decision_value
		clusters_coords = _calculate_new_clusters_coords(matrix_u, points, clusters_q)
		# print(clusters_coords)
		var point_idx = 0
		# print("Clusters coords: " + str(clusters_coords))
		for matrix_row in matrix_u:
			var cluster_idx = 0
			for i in matrix_row.size():
				var distance : float = points[point_idx].rect_global_position.distance_to(clusters_coords[cluster_idx])
				# print(str(point_idx) + ": " + str(distance))
				matrix_row[i] = _prepare_u(distance) # Changing "u"
				cluster_idx += 1
			# print(matrix_row)
				
			matrix_row = _normalize_u_matrix_row(matrix_row)
			matrix_u[point_idx] = matrix_row
			point_idx += 1
		
		current_decision_value = _calculate_decision_function(points, clusters_coords, matrix_u)
		# print("Prev: " + str(previous_decision_value))
		# print("Curr: " + str(current_decision_value))
	print("Iterations quantity: " + str(iter_num))
	return {"matrix_u" : matrix_u, "clusters_coords" : clusters_coords}


# Matrix row = массив принадлежности данной точки к каждому кластеру

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
		print("Before: " + str(matrix[x]))
		matrix[x] = _normalize_u_matrix_row(matrix[x])
		print("After: " + str(matrix[x]))
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
