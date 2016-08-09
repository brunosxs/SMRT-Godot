# init script that sets everything up
# Nothing (that I think) worth mentioning here

tool
extends EditorPlugin

var show_editor_btn
var editor_tscn = preload("res://addons/SMRT/editor.tscn")
var editor_btn
var editor
func _init():
	editor_btn = ToolButton.new()

func _ready():
	editor_btn.set_button_icon(preload("icon.png"))
	editor_btn.set_text("SMRT-Editor")
	editor_btn.connect("pressed",self,"_open_editor")

func _enter_tree():
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU,editor_btn)
	add_custom_type("SMRT-Dialog","Control",preload("res://addons/SMRT/instance_dialog.gd"),preload("icon.png"))

func _exit_tree():
# TODO:
# As the release of this plugin, there is no oposite function 
# to "add_control_to_container" so for now it is not possible to remove a control from a container,
# only the custom type
	remove_custom_type("SMRT-Dialog")
	

func _open_editor():
	if (editor == null):
		editor = editor_tscn.instance()
		add_child(editor)
	editor.popup_centered()
	print("OPENING EDITOR!")
	print("===============")
