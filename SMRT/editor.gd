tool
extends  Control
var single_text = preload("res://addons/SMRT/scripts/single_text.gd")


const NONE = 0
const TOP = 0
const MIDDLE = 1
const BOTTOM = 2
const LEFT = 1
const RIGHT = 2

#Colors
const ERROR = "F22225"
const INFO = "FFFFFF"
const SUCCESS = "22F230"

var messages_db = {
"Save Error": ["Save Error", ERROR],
"Load Error": ["Load Error", ERROR],
"Chapter is not set": ["Chapter is not set", ERROR],
"Dialog is not set": ["Dialog is not set", ERROR],
"File saved successfully":["File saved successfully", SUCCESS],
"File loaded successfully":["File loaded successfully", SUCCESS]
}

# Controls
# Loved to hate GUI programming... :)
onready var mainButtons = get_node("VBoxContainer/PanelContainer/HBoxContainer/MainControlButtons")
onready var info = get_node("VBoxContainer/PanelContainer/HBoxContainer/info")
var chapter_list
onready var chapter_list_buttons = get_node("VBoxContainer/HBoxContainer/ChapterContainer/VBoxContainer/HButtonArray")
onready var chapter_list_buttons_del_edit = get_node("VBoxContainer/HBoxContainer/ChapterContainer/VBoxContainer/DelEdit")
var dialog_list
onready var dialog_list_buttons = get_node("VBoxContainer/HBoxContainer/DialogContainer/VBoxContainer/HButtonArray")
onready var dialog_list_buttons_del_edit = get_node("VBoxContainer/HBoxContainer/DialogContainer/VBoxContainer/DelEdit")
var text_list
onready var text_list_buttons = get_node("VBoxContainer/HBoxContainer/TextContainer/VBoxContainer/HButtonArray")
onready var text_list_move_buttons = get_node("VBoxContainer/HBoxContainer/TextContainer/VBoxContainer/MoveText")
var frame_position
onready var face_position = get_node("VBoxContainer/HBoxContainer/GridContainer/Face/VBoxContainer/side")
onready var face_frame = get_node("VBoxContainer/HBoxContainer/GridContainer/Face/VBoxContainer/FaceFrame")
onready var typewriter = get_node("VBoxContainer/HBoxContainer/GridContainer/Typewriter/VBoxContainer/CheckButton")
onready var typewriter_speed = get_node("VBoxContainer/HBoxContainer/GridContainer/Typewriter/VBoxContainer/HBoxContainer/TypewriterSpeed")
onready var beep = get_node("VBoxContainer/HBoxContainer/GridContainer/Typewriter/VBoxContainer/beep")
onready var beep_pitch = get_node("VBoxContainer/HBoxContainer/GridContainer/Typewriter/VBoxContainer/SpinBox")
onready var textEditor = get_node("VBoxContainer/TextPanel/VBoxContainer/HBoxContainer 2/TextEdit")
onready var textButtons = get_node("VBoxContainer/TextPanel/VBoxContainer/HBoxContainer 2/VButtonArray")
onready var enableQuestion = get_node("VBoxContainer/CheckButton")
onready var question = get_node("VBoxContainer/question")
onready var choicesNumber = get_node("VBoxContainer/question/VBoxContainer/choicesNumber")
onready var options = question.get_node("VBoxContainer/GridContainer")
onready var option = options.get_child(0).duplicate()
var messages
# Global vars
var contents = {}
var currentChapter
var currentDialog
var currentText
var language_file
var timer
var answers

var input_tscn=preload("res://addons/SMRT/modals/input.tscn")
var old_text
func _ready():
	
	choicesNumber.connect("value_changed", self, "manageQuestionOptions")
	chapter_list = get_node("VBoxContainer/HBoxContainer/ChapterContainer/VBoxContainer/ItemList")
	dialog_list = get_node("VBoxContainer/HBoxContainer/DialogContainer/VBoxContainer/ItemList")
	text_list = get_node("VBoxContainer/HBoxContainer/TextContainer/VBoxContainer/ItemList")
	messages = get_node("VBoxContainer/messages")
	frame_position = get_node("VBoxContainer/HBoxContainer/GridContainer/FramePosition1/VBoxContainer/FramePosition")
	
	if !mainButtons.is_connected("button_selected",self,"mainOptions"):
		mainButtons.connect("button_selected",self,"mainOptions")
		
