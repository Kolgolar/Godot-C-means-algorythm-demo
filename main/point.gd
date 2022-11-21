extends Control

class_name Point

var colors = [
	Color.red, 
	Color.orange,
	Color.yellow,
	Color.green,
	Color.aqua,
	Color.blue,
	Color.magenta,
	Color.bisque,
	Color.black,
	Color.deeppink,
]

var cluster_releations := [] setget update_clusters_relations

func _ready() -> void:
	pass


func update_clusters_relations(arr : Array) -> void:
	var max_u := 0
	for u_idx in arr.size():
		if arr[u_idx] > arr[max_u]:
			max_u = u_idx
	$TextureRect.self_modulate = colors[max_u]


func _on_mouse_exited() -> void:
	$PanelContainer.hide()


func _on_mouse_entered() -> void:
	print("COCK")
	$PanelContainer.show()
