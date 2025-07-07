@tool
extends Node2D
class_name WorldDraftController

# === WORLD DRAFT CONTROLLER ===
# Prototyping environment for 3x3 overworld map layout
# Canvas: 3840x2160 (3x 1280x720 regions)
# Purpose: Design, iteration, and layout planning for world cohesion

# Region constants based on 1280x720 individual scenes
const REGION_WIDTH := 1280
const REGION_HEIGHT := 720
const TOTAL_WIDTH := 3840  # 3 * 1280
const TOTAL_HEIGHT := 2160  # 3 * 720

# Camera controls
@onready var camera: Camera2D = $Camera2D
@onready var grid_lines: Control = $DraftCanvas/GridLines
@onready var region_markers: Control = $RegionOverlays/RegionMarkers
@onready var collision_layer: TileMap = $TileMapStack/CollisionLayer
@onready var procreate_slot: Sprite2D = $ExternalArtLayer/ProcreateDraftSlot

# UI Controls
@onready var show_grid_checkbox: CheckBox = $UI/ToolsPanel/VBoxContainer/ShowGrid
@onready var show_regions_checkbox: CheckBox = $UI/ToolsPanel/VBoxContainer/ShowRegions  
@onready var show_collision_checkbox: CheckBox = $UI/ToolsPanel/VBoxContainer/ShowCollision
@onready var zoom_in_btn: Button = $UI/ToolsPanel/VBoxContainer/ZoomControls/ZoomIn
@onready var zoom_out_btn: Button = $UI/ToolsPanel/VBoxContainer/ZoomControls/ZoomOut
@onready var center_view_btn: Button = $UI/ToolsPanel/VBoxContainer/CenterView
@onready var reset_zoom_btn: Button = $UI/ToolsPanel/VBoxContainer/ResetZoom

# Camera navigation
var is_dragging := false
var drag_start_pos: Vector2
var initial_camera_pos: Vector2

# Zoom settings
const MIN_ZOOM := 0.1
const MAX_ZOOM := 2.0
const ZOOM_STEP := 0.1
const DEFAULT_ZOOM := 0.3

func _ready():
	_setup_camera()
	_connect_ui_signals()
	_draw_grid_overlay()
	
	# Set initial states
	_update_grid_visibility()
	_update_region_visibility()
	_update_collision_visibility()
	
	print("WorldDraft initialized - Canvas: %dx%d" % [TOTAL_WIDTH, TOTAL_HEIGHT])

func _setup_camera():
	"""Position camera at center of 3x3 world with appropriate zoom"""
	camera.position = Vector2(TOTAL_WIDTH / 2, TOTAL_HEIGHT / 2)
	camera.zoom = Vector2(DEFAULT_ZOOM, DEFAULT_ZOOM)

func _connect_ui_signals():
	"""Connect all UI control signals"""
	show_grid_checkbox.toggled.connect(_on_show_grid_toggled)
	show_regions_checkbox.toggled.connect(_on_show_regions_toggled)
	show_collision_checkbox.toggled.connect(_on_show_collision_toggled)
	
	zoom_in_btn.pressed.connect(_on_zoom_in)
	zoom_out_btn.pressed.connect(_on_zoom_out)
	center_view_btn.pressed.connect(_on_center_view)
	reset_zoom_btn.pressed.connect(_on_reset_zoom)

func _draw_grid_overlay():
	"""Draw visual grid lines for 3x3 region layout"""
	grid_lines.draw.connect(_on_draw_grid)
	grid_lines.queue_redraw()

func _on_draw_grid():
	"""Custom draw function for grid overlay"""
	var line_color = Color.WHITE
	line_color.a = 0.3
	var line_width = 2.0
	
	# Vertical lines
	for i in range(1, 3):  # 2 vertical dividers
		var x = i * REGION_WIDTH
		grid_lines.draw_line(Vector2(x, 0), Vector2(x, TOTAL_HEIGHT), line_color, line_width)
	
	# Horizontal lines  
	for i in range(1, 3):  # 2 horizontal dividers
		var y = i * REGION_HEIGHT
		grid_lines.draw_line(Vector2(0, y), Vector2(TOTAL_WIDTH, y), line_color, line_width)

