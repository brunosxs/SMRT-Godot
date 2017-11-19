extends Patch9Frame

#Declared variables:

export (String, FILE, "*.lan") var language = "res://addons/SMRT/example.lan"
var dialogs = []
var speech_bubble
var side = null
var TOP
var MIDDLE
var BOTTOM

# EXPORTED VARS =====>
export (Sample) var beep_WAV = preload("res://addons/SMRT/beep_letter.wav")
export (DynamicFont) var font = preload("res://addons/SMRT/font/main_font.tres")
export (int) var font_size = 32
export (SpriteFrames) var face_sprites = preload("res://addons/SMRT/faces/dialog.tres")
export (Texture) var next_dialog_texture = preload("res://addons/SMRT/next_line.png")
export var dialog_frame_height = 4
var face_v_pos = 0
#DEBUG MESSAGES
export var show_debug_messages = false
#Speed of the typewriter effect. If there is no value given in the message,
#it defaults to this.
var speed = float(.05)

signal  finished
signal answer_selected
signal dialog_control(information)
#Global variable to change the position of the dialog on the viewport.
#It is a string that is interpreted: "top", "middle" and "down"
#Thinking of making some global constants and change it to vector2 values
var position

#If true, a beep sound will play for each character, excluding " "
var beep = true
# The pitch is a float that enables the beep to sound lower or higher to
# create variations for characters.
var beep_pitch = float(1.0)
var finished = false
var on_dialog = false
var text
var typewriter = true
var enable_question
var answers
var dialog_dup
var btn_answers
var answer_number
var black_screen
var texture_width
var texture_height
var dialog_array
#THE NEXT VAR IS SENT THROUGH THE SIGNALS dialog_control 
#AND answer_selected
var info = {chapter = null, dialog = null, last_text_index = null, total_text = null, answer = null}

var dimensions = {"box_rectangle": null, "text_rectangle": null, "font_size": null, "text_margin":{"left": null, "right": null, "top":null, "bottom":null}}


onready var audio = get_node("SamplePlayer")
	#Get the label object in which the text will be displayed to the user
onready var textObj= get_node("text_display")
	#The "Press button" to continue
onready var nextLine = get_node("nextLine")
	#Timer for the loop of the main function
onready var timer = get_node("Timer")

#Get avatar sprite object
onready var face = get_node("face")
onready var anim = get_node("anim")

func _ready():
	language = load_language(language)
	
	#defaults
	if beep_WAV == null:
		if show_debug_messages:
			print("Beep sound file not found, loading default")
		preload("res://addons/SMRT/beep_letter.wav")
	var beep = SampleLibrary.new()
	beep.add_sample("beep_letter", beep_WAV)
	audio.set_sample_library(beep)
	if font == null:
		if show_debug_messages:
			print("Font file not found, loading default")
		load("res://addons/SMRT/font/main_font.tres")
		
	if face_sprites == null:
		if show_debug_messages:
			print("Face sprites file not found, loading default")
		preload("res://addons/SMRT/faces/dialog.tres")
		
	face.set_sprite_frames(face_sprites)
	if next_dialog_texture == null:
		preload("res://addons/SMRT/next_line.png")
	nextLine.set_texture(next_dialog_texture)

#	SIGNALS:
	hide()
	#Reset textObj	
	#Start the magic	
	set_process_input(true)
	set_process_input(true)
	store_dimensions()
	store_margins()
	
func reset():
	if show_debug_messages:
		print("reseting the dialog system")
	finished = false
	on_dialog = false
	text = null
	position= null
	side = null
	answer_number = null
	textObj.set_bbcode("")
	dialog_array = []
	
	
func load_language(lang_file="res://addons/SMRT/example.lan"):
	var file = File.new()
	if lang_file == null:
		lang_file = "res://addons/SMRT/example.lan"
	#Check for and load the language file
	if (file.open(lang_file,File.READ) == OK):
		if show_debug_messages:
			print("Found dialog file" , lang_file)
		var temp_lang = file.get_as_text()
		var dictionary = {}
		dictionary.parse_json(temp_lang)
		return dictionary
	else:
		if show_debug_messages:
			print("Error loading dialog file")
		var temp_lang = {"Problem":{"Debug":[{"beep_pitch":1, "face_position":1, "beep":true, "text":"Error loading the language file!", "enable_question":false, "typewriter_speed":0.05, "typewriter":true, "frame_position":1, "face_frame":1}]}}
		var dictionary = {}
		dictionary.parse_json(temp_lang)
		
		return dictionary

