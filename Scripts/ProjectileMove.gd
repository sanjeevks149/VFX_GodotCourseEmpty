extends RigidBody3D

@export var speed: float = 10.0
@export var muzzle_prefab: PackedScene
@export var impact_prefab: PackedScene
@export var delay_trails_start: float = 0.1
@export var trails: Array[GPUTrail3D]

var direction: Vector3 = Vector3.FORWARD
var fire_point_position: Vector3

func set_fire_point(fp_position: Vector3):
	fire_point_position = fp_position
	
func _ready():
	delay_trails()
	spawn_muzzle()
	contact_monitor = true
	max_contacts_reported = 1

func _integrate_forces(state):
	linear_velocity = direction * speed
	
	var collision = state.get_contact_count()
	if collision > 0:
		var contact = state.get_contact_collider_position(0)
		var normal = state.get_contact_local_normal(0)
		spawn_impact(contact, normal)
		queue_free()

func spawn_muzzle():
	if muzzle_prefab:
		var muzzle_instance = muzzle_prefab.instantiate()
		call_deferred("add_child", muzzle_instance)
		await get_tree().create_timer(0.001).timeout
		muzzle_instance.global_transform.origin = fire_point_position
		muzzle_instance.play_particles = true
		
		await get_tree().create_timer(3.0).timeout
		if is_instance_valid(muzzle_instance):
			muzzle_instance.queue_free()

func spawn_impact(contact_point: Vector3 = Vector3.ZERO, contact_normal: Vector3 = Vector3.ZERO):
	if impact_prefab:
		var impact_instance = impact_prefab.instantiate()
		get_tree().current_scene.add_child(impact_instance)
		impact_instance.play_particles = true
		
		impact_instance.global_transform.origin = contact_point
		impact_instance.look_at(contact_point + contact_normal, Vector3.UP)
		
		await get_tree().create_timer(3.0).timeout
		if is_instance_valid(impact_instance):
			impact_instance.queue_free()
			
func delay_trails():
	if trails.is_empty():
		return
	
	for trail in trails:
		if is_instance_valid(trail):
			trail.speed_scale = 0  # Stop movement initially, avoids glitches

	await get_tree().create_timer(delay_trails_start).timeout

	for trail in trails:
		if is_instance_valid(trail):
			trail.speed_scale = 1  # Resume movement