#	CONNECTIONS
	chapter_list.connect("item_selected",self,"selected_chapter")
	text_list_buttons.connect("button_selected",self,"text_list_buttons")
	dialog_list_buttons.connect("button_selected",self,"dialog_options")
	dialog_list_buttons_del_edit.connect("button_selected",self,"dialog_options_2")
	chapter_list_buttons.connect("button_selected",self,"chapter_options")
	chapter_list_buttons_del_edit.connect("button_selected",self,"chapter_options_2")
	text_list_move_buttons.connect("button_selected",self,"moveText")
	
	textButtons.connect("button_selected",self, "selectedTextButtons")
	
	connect("modal_close", self,"quit")
	
	timer = Timer.new()
	timer.set_wait_time(0.01)
	add_child(timer)
	timer.connect("timeout",self,"to_memory")
	timer.start()
	
		
	
func to_memory():
	if currentChapter != null and currentDialog != null and currentText != null:
		agregate(currentText)

func mainOptions(btn_index):# overrides the arguments
	if btn_index == 0:
		language_file = null
		contents = {}
		clear_all()
		save_file(contents)
	elif btn_index == 1:
		load_file()
	elif btn_index == 2:
		save_file(contents)
	elif btn_index == 3:
		OS.shell_open("https://github.com/brunosxs/SMRT-Godot/wiki")

func new_text():
	return single_text.new().single_text

func load_file():
	var selector = EditorFileDialog.new()
	selector.add_filter("*.lan")
	selector.set_mode(selector.MODE_OPEN_FILE)
	add_child(selector)
	selector.popup_centered(Vector2(800,600))
	language_file = yield(selector,"file_selected")
	var file = File.new()
	if file.open(language_file,file.READ) == OK:
		#this means it sucesfully opened
		var dictionary = {}
		if dictionary.parse_json(file.get_as_text()) == OK:
			dictionary.parse_json(file.get_as_text())
			contents = dictionary
			get_chapters()
			dialog_list.clear()
			messages.set_text(messages_db["File loaded successfully"][0])
			messages.set("custom_colors/font_color", messages_db["File loaded successfully"][1])

func quit():
	save_file(contents)

func save_file(content):
	var file = File.new()
	if language_file == null:
		var selector = EditorFileDialog.new()
		selector.add_filter("*.lan")
		selector.set_title("Save file")
		selector.set_mode(selector.MODE_SAVE_FILE)
		add_child(selector)
		print("LANGUAGE FILE IS NULL, OPENING OR CREATING ONE...")
		selector.popup_centered(Vector2(800,600))
		language_file = yield(selector,"file_selected")
	if file.open(language_file, file.WRITE) == OK:
		file.store_string(content.to_json())
		messages.set_text(messages_db["File saved successfully"][0])
		messages.set("custom_colors/font_color", messages_db["File saved successfully"][1])
		file.close()
	else:
		messages.set_text(messages_db["Save Error"][0])
		messages.set("custom_colors/font_color", messages_db["Save Error"][1])


func get_chapters():
	chapter_list.clear()
	dialog_list.clear()
	text_list.clear()
	var chapters = contents.keys()
	print(chapters)
	for i in range(contents.size()):
		chapter_list.add_item(chapters[i])

func chapter_options(btn_index):
	currentDialog = null
	currentText = null
	if btn_index ==0:
		var input = input_tscn.instance()
		add_child(input)
		input.label.set_text("Name the chapter")
		create_chapter(yield(input, "text"))
		pass
	elif btn_index == 1:
		if currentChapter != null or currentChapter !="":
			duplicate_chapter(currentChapter)

