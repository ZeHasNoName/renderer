@tool
class_name EffectMirror
extends Node

@export var source: Node3D = get_parent()
@export var perma_clone := false
@export_tool_button("apply")
@warning_ignore("unused_private_class_variable")
var _tool := execute
var clone: Node3D


const MIRROR_X = Basis(Vector3(-1,0,0), Vector3(0,1,0), Vector3(0,0,1))
const MIRROR_Y = Basis(Vector3(1,0,0), Vector3(0,-1,0), Vector3(0,0,1))
const MIRROR_Z = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,-1))


# func _ready() -> void:
	# execute.call_deferred()


func execute() -> void:
	if source == null: return
	if clone != null: clone.queue_free()
	clone = source.duplicate()
	source.get_parent().add_child(clone)
	if perma_clone: clone.owner = get_tree().get_edited_scene_root()
	#clone.global_transform.basis = MIRROR_X * source.global_transform.basis
	#clone.global_transform.origin = MIRROR_X * source.global_transform.origin
	
	var forward := -source.global_basis.z
	forward.x *= -1

	clone.global_position = source.global_position
	clone.global_position.x *= -1

	clone.look_at(
		clone.global_position + forward,
		Vector3.UP
	)