func store_dimensions():
	dimensions.box_rectangle = get_rect()
	dimensions.text_rectangle = textObj.get_rect()
	
	dimensions.text_rectangle.size.x += textObj.get_margin(0) + textObj.get_margin(2)
	dimensions.text_rectangle.size.y += textObj.get_margin(1) + textObj.get_margin(3)
	dimensions.font_size = font_size

func store_margins():
	dimensions.text_margin.left = textObj.get_margin(0)
	dimensions.text_margin.top = textObj.get_margin(1)
	dimensions.text_margin.right = textObj.get_margin(2)
	dimensions.text_margin.bottom = textObj.get_margin(3)

func show_text(chapter, dialog, start_at = 0):
	textObj.set_bbcode("")
	text=""
	if start_at == null:      
		start_at = 0
	if chapter =="single_text":
		info = {chapter = chapter, dialog = null, last_text_index = null, total_text = 1, answer = null}
		dialog_array = dialog
		position = 1
	if typeof(dialog_array) == TYPE_STRING:
		var single_text = {"text": parser(dialog_array)}
		dialog_array = []
		dialog_array.append(single_text)
	if language.has(chapter):
		var current_chapter = language[chapter]
		if current_chapter.empty():
			dialog_array.append({text: "Chapter has no dialogs"})
		else:
			
			if current_chapter.has(dialog):
				if show_debug_messages:
					print("found dialog ", dialog)
			
				dialog_array = current_chapter[dialog]
				if not dialog_array == null and typeof(dialogs) == TYPE_ARRAY:
#				STORE INFO	
					info.chapter = chapter
					info.dialog = dialog
					info.total_text = dialog_array.size()-1
				else: 
					yield(get_tree(),"idle_frame") # fix for signal not registering at the same loop
					emit_signal("finished")
					if show_debug_messages:
						print("dialog is null or empty")
					return
			else: 
				yield(get_tree(),"idle_frame") # fix for signal not registering at the same loop
				if show_debug_messages:
					print("dialog doesn't exist")
				emit_signal("finished")
				return
	if show_debug_messages:
		print("Starting the dialog system")
	on_dialog = true
	if is_hidden():
		show()
	finished = false
	side = 0
	nextLine.hide()
	textObj.set_bbcode("")
	face.hide()
#	ERROR checking
	if dialog_array == null or dialog_array.empty():
		yield(get_tree(),"idle_frame") # fix for signal not registering at the same loop
		if show_debug_messages:
			print("Dialog array is null or empty")
		emit_signal("finished")
		return
#	POSITION VARS:
	TOP= Vector2(0,0)
	MIDDLE = (get_viewport_rect().size/2)-Vector2(0,get_size().y)
	BOTTOM = (get_viewport_rect().size)-Vector2(0,get_size().y)	
#	A while loop that goes over each array value inside of dialog_array 
#	based on the start_at parameter
	while on_dialog and start_at < dialog_array.size():
		textObj.add_font_override("normal_font", font)
		nextLine.hide()
#		Gets the values to be reseted at the end of the loop
		# ERROR CHECKING:
		if show_debug_messages:
			print("STARTED DIALOG AT ", start_at)
		if dialog_array[start_at].has("beep"):
			beep = dialog_array[start_at].beep
		if dialog_array[start_at].has("beep_pitch"):
			beep_pitch = dialog_array[start_at].beep_pitch
		if dialog_array[start_at].has("frame_position"):
			position = dialog_array[start_at].frame_position
		if dialog_array[start_at].has("enable_question"):
			enable_question = dialog_array[start_at].enable_question
			if dialog_array[start_at].has("answers"):
				answers = dialog_array[start_at].answers
		# face frame and face position
		if dialog_array[start_at].has("face_frame"):
			if typeof(dialog_array[start_at].face_frame) == TYPE_REAL or typeof(dialog_array[start_at].face_position) == TYPE_INT:
				face.set_frame(int(dialog_array[start_at].face_frame))
				face.show()
		if dialog_array[start_at].has("face_position"):
			side = dialog_array[start_at].face_position
	
			face.show()
		texture_width = face.get_sprite_frames().get_frame(face.get_animation(), face.get_frame()).get_width()
		texture_height = face.get_sprite_frames().get_frame(face.get_animation(), face.get_frame()).get_height()