func chapter_options_2(btn_index):
	currentDialog = null
	currentText = null
	if btn_index == 0:
		if currentChapter != null or currentChapter !="":
			remove_chapter(currentChapter)
	elif btn_index == 1:
		print("Renaming Chapter")
		if currentChapter != null or currentChapter !="":
			var input = input_tscn.instance()
			add_child(input)
			input.label.set_text("Rename the chapter")
			rename_chapter(currentChapter, yield(input,"text"))
			dialog_list.clear()
			text_list.clear()
			get_chapters()


func selected_chapter(selected):
	currentDialog = null
	currentText = null
	if selected == null:
		return
	else:
		var chapter = chapter_list.get_item_text(selected)
		if chapter:
			currentChapter = chapter
			print("Current chapter is: ",currentChapter)
			get_dialogs(currentChapter)
			

func get_dialogs(chapter):
	dialog_list.clear()
	text_list.clear()
	chapter = contents[chapter]
	var dialogs = chapter.keys()
	for i in range(dialogs.size()):
		dialog_list.add_item(dialogs[i])
	if !dialog_list.is_connected("item_selected", self, "selected_dialog"):
		dialog_list.connect("item_selected", self, "selected_dialog")
	return


func selected_dialog(selected):
	currentText = null
	var dialog = dialog_list.get_item_text(selected)
	if dialog:
		currentDialog = dialog
		get_texts(currentDialog)
		
func get_texts(dialog):
	text_list.clear()
	currentText = null
	var texts = contents[currentChapter][dialog]
	for text in texts:
		var tempName = text.text.substr(0,25)
		text_list.add_item(tempName)
	if !text_list.is_connected("item_selected", self, "selected_text"):
		text_list.connect("item_selected", self, "selected_text")
	pass

func selected_text(selected):
	currentText = selected
	populate(currentText)

#==========================
# CHAPTER BUTTONS EVENTS
#==========================

func create_chapter(chapter_name):
	print("STARTING CREATE CHAPTER FUNCTION")
	if typeof(contents) == TYPE_DICTIONARY:
		print("It is a dictionary!")
		if chapter_name == "" or chapter_name == null or chapter_name == "cancel_error":
			print("different value given")
			return
		elif chapter_name in contents.keys():
			print("this one exists")
			return
		
		else:
			var newDialog = [new_text()]
			
			print("TYPE OF NEW DIALOG IS ",typeof (newDialog))
			contents[chapter_name] = {"New Dialog": newDialog}
			get_chapters()
			currentChapter = null
			currentDialog = null
			currentText = null
			dialog_list.clear()
			text_list.clear()
	pass

func duplicate_chapter(name):
	contents["new "+ name] = contents[name]
	get_chapters()

func remove_chapter(name):
	contents.erase(name)
	print("REMOVED CHAPTER ", name)
	get_chapters()
	dialog_list.clear()
	text_list.clear()

func rename_chapter(old_name, name):
	if name == "" or name == null or name == "cancel_error":
		return
	elif old_name in contents.keys():
		print("this one exists")
		var temp = contents[old_name]
		contents.erase(old_name)
		contents[name] = temp
		get_chapters()
	pass


#==========================
# DIALOG BUTTONS EVENTS
#==========================

func dialog_options(btn_index):
	currentText = null
	if currentChapter != null and currentChapter != "":
		if btn_index ==0:
			var input = input_tscn.instance()
			add_child(input)
			input.label.set_text("Name the dialog")
			create_dialog(yield(input, "text"))
			print(input)
			pass
		elif btn_index == 1:
			if currentDialog != null or currentDialog !="":
				if currentDialog != null and currentDialog != "":
					duplicate_dialog(currentDialog)

func dialog_options_2(btn_index):
	currentText = null
	if currentChapter != null and currentChapter != "":
		if btn_index == 0:
			if currentDialog != null and currentDialog != "":
				print("CHAPTER IS NOT NULL!")
				remove_dialog(currentDialog)
		elif btn_index == 1:
			print("Renaming Dialog")
			if currentDialog != null or currentDialog !="":
				var input = input_tscn.instance()
				add_child(input)
				input.label.set_text("Rename the dialog")
				rename_dialog(currentDialog, yield(input,"text"))
				get_dialogs(currentChapter)
				text_list.clear()

