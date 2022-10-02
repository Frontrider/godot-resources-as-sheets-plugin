tool
extends VBoxContainer

signal update_data(data)
signal hidden_columns_changed(hidden_columns)

var editor_plugin : EditorPlugin = EditorPlugin.new()
var directory:String
var save_data_path : String = get_script().resource_path.get_base_dir() + "/saved_state.json"
var recent_paths = []
var hidden_columns = []

func _ready():
	if editor_plugin != null:
		editor_plugin.get_editor_interface().get_resource_filesystem()
		.connect("filesystem_changed", self, "_on_filesystem_changed")
	load_settings()
	pass

func _on_SelectDirectory_dir_selected(dir):
	directory = dir
	$"%Path".text = directory
	add_path_to_recent(directory)
	refresh()
	pass

func _on_SelectDir_pressed():
	$Node/SelectDirectory.show()
	pass

func _on_Refresh_pressed():
	refresh()

func _on_filesystem_changed():
	refresh()

func refresh():
	if directory != "":
		var data = _load_resources_from_folder(directory)
		emit_signal("update_data",data)
		pass
	pass

func _load_resources_from_folder(folderpath : String):
	var dir := Directory.new()
	dir.open(folderpath)
	dir.list_dir_begin()
	var cur_dir_script : Script = null

	var filepath = dir.get_next()
	var res : Resource
	var resources = []
	while filepath != "":
		if filepath.ends_with(".tres"):
			filepath = folderpath + filepath
			res = load(filepath)
			if !is_instance_valid(cur_dir_script):
				resources.append(res)
		filepath = dir.get_next()
	return resources

func _on_DeletePath_pressed():
	$"%Path".text = ""
	directory = ""
	pass

func _on_Info_pressed():
	$"%Info".popup()
	pass # Replace with function body.


func _on_Settings_pressed():
	$"%Settings".popup()
	pass # Replace with function body.

func load_settings():
	# Load saved recent paths
	var file := File.new()
	if file.file_exists(save_data_path):
		file.open(save_data_path, File.READ)

		var as_text = file.get_as_text()
		var as_var = str2var(as_text)
		for x in as_var["recent_paths"]:
			add_path_to_recent(x, true)
		hidden_columns = as_var["hidden_columns"]
		emit_signal("hidden_columns_changed",hidden_columns)
	

func add_path_to_recent(path : String, is_loading : bool = false):
	if path in recent_paths: return

	var node_recent := $"%RecentPaths"
	var idx_in_array:int = recent_paths.find(path)
	if idx_in_array != -1:
		node_recent.remove_item(idx_in_array)
		recent_paths.remove(idx_in_array)
	
	recent_paths.append(path)
	node_recent.add_item(path)
	node_recent.select(node_recent.get_item_count() - 1)

	if !is_loading:
		save_data()
	

func save_data():
	var file = File.new()
	file.open(save_data_path, File.WRITE)
	file.store_string(var2str(
		{
			"recent_paths" : recent_paths,
			"hidden_columns" : hidden_columns,
		}
	))

func set_columns():
	
	pass
