extends Node3D

var line2d_scene = preload("res://move_line2d/move_line_2d.tscn")

var camera_move := false
var vp_size :Vector2
var l2d_list :Array = []
var paused :bool
func _ready() -> void:
	vp_size = get_viewport().size
	reset_camera()
	var l2d_0 = line2d_scene.instantiate().init_with_random(50,4,1,vp_size,2.0/60.0)
	for i in 100:
		var l2d = line2d_scene.instantiate().init_with_copy(l2d_0)
		for j in i:
			l2d.move_1_step()
		l2d.start()
		var mi = make_line2d_plane(l2d, vp_size)
		mi.position.z = i *2
		l2d_list.append(l2d)

func make_line2d_plane(l2d :MoveLine2D, sz2 :Vector2) -> MeshInstance3D:
	var sv = SubViewport.new()
	sv.size = sz2
	sv.transparent_bg = true
	sv.add_child(l2d)
	add_child(sv)
	var mesh = PlaneMesh.new()
	mesh.size = sz2
	mesh.orientation = PlaneMesh.FACE_Z
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = StandardMaterial3D.new()
	mi.material_override.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	mi.material_override.albedo_texture = sv.get_texture()
	add_child(mi)
	return mi
	
func _process(delta: float) -> void:
	if camera_move:
		move_camera(delta)

func reset_camera() -> void:
	var centerx = 10
	var centery = 10
	var z = vp_size.length()/2
	$Camera3D.position = Vector3(centerx, centery, z)
	$Camera3D.look_at(Vector3(centerx, centery, 0))
	$DirectionalLight3D.position = Vector3(centerx, centery, z)
	$DirectionalLight3D.look_at(Vector3(centerx, centery, 0))

func move_camera(_delta: float) -> void:
	var t = -Time.get_unix_time_from_system() /2.3
	var r = vp_size.length() /2
	var centerx = 10
	var centery = 10
	var z = vp_size.length() /2
	var center = Vector3(centerx, centery, 0)
	$Camera3D.position = Vector3( sin(t)*r, cos(t)*r, z ) + center
	$Camera3D.look_at(center)

var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_C: _on_button_camera_pressed,
	KEY_P: _on_button_pause_pressed,
}

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_button_esc_pressed() -> void:
	get_tree().quit()

func _on_button_pause_pressed() -> void:
	paused = not paused
	for l2d in l2d_list:
		l2d.auto_move = not paused

func _on_button_camera_pressed() -> void:
	camera_move = not camera_move
	if not camera_move:
		reset_camera()