#		Side of the dialog to display the face
#		RESETING THE DIALOG	
		text = parser(dialog_array[start_at].text)
		textObj.set_bbcode(text)
		textObj.set_visible_characters(-1)
		var screen_res = get_tree().get_root().get_rect()
		
		
#		SPEED
		if dialog_array[start_at].has("typewriter"):
			typewriter = dialog_array[start_at].typewriter
		
		if typewriter:
	
			if dialog_array[start_at].has("typewriter_speed"):
				
				speed = dialog_array[start_at].typewriter_speed

#		If typewriter boolean is false, then gives ZERO to speed variable
#		to make the effect disapear.
		else:
			pass
#			audio.play("beep_letter")
		
		
		set_size(Vector2(screen_res.size.x,screen_res.size.y/dialog_frame_height))
		textObj.set_size(get_size())
		textObj.set_margin(0, 16)
		textObj.set_margin(1, 8)
		textObj.set_margin(2, 16)
		textObj.set_margin(3, 8)
		font.set_size(font_size)
		nextLine.set_pos(get_size()-nextLine.get_size())

		#POSITION if the dialog is not bubble
		if position==0:
			set_pos(Vector2(0,0))
		elif position==1:
			set_pos(Vector2(0,screen_res.size.y/2)-Vector2(0,get_size().y/2))
		
		elif position==2:
			self.set_pos(Vector2(0,screen_res.size.y-(get_size().y)))
		var size = get_size().x
		face_v_pos = get_size().y/2 - (texture_height/2)
		if show_debug_messages:
			print("FACE V POS ", face_v_pos)
		if side == 0:
			textObj.set_margin(0, dimensions.text_margin.left)
			textObj.set_margin(1, dimensions.text_margin.top)
			textObj.set_margin(2, dimensions.text_margin.right)
			textObj.set_margin(3, dimensions.text_margin.bottom)
			face.hide()
		elif side == 1:
			textObj.set_margin(0, texture_width + texture_width/3)
			textObj.set_margin(2, dimensions.text_margin.right)
			face.set_pos(Vector2(8,face_v_pos))
			face.set_flip_h(false)
			face.show()
		elif side == 2:
			textObj.set_margin(2, texture_width + texture_width/3)
			textObj.set_margin(0, dimensions.text_margin.left)
			face.set_pos(Vector2(get_size().x-texture_width-8,face_v_pos))
			face.set_flip_h(true)
			face.show()
		while textObj.get_total_character_count() > textObj.get_visible_characters():
			if not typewriter:
				textObj.set_visible_characters(textObj.get_total_character_count())
			#Play beep sound for each character
			if beep:
				audio.set_default_pitch_scale(beep_pitch)
				audio.play("beep_letter")
				if show_debug_messages:
					print("Playing beep")
				#audio.set_param(1,old_beep_pitch)
			textObj.set_visible_characters(textObj.get_visible_characters()+ 1)
			timer.set_wait_time(speed)
			timer.start()
			yield(timer, "timeout") #So, it will only happen if it is false at first
		if textObj.get_total_character_count() <= textObj.get_visible_characters():# and not finished and start_at < dialog_array.size()-1:
			get_node("nextLine/animation").play("idle")
			if show_debug_messages:
				print("Finished text display")
			finished = true
			yield(get_tree(), "idle_frame")
			info.last_text_index = start_at
			yield(self,"dialog_control")
			if enable_question:
				question(answers)
				start_at +=1
				yield(self, "answer_selected")
			else:
				start_at +=1
			finished = false
			#RESET The message system:
	on_dialog = false
# Emits a signal when all the dialogs are over.
# Useful to know exactly when it is possible to free the resources it holds.
	if show_debug_messages:
		print("SMRT finished displaying all the dialog")
	emit_signal("finished")
	beep_pitch = 1.0
	self.hide()

