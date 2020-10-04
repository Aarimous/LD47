extends Node2D

var is_main = true
var spawned_main_gap = false
var is_playing = false
var mute = false
export var score = 0
var delta_time = 0
var time_threshold = 3

const GAP_LARGE = preload("res://Scenes/Gap_Large.tscn")
const GAP_MED = preload("res://Scenes/Gap_Med.tscn")
const GAP_SMALL = preload("res://Scenes/Gap_Small.tscn")

var white_list = [0,1,2,3,4,5]
var spawn_count = 0
var spawned_gap = false
func _ready():
		
	global.connect("point_won", self, "_on_Global_points_won")
	global.connect("game_over", self, "_on_Global_game_over")
	$UI/Score.text = String(score)
	_showMain()
	pass

func _showMain():
	$Help.visible = true
	$Help2.visible = false
	$UI.visible = false
	$Title.visible = true
	$GameOver.visible = false
	
func _startGame():
	is_main = false
	score = 0
	spawn_count = 0
	white_list = [0,1,2,3,4,5]
	delta_time = 0
	for n in $Gaps.get_children():
		$Gaps.remove_child(n)
		n.queue_free()
		
	$UI/Score.text = String(score)
	$GameOver.visible = false
	$Title.visible = false
	$Start.visible = false
	$UI.visible = true
	get_tree().paused = false
	is_playing = true
	
func _process(delta):
	
	if(Input.get_action_strength("Mute") > 0):
		if(mute == false):
			mute = true
			AudioServer.set_bus_mute(0,true)
		else:
			mute = false
			AudioServer.set_bus_mute(0,false)
	delta_time += delta
	if(white_list.size() > 0):
		if(is_main == false && is_playing == true):
			_game_loop(delta)
		elif(is_main == true && delta_time >= time_threshold && spawned_main_gap == false):
			spawned_main_gap = true
			delta_time = 0
			print("Main Large")
			var gap_inst = GAP_LARGE.instance()
			gap_inst.set_init(3, 0, 5, 3)
			$Help2.visible = true
			get_node("Gaps").add_child(gap_inst, false)
	else:
		print("No valid spawn locations")
		
func _game_loop(delta):
	
	if(delta_time >= time_threshold && spawned_gap == false):
		delta_time = 0
		var gap_inst
		if(spawn_count < 5):
			time_threshold = 5
			print("Large")
			gap_inst = GAP_LARGE.instance()
			gap_inst.set_init(_set_rotat() , 1, 3, 3)
		elif(spawn_count < 10):
			time_threshold = 4
			print("Medium")
			gap_inst = GAP_MED.instance()
			gap_inst.set_init(_set_rotat() , 2, 3, 3)
		else:
			time_threshold = clamp(time_threshold -.1, 1.4, 10)
			print("Threshold ", time_threshold )
			var rand = randf()
			print("Ranom Coinflip = ", rand)
			if(rand <= .5):
				print("Small")
				gap_inst = GAP_SMALL.instance()
				gap_inst.set_init(_set_rotat() , 2, 3, 3)
			else:
				print("Medium")
				gap_inst = GAP_MED.instance()
				gap_inst.set_init(_set_rotat() , 2, 3, 3)
		
		get_node("Gaps").add_child(gap_inst, false)
		spawn_count += 1

		
func _set_rotat():
	
	white_list.shuffle ()
	var rtn = white_list.pop_front ()
	return rtn

	var rotation
	if($Gaps.get_child_count() > 0):
		var good_spot = false
		while(good_spot == false):
			rotation = rand_range(0,360)
			good_spot = true
			for n in range(0,$Gaps.get_child_count()):
				if($Gaps.get_child(n) != null):
					var pos = $Gaps.get_child(n).rotation_degees
					var max_pos = max(wrapf(pos + 40, 0, 360) ,wrapf(pos - 40, 0, 360))
					var min_pos = min(wrapf(pos + 40, 0, 360) ,wrapf(pos - 40, 0, 360))
					if(rotation < max_pos || rotation > min_pos):
						good_spot = false
						break
	else:
		rotation = rand_range(0,360)
	return rotation
	
func _on_Global_points_won(points, slot):
	if(is_main):
		$Start.visible = true
		$Help.visible = false
		$Help2.visible = false
		pass
	else:
		$PointsSound.play()
		$Particles/Particles2D.emitting = false
		$Particles/Particles2D.emitting = true
		score += points	
		$UI/Score.text = String(score)
		white_list.append(slot)
	
func _on_Global_game_over():
	if(is_main):
		pass
	else:
		get_tree().paused = true
		$GameOver.show()
		print("GAME OVER")
	


func _on_Start_button_up():
	_startGame()
