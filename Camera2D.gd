extends Camera2D

var TargetNode : Node2D = null
const SPEED = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setTargetNode(targetNode: Node2D):
	TargetNode = targetNode

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if TargetNode == null:
		return

	var targetPos = TargetNode.global_position.x
	var currentPos = global_position.x
	var centerPos = get_screen_center_position()

	self.global_position.x = targetPos
	pass
