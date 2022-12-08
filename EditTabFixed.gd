extends TextEdit

export var supress_tab : bool = true
func _ready():
	pass # Replace with function body.
	
func _input(event):
	if not supress_tab:
		return
		
	if not event.shift and event.is_action_pressed("ui_next") and has_focus():
		if focus_next != "":
			get_node(focus_next).grab_focus()
		get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_previous") and has_focus():
		if focus_previous != "":
			get_node(focus_previous).grab_focus()
		get_tree().set_input_as_handled()
# Called every frame. 'delta' is the elapsed

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
