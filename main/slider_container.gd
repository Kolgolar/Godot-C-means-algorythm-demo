extends VBoxContainer


export var _min_value := 0
export var _max_value := 1
export var _step := 1

onready var _slider = $HSlider
onready var _spin_box = $SpinBox


func _ready() -> void:
	for n in [_slider, _spin_box]:
		n.min_value = _min_value
		n.max_value = _max_value
		n.step = _step


func set_max(value) -> void:
	_slider.max_value = value
	_spin_box.max_value = value


func _on_SpinBox_value_changed(value : float) -> void:
	_slider.value = value 


func _on_HSlider_value_changed(value : float) -> void:
	_spin_box.value = value
