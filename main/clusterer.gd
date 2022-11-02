extends Node


func _ready() -> void:
	randomize()


func start_clasterization(q : int, p : Array) -> Dictionary:
	var clusters = _rnd_distribution(q, p)
	
	return {}


func _rnd_distribution(q : int, points : Array) -> Array:
	var clusters := []
	for i in q:
		var cluster = Cluster.new()
		cluster.id = i
		clusters.append(cluster)
	for p in points:
		var num = randi() % q
		var cluster = clusters[num]
		cluster.points.append(p)
	return clusters
