extends Panel

var alreadyStarted = false

func _ready():
	alreadyStarted = false
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if alreadyStarted == false and Input.is_action_just_pressed("ui_accept"):
		%Player.started = true
		self.hide()
		alreadyStarted = true
	pass
