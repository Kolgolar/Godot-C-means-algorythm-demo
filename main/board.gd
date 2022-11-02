extends ColorRect

export(PackedScene) var _point

var should_create_points := false
var _points_q := 0

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
	_points_q = 0


func _on_Button_pressed() -> void:
	var new_point = _point.instance()
	_points_container.add_child(new_point)
	new_point.rect_global_position = get_global_mouse_position()
	_points_q += 1
	emit_signal("point_created", _points_q)
