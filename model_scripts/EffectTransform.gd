@tool
class_name EffectTransform
extends Node

@export var source: Node3D = get_parent()
@export var perma_clone := false
@export var pos_factor := Vector3(-1, 1, 1)
@export var pos_offset := Vector3.ZERO
@export var scale_factor := Vector3(1, 1, 1)
@export var rotate_degrees := Vector3(0, 180, 0):
	get: return rotate_degrees
	set(v): 
		rotate_degrees = v
		_set_clone_transform()
@export_tool_button("apply")
@warning_ignore("unused_private_class_variable")
var _tool := execute
var clone: Node3D


func _ready() -> void:
	execute.call_deferred()


func execute() -> void:
	if source == null: return
	if clone != null: clone.queue_free()
	clone = source.duplicate()
	source.get_parent().add_child(clone)
	if perma_clone: clone.owner = get_tree().get_edited_scene_root()
	_set_clone_transform()


func _set_clone_transform() -> void:
	if source == null || clone == null: return
	clone.transform = source.transform
	clone.position *= pos_factor
	clone.position += pos_offset
	clone.scale *= scale_factor
	clone.rotation_degrees += rotate_degrees
