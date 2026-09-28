extends Node3D

@export var camera: Camera3D = null
@export var fire_rate: float = 0.5
@export var aoe_lifetime: float = 7.0
@export var aoe_prefab: PackedScene

var can_fire: bool = true

func _process(_delta):
	if Input.is_action_pressed("fire") and can_fire:
		fire_aoe()
		can_fire = false
		await get_tree().create_timer(fire_rate).timeout
		can_fire = true
		
func fire_aoe():
	if not (aoe_prefab and camera):
		return
	
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_direction = camera.project_ray_normal(mouse_position) * 1000  # Long ray

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction)
	var result = space_state.intersect_ray(query)

	if result.has("position"):
		var aoe_instance = aoe_prefab.instantiate()
		get_parent().add_child(aoe_instance)
		aoe_instance.global_position = result["position"]  # Spawn at hit position
		aoe_instance.play_particles = true  # Start particle effect
		
		await get_tree().create_timer(aoe_lifetime).timeout
		if is_instance_valid(aoe_instance):
			aoe_instance.queue_free()
