extends Node2D

var _velocity = 0
var _accel = 200
var _deccel = 150
var MAX_SPEED = 180

func _ready():
	rotation_degrees = 0
	pass

func _process(delta):
	
	var direction = get_direction()
	update_velocity(direction, delta)
	rotation_degrees = rotation_degrees + (delta * _velocity)
	
func get_direction():
	return Input.get_action_strength("Clockwise") - Input.get_action_strength("CounterClockwise")

func update_velocity(direction, delta):

	if(direction > 0):
		_velocity = clamp( _velocity +  _accel * delta,  0, MAX_SPEED)
	elif(direction < 0):
		_velocity = clamp( _velocity - _accel * delta, -MAX_SPEED,  0)
	else:
		if(_velocity > 0):
			_velocity = clamp( _velocity - _deccel * delta, 0, MAX_SPEED)
		elif(_velocity < 0):
			_velocity = clamp( _velocity + _deccel * delta, -MAX_SPEED, 0)
	


