extends Control

class_name Point

export(PackedScene) var _row

var clusters_releations_arr := []

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

onready var _info = $CanvasLayer/Info
onready var _row_container = $CanvasLayer/Info/RowContainer


func _ready() -> void:
	pass


func update_clusters_relations(arr : Array) -> void:
	var max_u := 0
	for u_idx in arr.size():
		if arr[u_idx] > arr[max_u]:
			max_u = u_idx
	$TextureRect.self_modulate = colors[max_u]



func set_info_panel(arr : Array) -> void:
	for child in $CanvasLayer/Info/RowContainer.get_children():
		child.queue_free()
	for r in arr.size():
		var new_row = _row.instance()
		new_row.get_node("TextureRect").self_modulate = colors[r]
		new_row.get_node("Value").text = str(arr[r])
		new_row.visible = true
		_row_container.add_child(new_row)


func _on_mouse_exited() -> void:
	_info.hide()


func _on_mouse_entered() -> void:
	_info.rect_global_position = rect_global_position
	_info.show()
