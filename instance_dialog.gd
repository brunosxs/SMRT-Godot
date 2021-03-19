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

tool

extends Control

# WORKAROUND (06/08/2016)
# As Godot's plugin system doesn't allow us to create or instance scenes with child nodes as
# custom types, this script does the dirty job for us...



var dialog = preload("res://addons/SMRT/dialog.tscn") #reference to the dialog scene

func _ready():
	var n = dialog.instance(true) #instance a new scene
	get_parent().add_child(n) #add the scene to out parent, remember we are a recently created Control
	if (get_parent().get_owner()):
		n.set_owner(get_parent().get_owner())
	else:
		n.set_owner(get_parent())
	call_deferred("queue_free")