func create_dialog(dialog_name):
	print("Current chapter: ", contents[currentChapter], typeof(contents[currentChapter]))
	if typeof(contents[currentChapter]) == TYPE_DICTIONARY:
		print("CURRENT CHAPTER IS OK")
		if dialog_name == "" or dialog_name == null or dialog_name == "cancel_error":
			print("Dialog name is null ", dialog_name)
			return
		elif contents[currentChapter] != null:
			if dialog_name in contents[currentChapter].keys():
				print("this one exists")
				return
		
			else:
				var newDialog = [new_text()]
				contents[currentChapter][dialog_name] = newDialog
				get_dialogs(currentChapter)
				currentDialog = null
				currentText = null
				text_list.clear()
		pass


func duplicate_dialog(name):
	contents[currentChapter]["new "+ name] = contents[currentChapter][name]
	get_dialogs(currentChapter)
	text_list.clear()

func remove_dialog(name):
	contents[currentChapter].erase(name)
	print("REMOVED DIALOG ", name)
	get_dialogs(currentChapter)
	text_list.clear()

func rename_dialog(old_name, name):
	print("let's rock!")
	if name != "" or name != null or name != "cancel_error":
		print("For now it is ok")
		print(contents[currentChapter].keys())
		print("OLD NAME: ", old_name)
		if old_name in contents[currentChapter].keys():
			print("this one exists")
			var temp = contents[currentChapter][old_name]
			contents[currentChapter].erase(old_name)
			contents[currentChapter][name] = temp
			get_dialogs(currentChapter)
	pass


#TEXT EVENTS:

func create_text():
	if contents[currentChapter][currentDialog] == null: # Error checking
		return
	
	if currentText == null:
		
		contents[currentChapter][currentDialog].push_back(new_text())
	else:
		contents[currentChapter][currentDialog].insert(currentText+1, new_text())
		
	get_texts(currentDialog)
	currentText = null
	
	pass
	
func text_list_buttons(btn_index):
	if currentChapter != null and currentChapter != "":
		if currentDialog != null and currentDialog != "":
			if btn_index == 0:
				create_text()
			elif btn_index ==1:
				if currentText != null and typeof(currentText) == TYPE_INT:
					duplicate_text(currentText)
			elif btn_index == 2:
				if typeof(currentText) == TYPE_INT:
					remove_text(currentText)

func duplicate_text(index):
	if currentChapter != null and currentChapter != "":
		if currentDialog != null and currentDialog != "":
			if contents[currentChapter][currentDialog][index] != null:
				contents[currentChapter][currentDialog].append(contents[currentChapter][currentDialog][index])
				text_list.clear()
				get_texts(currentDialog)

func remove_text(index):
	if currentChapter != null and currentChapter != "":
		print("Chapter is null or doesn't exist")
		if currentDialog != null and currentDialog != "":
			print("Dialog is null or doesn't exist")
			if contents[currentChapter][currentDialog][index] != null:
				contents[currentChapter][currentDialog].remove(index)
				get_texts(currentDialog)
				

func moveText(btn_index):
	if currentChapter != null and currentChapter != "":
		if currentDialog != null and currentDialog != "":
			var pos
			if btn_index == 0:
				pos = -1
				var size = contents[currentChapter][currentDialog].size()-1
	#			Check if size is not null and if the new position won't go over or under the limits of the array 	
				if size != null:
					if currentText + pos != -1:
						var text= contents[currentChapter][currentDialog][currentText]
						print("Current text is: ",text)
						print("text exists")
				
		#				First removes	
						contents[currentChapter][currentDialog].remove(currentText)
		#				Then adds	
						contents[currentChapter][currentDialog].insert(currentText + pos, text)
						get_texts(currentDialog)
			elif btn_index == 1:
				pos = 1
				var size = contents[currentChapter][currentDialog].size()-1
	#			Check if size is not null and if the new position won't go over or under the limits of the array 	
				if size != null:
					if not currentText + pos > size:
						var text= contents[currentChapter][currentDialog][currentText]
		#				First removes	
						contents[currentChapter][currentDialog].remove(currentText)
		#				Then adds	
						contents[currentChapter][currentDialog].insert(currentText + pos, text)
						get_texts(currentDialog)