func _input(event):
	"""Handle camera drag-to-pan navigation"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_pos = event.position
				initial_camera_pos = camera.position
			else:
				is_dragging = false
	
	elif event is InputEventMouseMotion and is_dragging:
		var drag_delta = (event.position - drag_start_pos) / camera.zoom.x
		camera.position = initial_camera_pos - drag_delta
	
	elif event is InputEventMouseButton:
		# Zoom with mouse wheel
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at_point(event.position, ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at_point(event.position, -ZOOM_STEP)

func _zoom_at_point(screen_point: Vector2, zoom_delta: float):
	"""Zoom camera while maintaining focus on mouse position"""
	var world_point = camera.to_global(screen_point)
	var new_zoom = clamp(camera.zoom.x + zoom_delta, MIN_ZOOM, MAX_ZOOM)
	
	camera.zoom = Vector2(new_zoom, new_zoom)
	
	# Adjust camera position to keep world point under cursor
	var new_world_point = camera.to_global(screen_point)
	camera.position += world_point - new_world_point

# === UI SIGNAL HANDLERS ===

func _on_show_grid_toggled(pressed: bool):
	_update_grid_visibility()

func _on_show_regions_toggled(pressed: bool):
	_update_region_visibility()

func _on_show_collision_toggled(pressed: bool):
	_update_collision_visibility()

func _on_zoom_in():
	var new_zoom = clamp(camera.zoom.x + ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
	camera.zoom = Vector2(new_zoom, new_zoom)

func _on_zoom_out():
	var new_zoom = clamp(camera.zoom.x - ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
	camera.zoom = Vector2(new_zoom, new_zoom)

func _on_center_view():
	camera.position = Vector2(TOTAL_WIDTH / 2, TOTAL_HEIGHT / 2)

func _on_reset_zoom():
	camera.zoom = Vector2(DEFAULT_ZOOM, DEFAULT_ZOOM)

# === VISIBILITY CONTROLS ===

func _update_grid_visibility():
	grid_lines.visible = show_grid_checkbox.button_pressed

func _update_region_visibility():
	region_markers.visible = show_regions_checkbox.button_pressed

func _update_collision_visibility():
	collision_layer.visible = show_collision_checkbox.button_pressed

# === EXTERNAL ART INTEGRATION ===

func load_procreate_draft(texture_path: String):
	"""Load external artwork from Procreate/Figma as reference overlay"""
	var texture = load(texture_path) as Texture2D
	if texture:
		procreate_slot.texture = texture
		procreate_slot.visible = true
		print("Loaded draft overlay: %s" % texture_path)
	else:
		print("Failed to load draft overlay: %s" % texture_path)

func clear_procreate_draft():
	"""Remove external artwork overlay"""
	procreate_slot.texture = null
	procreate_slot.visible = false

# === UTILITY FUNCTIONS ===

func get_region_at_position(world_pos: Vector2) -> Vector2:
	"""Get region coordinates (0-2, 0-2) for world position"""
	var region_x = int(world_pos.x / REGION_WIDTH)
	var region_y = int(world_pos.y / REGION_HEIGHT)
	return Vector2(clamp(region_x, 0, 2), clamp(region_y, 0, 2))

func get_region_center(region_coords: Vector2) -> Vector2:
	"""Get world center position for given region coordinates"""
	return Vector2(
		region_coords.x * REGION_WIDTH + REGION_WIDTH / 2,
		region_coords.y * REGION_HEIGHT + REGION_HEIGHT / 2
	)

func focus_on_region(region_coords: Vector2):
	"""Center camera on specific region"""
	camera.position = get_region_center(region_coords)

# === DEBUG INFO ===

func _on_mouse_moved():
	"""Show region info for debugging (can be connected via signal)"""
	var mouse_pos = get_global_mouse_position()
	var region = get_region_at_position(mouse_pos)
	print("Mouse in region: (%d, %d)" % [region.x, region.y]) 