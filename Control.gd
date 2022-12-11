extends Control


# Declare member variables here. Examples:
# var a = 2

var output = []
# var b = "text"

var files =[]
var files_out = []
var folder_cache = {}
var regex_string = ".*"
var regex_out_string =""
var regex_machine = null
func _ready():
	_on_RegexFind_text_changed()
	$VBoxContainer/HBoxContainer/RegexFind.text = regex_string
	
	var default_dir = "I:\\torr"
	if OS.get_cmdline_args():
		print("ssss"+OS.get_cmdline_args()[0])
		default_dir = OS.get_cmdline_args()[0]
	$PickFile.current_dir =default_dir
	_on_PickFile_dir_selected( default_dir )
	
func _on_Button_pressed():
	$PickFile.popup() # Replace with function body.

func is_folder(path):
	if not path in folder_cache:
		folder_cache[path]=Directory.new().open(current_dir()+"\\"+path) == OK
	return folder_cache[path]
func encode_bb_code(path):
#	path=path.replace("[","%5B")
#	path= path.replace("]","%5D")
	return 	path.percent_encode()
func decode_bb_code(path):
#	path=path.replace("%5B","[")
#	path= path.replace("%5D","]")
	return path.percent_decode()
	
func files_in_dir(dir):
	files = []
	var d = Directory.new()
	d.open(dir)
	d.list_dir_begin()
	var file = d.get_next()
	
	
	while file != "":
		if not file.begins_with(".") and regex_machine.search(file):
			files.append(file)
		file = d.get_next()
	d.list_dir_end()
	return files
	
	
func _on_PickFile_dir_selected(dir):
	dir = decode_bb_code(dir)
	print("nav to> "+dir)
	$PickFile.current_dir = dir
	current_dir_node().text  = dir
	
	
	files = files_in_dir(dir)
	files_out=[]
	
	
	var file_collection = $VBoxContainer/HSplitContainer/FileList
	var file_ui_component = $VBoxContainer/HSplitContainer/FileList/File
	var file_collection_2 = $VBoxContainer/HSplitContainer/renames
	var file_ui_component_2 = $VBoxContainer/HSplitContainer/renames/File
	
	for child in file_collection.get_children():
		if child!=file_ui_component:
			file_collection.remove_child(child)
	for child in file_collection_2.get_children():
		if child!=file_ui_component_2:
			file_collection_2.remove_child(child)
			
	var max_files = 50
	var max_files2 = 50
	var copy_text = null
	
	for F in files:
		if not copy_text:
			copy_text=F		
					
		if  max_files > 0:
			max_files -= 1
			var new_node = file_ui_component.duplicate()
			new_node.text=""
			if is_folder(F):
				#print("File\t"+F)
				new_node.append_bbcode("[url="+ encode_bb_code(F)+"]" +F + "[/url]")
			else:
				new_node.append_bbcode(F)
			new_node.visible = true
			file_collection.add_child(new_node)
		if  regex_machine.search(F).get_start() == 0 and  regex_machine.search(F).get_end() == F.length() and regex_machine.sub(F,regex_out_string) and max_files2 >0:
			max_files2 -= 1
			var new_node = file_ui_component_2.duplicate()
			new_node.text=regex_machine.sub(F,regex_out_string)
			files_out.append([F,regex_machine.sub(F,regex_out_string)])
			
			new_node.visible = true
			file_collection_2.add_child(new_node)
	if copy_text:
		$VBoxContainer/HBoxContainer3/CopyArea.text = copy_text


func current_dir():
	return $VBoxContainer/HBoxContainer2/CurrentDir.text

func current_dir_node():
	return $VBoxContainer/HBoxContainer2/CurrentDir
func _on_RegexFind_text_changed():
	var t = $VBoxContainer/HBoxContainer/RegexFind.text
	var t2 =  null
	var reg_temp = RegEx.new()
	reg_temp.compile(t)
	print(t)
	print(reg_temp.get_group_count())
	if reg_temp.get_group_count()==0:
		t2="("+t+")"
	var r = RegEx.new()
	print(t2)
	var Validation = r.compile(t) if not t2 else r.compile(t2)
	
	if $VBoxContainer/HBoxContainer/RegexReplace.text=="":
		regex_out_string = "$1"
		$VBoxContainer/HBoxContainer/RegexReplace.text = "$1"
		
	#_on_RegexReplace_text_changed()
	if Validation == OK:
		regex_string = t
		regex_machine = r
		_on_PickFile_dir_selected(current_dir())
		#$VBoxContainer/HBoxContainer/RegexFind.set_custom_bg_color(0, Color(0,222,0))
	else:
		print("failed compilation")#$VBoxContainer/HBoxContainer/RegexFind.set_custom_bg_color ( Color(0,0,222))
	
	 # Replace with function body.


func _on_RegexReplace_text_changed():
	regex_out_string = $VBoxContainer/HBoxContainer/RegexReplace.text
	
	_on_PickFile_dir_selected(current_dir())


