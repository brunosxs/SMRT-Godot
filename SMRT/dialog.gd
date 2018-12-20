#------------------------------------------------------------------------------
# Copyright 2016 brunosxs
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of 
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to 
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ------------------------------------------------------------------------------

extends NinePatchRect

#Declared variables:

export (String, FILE, "*.lan") var language = "res://addons/SMRT/example.lan"
var dialogs = []
var speech_bubble
var side = null
var TOP
var MIDDLE
var BOTTOM

# EXPORTED VARS =====>
export (AudioStreamSample) var beep_WAV = preload("res://addons/SMRT/beep_letter.wav")
export (DynamicFont) var font = preload("res://addons/SMRT/font/main_font.tres")
export (int) var font_size = 32
export (SpriteFrames) var face_sprites
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


onready var audio = get_node("AudioStreamPlayer")
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
	print("VIEWPORT RECTANGLE ",get_viewport_rect().size)
	
	#defaults
	if beep_WAV == null:
		if show_debug_messages:
			beep_WAV = preload("res://addons/SMRT/beep_letter.wav")
			pass
	
	audio.stream = beep_WAV
	if font == null:
		if show_debug_messages:
			print("Font file not found, loading default")
		load("res://addons/SMRT/font/main_font.tres")
		
	if face_sprites == null:
		if show_debug_messages:
			print("Face sprites file not found")
	else:
		face.set_sprite_frames(face_sprites)
	if next_dialog_texture == null:
		preload("res://addons/SMRT/next_line.png")
	nextLine.set_texture(next_dialog_texture)

#	SIGNALS:
	hide()
	#Reset textObj	
	#Start the magic	
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
	textObj.bbcode_enabled = true
	textObj.bbcode_text = ""
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
		dictionary = JSON.parse(temp_lang)
		if typeof(dictionary.result) == TYPE_DICTIONARY:
			return dictionary.result
		else:
			if show_debug_messages:
				print("Error loading dialog file")
			return

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
					print("dialog ", dialog, " doesn't exist")
				emit_signal("finished")
				return
	if show_debug_messages:
		print("Starting the dialog system")
	on_dialog = true
	if not visible:
		visible = true
	finished = false
	side = 0
	nextLine.visible = false
	textObj.set_bbcode("")
	face.visible = false
#	ERROR checking
	if dialog_array == null or dialog_array.empty():
		yield(get_tree(),"idle_frame") # fix for signal not registering at the same loop
		if show_debug_messages:
			print("Dialog array is null or empty")
		emit_signal("finished")
		return
#	POSITION VARS:
	TOP= Vector2(0,0)
	MIDDLE = (get_viewport_rect().size/2)-Vector2(0,rect_size.y)
	BOTTOM = (get_viewport_rect().size)-Vector2(0,rect_size.y)	
#	A while loop that goes over each array value inside of dialog_array 
#	based on the start_at parameter
	while on_dialog and start_at < dialog_array.size():
		textObj.add_font_override("normal_font", font)
		nextLine.visible = false
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
				face.visible = true
		if dialog_array[start_at].has("face_position"):
			side = dialog_array[start_at].face_position
	
			face.show()
		if dialog_array[start_at].face_frame == null and dialog_array[start_at].face_frame <= face.frames.get_frame_count():
			texture_width = 0
			texture_height = 0
		else:
			print("CURRENT FRAME IS ", dialog_array[start_at].face_frame)
			texture_width = face.frames.get_frame("default", int(dialog_array[start_at].face_frame)).get_width()
			texture_height = face.frames.get_frame("default", int(dialog_array[start_at].face_frame)).get_height()
