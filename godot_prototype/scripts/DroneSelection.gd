# DroneSelection.gd
# ForgeFPV - Drone Selection Screen Logic

extends Control
class_name DroneSelection

@export var database_path: NodePath
@export var main_menu_path: NodePath

var database: DroneDatabase
var main_menu: MainMenu

var selected_drone_id: String = ""

@onready var drone_list: ItemList = $DroneList
@onready var drone_info: RichTextLabel = $DroneInfo
@onready var select_button: Button = $SelectButton
@onready var back_button: Button = $BackButton

func _ready():
	if database_path:
		database = get_node(database_path) as DroneDatabase
	_populate_drone_list()
	if select_button:
		select_button.pressed.connect(_on_select_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if drone_list:
		drone_list.item_selected.connect(_on_drone_selected)

func _populate_drone_list():
	if not database or not drone_list: return
	drone_list.clear()
	for drone in database.get_all_drones():
		drone_list.add_item(drone.display_name)

func _on_drone_selected(index: int):
	if not database: return
	var drone = database.get_all_drones()[index]
	selected_drone_id = drone.id
	if drone_info:
		drone_info.text = "[b]%s[/b]\nType: %s" % [drone.display_name, drone.type]

func _on_select_pressed():
	if selected_drone_id == "": return
	var drone_data = database.get_drone_by_id(selected_drone_id)
	if not drone_data: return
	var config = DroneConfig.from_drone_data(drone_data)
	if has_node("/root/GameState"):
		get_node("/root/GameState").set_selected_drone(config)
	print("Selected drone:", drone_data.display_name)
	if main_menu and main_menu.training_scene_path != "":
		get_tree().change_scene_to_file(main_menu.training_scene_path)

func _on_back_pressed():
	hide()
	if main_menu: main_menu.show()