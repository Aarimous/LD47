extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var sides_entered = 0
var time_in_gap = 0
var threshold = 1
var deleting = false

export var time_alive = 0
export var die_start_threshold = 3
export var time_die = 0
export var die_animiation_time = 3
export var pts = 1
export var slot = 0

func set_init(slot, pts, die_start_threshold, die_animiation_time):
	self.slot = slot
	self.rotation_degrees =  (slot * 60) + rand_range(-10,10)
	self.pts = pts
	self.die_animiation_time = die_start_threshold
	self.die_animiation_time = die_animiation_time
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Fade_In")

func _process(delta):
	time_alive += delta
	
	if(sides_entered == 2):
		if(time_die > 0):
			_reset_color()
			time_die = 0
			
		time_in_gap += delta
		if($AudioStreamPlayer2D.playing == false):
			$AudioStreamPlayer2D.play(2.9 + time_in_gap)
		$Sprite.modulate.g += 1 * delta
		$Sprite.modulate.b -= 1 * delta
		$Sprite.modulate.r -= 1 * delta
		if(time_in_gap >= threshold && deleting == false):
			global.emit_signal("point_won", pts, slot)
			$AnimationPlayer.play("Fade")
			deleting = true
			yield($AnimationPlayer, "animation_finished")
			
			queue_free()
			
	elif(time_alive >= die_start_threshold):
		time_in_gap = clamp(time_in_gap - delta, 0, threshold)
		time_die += delta
		$Sprite.modulate.g -= 1 * delta
		$Sprite.modulate.b -= 1 * delta
		$Sprite.modulate.r += 1 * delta
		
		if(time_die >= die_animiation_time):
			global.emit_signal("game_over")
	
	elif(deleting == false):
		$AudioStreamPlayer2D.stop()	
		
func _reset_color():
		$Sprite.modulate.g = 1.3
		$Sprite.modulate.b = 1.3
		$Sprite.modulate.r = 1.3

func _on_Area2D_area_entered(area):
	sides_entered += 1
		
func _on_Area2D_area_exited(area):
	sides_entered -= 1