#		Side of the dialog to display the face
#		RESETING THE DIALOG	
		text = parser(dialog_array[start_at].text)
		textObj.bbcode_text = text
		textObj.set_visible_characters(-1)
		var screen_res = get_viewport_rect().size
		print("This is the screen res: ", screen_res)
		
		
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
			audio.play()
		
		
		rect_size = (Vector2(screen_res.x,screen_res.y/dialog_frame_height))
		textObj.rect_size = rect_size
		textObj.margin_right = 16
		textObj.margin_bottom = 8
		textObj.margin_left = 16
		textObj.margin_top = 8
		font.size = font_size
		nextLine.rect_position = rect_size-nextLine.rect_size

		#POSITION if the dialog is not bubble
		if position==0:
			rect_position = Vector2(0,0)
		elif position==1:
			rect_position = Vector2(0,screen_res.y/2)-Vector2(0,rect_size.y/2)
		
		elif position==2:
			rect_position = Vector2(0,screen_res.y-(get_size().y))
		var size = rect_size.x
		face_v_pos = rect_size.y/2 - (texture_height/2)
		print("The text is: ", textObj.text)
		if show_debug_messages:
			print("FACE V POS ", face_v_pos)
			# no image
		if side == 0:
			textObj.margin_left =  dimensions.text_margin.left
			textObj.margin_top = dimensions.text_margin.top
			textObj.margin_right = dimensions.text_margin.right
			textObj.margin_bottom = dimensions.text_margin.bottom
			face.visible = false
			#left side image
		elif side == 1:
			textObj.margin_left =  texture_width + texture_width/3
			textObj.margin_right = dimensions.text_margin.right
			face.position = Vector2(8+texture_width/2,face_v_pos)
			face.flip_h  = false
			face.visible = true
		elif side == 2:
			textObj.margin_left = dimensions.text_margin.left
			textObj.margin_right = texture_width + texture_width/3
			face.position = Vector2(rect_size.x-texture_width-8,face_v_pos)
			face.flip_h = true
		while textObj.get_total_character_count() > textObj.get_visible_characters():
			if not typewriter:
				textObj.set_visible_characters(textObj.get_total_character_count())
			#Play beep sound for each character
			if beep:
				audio.stream = beep_WAV
				audio.pitch_scale = beep_pitch
				audio.play()

				if show_debug_messages:
					print("Playing beep")
			textObj.visible_characters = textObj.visible_characters + 1
			timer.wait_time = speed
			timer.start()
			yield(timer, "timeout") #So, it will only happen if it is false at first
		if textObj.get_total_character_count() <= textObj.visible_characters:# and not finished and start_at < dialog_array.size()-1:
			get_node("nextLine/AnimationPlayer").play("idle")
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
	visible = false

func question(answer_array):
	if show_debug_messages:
		print("STARTED QUESTION FUNCTION")
	btn_answers = VBoxContainer.new()
	btn_answers.set_alignment(HALIGN_LEFT)
	
	btn_answers.set_anchor(MARGIN_LEFT, ANCHOR_BEGIN)
	btn_answers.set_anchor(MARGIN_TOP, ANCHOR_BEGIN)
	btn_answers.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	btn_answers.set_anchor(MARGIN_BOTTOM, ANCHOR_END)
	
	dialog_dup = duplicate()
	dialog_dup.rect_size = btn_answers.rect_position
	dialog_dup.visible = false
	btn_answers.rect_position = (Vector2(0,0))
	dialog_dup.set_script(null)
	add_child(dialog_dup)
	for child in dialog_dup.get_children():
		child.queue_free()
	remove_child(btn_answers)
	dialog_dup.add_child(btn_answers)
	btn_answers.grab_focus()
	btn_answers.rect_size = (Vector2(0,0))
	if position <= 1:
		dialog_dup.rect_position = (Vector2(textObj.rect_position.x, get_viewport_rect().size.y/2))
	else:
		#question will appear on top of the dialog
		dialog_dup.rect_position = (Vector2(textObj.rect_position.x, rect_size.y*-1))
	var index = 0
	for answer in answer_array:
		var b = Button.new()
		b.set_text(answer)
		b.add_font_override("font", font)
		b.set_flat(true)
		b.add_stylebox_override("normal", StyleBox)
		b.add_stylebox_override("selected", StyleBox)
		b.add_stylebox_override("pressed", StyleBox)
		b.add_stylebox_override("hover", StyleBox)
		b.add_font_override("font_selected", font)
		btn_answers.add_child(b)
		b.connect("pressed",self,"selected_answer",[index])
		if index > 0:
			var last_child = btn_answers.get_child(index-1)
			b.set_focus_neighbour(MARGIN_TOP,last_child.get_path())
			btn_answers.rect_size.y += b.rect_size
			index+=1
	
	yield(get_tree(),"idle_frame")
	btn_answers.get_children()[0].grab_focus()
	yield(get_tree(), "idle_frame")
	btn_answers.set_margin(MARGIN_RIGHT, 0)
	dialog_dup.visible = true
	dialog_dup.rect_size = btn_answers.rect_size

func selected_answer(btn):
	if show_debug_messages:
		print("Answer selected: ", btn)
	answer_number = btn
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
			# TODO BEEP SFX
	if finished and not event.is_echo() and event.is_action_pressed("ui_accept"):
		emit_signal("dialog_control", info)
	

func stop():
	if show_debug_messages:
		print("Stopping smrt godot")
	if typeof(btn_answers) != TYPE_NIL:
		if btn_answers is ButtonGroup:
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
			b = string_to_change.find("}}", index)
			part = string_to_change.substr(part_start, sub["start"]-part_start)
			new_string += part
			if b != -1:
				sub["end"] = b
				sub["string"] = string_to_change.substr(sub["start"]+2, sub["end"] - sub["start"]-2)
				if ProjectSettings.has_setting(sub["string"]):
					var dynamic_value = ProjectSettings.get_setting(sub["string"])

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