func manageQuestionOptions(value):
	print("Running the function to manage the answers")
	var childsNumber= options.get_child_count()
	
	if currentChapter != null and currentDialog != null and currentText != null:
		if enableQuestion.is_pressed():
			contents[currentChapter][currentDialog][currentText].answers.resize(value)
			print("ARRAY WITH ANSWERS: ",contents[currentChapter][currentDialog][currentText].answers)

func _exit_tree():
	
	pass

###################################
# Getters and setters
###################################

func agregate(text_id):
	if not currentChapter or not currentDialog:
		print("Error with chapter")
		if not currentDialog:
			print("Error with dialog")
			if typeof(currentText) == TYPE_NIL:
				print("Error with text")
		return
	var text = contents[currentChapter][currentDialog][text_id]
	text_list.set_item_text(currentText, text.text.substr(0,25))
	text.frame_position  = frame_position.get_selected()
	text.face_position = face_position.get_selected()
	text.face_frame = face_frame.get("range/value")
	
	text.typewriter = typewriter.get("is_pressed")
	text.typewriter_speed = typewriter_speed.get("range/value")
	text.beep = beep.get("is_pressed")
	
	text.beep_pitch = beep_pitch.get("range/value")
	text.text = textEditor.get_text()
	text.enable_question = enableQuestion.get("is_pressed")
	
	if enableQuestion.get("is_pressed"):
		text.answers.resize(choicesNumber.get_value())
		for i in range(choicesNumber.get_value()):
			text.answers[i] = options.get_child(i).get_node("text").get_text()
	else:
		text.answers = []

func populate(text_id):
#	Gives the editor items the respective values based on the save
	frame_position.select(contents[currentChapter][currentDialog][text_id].frame_position)
	face_position.select(contents[currentChapter][currentDialog][text_id].face_position)
	face_frame.set("range/value", contents[currentChapter][currentDialog][text_id].face_frame)
	typewriter.set("is_pressed", contents[currentChapter][currentDialog][text_id].typewriter)
	typewriter_speed.set("range/value", contents[currentChapter][currentDialog][text_id].typewriter_speed)
	beep.set("is_pressed", contents[currentChapter][currentDialog][text_id].beep)
	beep_pitch.set("range/value", contents[currentChapter][currentDialog][text_id].beep_pitch)
	
	
	
	textEditor.set_text(contents[currentChapter][currentDialog][text_id].text)
	
	enableQuestion.set("is_pressed", contents[currentChapter][currentDialog][text_id].enable_question)
	
	answers = contents[currentChapter][currentDialog][text_id].answers
	choicesNumber.set("range/value", answers.size())
	print("setting answers size")
	if choicesNumber.get("range/value") == 0:
		enableQuestion.set("is_pressed", false)
	for i in range(options.get_child_count()):
		print("cleaning option ", i)
		options.get_child(i).get_node("text").set_text("")
	if enableQuestion.get("is_pressed") and typeof(answers) == TYPE_ARRAY:
		for i in range(answers.size()):
			print("setting option ", i)
			options.get_child(i).get_node("text").set_text(answers[i])


func selectedTextButtons(btn_index):
	if typeof(currentText) != TYPE_INT:
		return
	if btn_index == 0:
		agregate(currentText)
#		Since currentText is set to null when create text is called, we store 
#		its value in a temp var so we can select this newly created text on the spot
		var tempCurrentText = currentText
		create_text()
		selected_text(tempCurrentText+1)
		print("Single Text is: ",single_text)
	if btn_index == 1:
		print("TESTING")

func clear_all():
	chapter_list.clear()
	dialog_list.clear()
	text_list.clear()
	currentChapter = null
	currentDialog = null
	currentText = null
	pass