func question(answer_array):
	if show_debug_messages:
		print("STARTED QUESTION FUNCTION")
	btn_answers = ButtonGroup.new()
	btn_answers.set_alignment(HALIGN_LEFT)
	
	btn_answers.set_anchor(MARGIN_LEFT, ANCHOR_BEGIN)
	btn_answers.set_anchor(MARGIN_TOP, ANCHOR_BEGIN)
	btn_answers.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	btn_answers.set_anchor(MARGIN_BOTTOM, ANCHOR_END)
	
	dialog_dup = self.duplicate()
	dialog_dup.set_pos(btn_answers.get_pos())
	dialog_dup.set_opacity(0)
	btn_answers.set_pos(Vector2(0,0))
	dialog_dup.set_script(null)
	add_child(dialog_dup)
	for child in dialog_dup.get_children():
		child.queue_free()
	remove_child(btn_answers)
	dialog_dup.add_child(btn_answers)
	btn_answers.grab_focus()
	btn_answers.set_size(Vector2(0,0))
	
	btn_answers.connect("button_selected", self, "selected_answer")
	if position <= 1:
		dialog_dup.set_pos(Vector2(textObj.get_pos().x, get_rect().size.y/2))
	else:
		#question will appear on top of the dialog
		dialog_dup.set_pos(Vector2(textObj.get_pos().x, get_rect().size.y*-1))
	var index = 0
	for answer in answer_array:
		yield(get_tree(),"idle_frame")
		var b = Button.new()
		b.set_text(answer)
		b.add_font_override("font", font)
		b.set_flat(true)
		b.add_style_override("normal", StyleBoxEmpty.new())
		b.add_style_override("selected", StyleBoxEmpty.new())
		b.add_style_override("pressed", StyleBoxEmpty.new())
		b.add_style_override("hover", StyleBoxEmpty.new())
		b.add_font_override("font_selected", font)
#		b.set_h_size_flags(0)
		btn_answers.add_child(b)
#		if index > 0:
#			var last_child = btn_answers.get_child(index-1)
#			b.set_focus_neighbour(MARGIN_TOP,last_child.get_path())
#		index+=1
	btn_answers.get_children()[0].grab_focus()
	btn_answers.update()
	yield(get_tree(), "idle_frame")
	dialog_dup.set_size(Vector2(get_size().x/2,btn_answers.get_size().y))
	dialog_dup.update()
	btn_answers.set_margin(MARGIN_RIGHT, 0)
	dialog_dup.set_opacity(1)

func selected_answer(btn):
	if show_debug_messages:
		print("Answer selected: ", btn)
	answer_number = btn.get_index()
	info.answer = answer_number
	answer_number = null
	emit_signal("dialog_control", info)
	emit_signal("answer_selected")
	dialog_dup.queue_free()
	info.answer = null
	
func _input(event):
	
	
	if not event.is_echo() and event.is_action_pressed("ui_accept"):
		if textObj.get_total_character_count() > textObj.get_visible_characters() and on_dialog:
			textObj.set_visible_characters(textObj.get_total_character_count())
			audio.play("beep_letter")
	if finished and not event.is_echo() and event.is_action_pressed("ui_accept"):
		emit_signal("dialog_control", info)
	

func stop():
	if show_debug_messages:
		print("Stopping smrt godot")
	if typeof(btn_answers) != TYPE_NIL:
		if btn_answers extends HButtonArray:
			btn_answers.queue_free()
	reset()

func parser(string_to_change):
	var found = 0
	if show_debug_messages:
		print("This is the string: ", string_to_change)
	var index = 0
	var new_string =""
	var sub = {}
	while index < string_to_change.length():
		var b = string_to_change.find("{{", index)
		var part_start = index
		if b != -1:
			found+=1
			var part
			index = b
			sub["start"] = index
			var b = string_to_change.find("}}", index)
			part = string_to_change.substr(part_start, sub["start"]-part_start)
			new_string += part
			if b != -1:
				sub["end"] = b
				sub["string"] = string_to_change.substr(sub["start"]+2, sub["end"] - sub["start"]-2)
				if Globals.has(sub["string"]):
					var dynamic_value = Globals.get(sub["string"])

					string_to_change.erase(0, sub["end"])
					if show_debug_messages:
						print("STRING TO CHANGE: ",string_to_change)
#					string_to_change.insert(index, dynamic_value)
					new_string += str(dynamic_value)
					if show_debug_messages:
						print(dynamic_value)
					index = 0

				else:
					pass
				index +=1

		index +=1	
	if found > 0:
		string_to_change.erase(0,2)
		new_string += string_to_change
		if show_debug_messages:
			print("String after change: ", new_string)
		return new_string
	else:
		if show_debug_messages:
			print("Returning the old string: ", string_to_change)
		return string_to_change