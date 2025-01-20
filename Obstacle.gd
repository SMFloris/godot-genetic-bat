extends Node2D

# from 1-3 where 1 is hardest
var gapSize = 1

# from -1 to 0 where -1 is bottom, 0 is center, 1 is top
var offsetY = 0

const MOVE_STEP = 100
const GAP_STEP = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	# self.resetPosition()
	pass # Replace with function body.

func setUp(gapSize, offsetX, offsetY):
	self.gapSize = gapSize 
	self.offsetY = offsetY
	self.global_position.x = offsetX
	self.resetPosition()
	pass

func resetPosition():
	self.position.y += MOVE_STEP * offsetY
	get_node("top").position.y -= GAP_STEP * gapSize     
	get_node("bottom").position.y += GAP_STEP * gapSize
	
func getTopWallBottomLeftPoint():
	var topWall = get_node("top/Wall/CollisionShape2D")
	var shape = topWall.get_shape().get_rect()
	return Vector2(topWall.global_position.x + shape.position.x, topWall.global_position.y + shape.position.y + shape.size.y)

func getBottomWallTopLeftPoint():
	var bottomWall = get_node("bottom/Wall/CollisionShape2D")
	var shape = bottomWall.get_shape().get_rect()
	return bottomWall.global_position - (shape.size / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global_position.x < -300:
		self.queue_free()
	pass