func _on_groupfolder_pressed():
	var directory = Directory.new()
	
	var new_dir_name = current_dir() 
	
	if not $VBoxContainer/HBoxContainer2/TextEdit.text.empty():
		new_dir_name+="\\"+$VBoxContainer/HBoxContainer2/TextEdit.text

	if new_dir_name.ends_with(" ") or new_dir_name.begins_with(" "):
		print("no spaces at begin or end")
		return
	
		
	for F in files_out:
		var new_dir_local = new_dir_name
		var from = current_dir()+"\\"+F[0]
		new_dir_local = regex_machine.sub(F[0],new_dir_local)
		if not directory.dir_exists(new_dir_local):
			OS.execute("CMD.EXE",[ "/C","mkdir \""+new_dir_local+"\""],true,output)
		var to = new_dir_local+"\\"+F[1]
		print("mv \""+from+"\" \""+to+"\"")
		#var status=directory.copy(current_dir()+"/"+F[0],new_dir_name+"/"+F[1])
		var output = []
		var status = OS.execute("CMD.EXE",[ "/C","mv \""+from+"\" \""+to+"\""],true,output)
		for x in output:
			print(x)
	_on_PickFile_dir_selected(current_dir())
	
	


func _on_UPButton_pressed():
	var d = Directory.new()
	d.open(current_dir())
	d.change_dir("..")
	_on_PickFile_dir_selected(d.get_current_dir())


func _on_File_meta_clicked(meta):
	#print("meta"+meta)
	_on_PickFile_dir_selected(current_dir()+"\\"+meta)


func _on_Destroy_pressed():
	for f in files_out:
		if is_folder(f[0]):
			OS.execute("CMD.EXE",[ "/C","rmdir /S /Q \""+current_dir()+"\\"+f[0]+"\""],true,output)
			print("rmdir /S /Q \""+current_dir()+"\\"+f[0]+"\"")
		else:
			OS.execute("CMD.EXE",[ "/C","rm \""+current_dir()+"\\"+f[0]+"\""],true,output)
			folder_cache.erase(f[0])
			print("rm "+current_dir()+"\\"+f[0])
	_on_PickFile_dir_selected(current_dir())
	 # Replace with function body.


func _on_extract_pressed():
	print("extract")
	for F in files:
		if not is_folder(F):
			continue
			
		var all_sucesfully_moved = true
			
		print(current_dir()+"\\"+F)
		var d = Directory.new()
		
		var err = d.open(current_dir()+"\\"+F)
		if err:
			print("failed opening "+F)
			continue
			
		d.list_dir_begin()
		var file = d.get_next()
		
		while file != "":
			if not file.begins_with("."):
				print("/C","mv "+"'"+current_dir()+"\\"+F+"\\"+file+"' '"+current_dir()+"\\"+file+"'")					
				OS.execute("CMD.EXE",[ "/C","mv "+"'"+current_dir()+"\\"+F+"\\"+file+"' '"+current_dir()+"\\"+file+"'"],true,output)
				
				if output[0].length()>0:
					all_sucesfully_moved = false
				 #OS.execute("CMD.EXE",[ "/C","rmdir "+"'"+current_dir()+"\\"+F+"'"],true,output)
			file = d.get_next()
		d.list_dir_end()
		if all_sucesfully_moved:
			print("rmdir /S /Q \""+current_dir()+"\\"+F+"\"")
			OS.execute("CMD.EXE",[ "/C","rmdir /S /Q \""+current_dir()+"\\"+F+"\""],true,output)
			 # Replace with function body.
	_on_PickFile_dir_selected(current_dir())


func _on_cpy_text_pressed():
	var CopyArea = $VBoxContainer/HBoxContainer3/CopyArea
	CopyArea.text = CopyArea.text.percent_decode()
	CopyArea.text = CopyArea.text.replace("(","\\(")
	CopyArea.text = CopyArea.text.replace(")","\\)")
	CopyArea.text = CopyArea.text.replace("[","\\[")
	CopyArea.text = CopyArea.text.replace("]","\\]")
	OS.set_clipboard($VBoxContainer/HBoxContainer3/CopyArea.text) # Replace with function body.
	$VBoxContainer/HBoxContainer/RegexFind.text= $VBoxContainer/HBoxContainer3/CopyArea.text
	_on_RegexFind_text_changed()


func _on_TextEdit_text_changed():
	var NewDirField = $VBoxContainer/HBoxContainer2/TextEdit
	NewDirField.text = NewDirField.text.percent_decode()
	NewDirField.text = NewDirField.text.replace("\\(","(")
	NewDirField.text = NewDirField.text.replace("\\)",")")
	NewDirField.text = NewDirField.text.replace("\\[","[")
	NewDirField.text = NewDirField.text.replace("\\]","]")
	NewDirField.cursor_set_column(NewDirField.text.length())
	
func _input(event):
	if event.is_action_pressed("ui_copy"):
		_on_cpy_text_pressed()
		get_tree().set_input_as_handled()


func _on_MYNewButton_pressed():
	
	$VBoxContainer/HBoxContainer/RegexFind.text += ".*[s|S](..)[e|E](..).*(....)"
	_on_RegexFind_text_changed()
	if $VBoxContainer/HBoxContainer/RegexReplace.text.ends_with("$1"):
		$VBoxContainer/HBoxContainer/RegexReplace.text = $VBoxContainer/HBoxContainer/RegexReplace.text.substr(0,$VBoxContainer/HBoxContainer/RegexReplace.text.length()-2)
	
	$VBoxContainer/HBoxContainer/RegexReplace.text += " S$1E$2$3"
	_on_RegexReplace_text_changed()
		

