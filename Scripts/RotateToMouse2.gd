extends Node3D

@export var camera: Camera3D = null
@export var rotation_speed: float = 5.0

func _process(delta):
	if camera:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_dir = camera.project_ray_normal(mouse_pos)
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * 1000.0)
		var result = space_state.intersect_ray(query)
		
		var target_position = result["position"] if result else ray_origin + ray_dir * 10.0
		var direction = (target_position - global_transform.origin).normalized()
		var target_rotation = Quaternion(Vector3.FORWARD, direction)
		transform.basis = Basis(transform.basis.get_rotation_quaternion().slerp(target_rotation, delta * rotation_speed))
