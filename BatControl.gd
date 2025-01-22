extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const JUMP_DELAY = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var timeSinceLastAnimation = JUMP_DELAY
var timeSinceLastScore = 0

var dead = false
var started = false

var nn = null

var pointScore = 0
var scoreModifier = 0

var nextAction = "WAIT"

var nextTopWallPoint = null
var nextBottomWallPoint = null
var timeAlive = 0
var initialX = 0

func _physics_process(delta):
	var collider = $ForwardRay.get_collider()
	if collider and collider.name == "ScoreArea":
		var obstacle = collider.getParentObstacle()
		nextTopWallPoint = obstacle.getTopWallBottomLeftPoint() - $TopRay.global_position
		nextBottomWallPoint = obstacle.getBottomWallTopLeftPoint() - $BottomRay.global_position
		$TopRay.set_point_position(1, nextTopWallPoint)
		$BottomRay.set_point_position(1, nextBottomWallPoint)
		# print(obstacle.name)
		queue_redraw()
	
	if self.started == false:
		return
	
	if self.dead == true:
		return
		
	timeAlive += delta
	
	# Add the gravity. 
	velocity.y += gravity * delta
	timeSinceLastAnimation += delta
	
	if timeSinceLastAnimation < JUMP_DELAY:
		velocity.x = SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2 )
	
	# Handle jump.
	if nextAction == "JUMP" and timeSinceLastAnimation > JUMP_DELAY:
		velocity.y = JUMP_VELOCITY 
		$AnimationPlayer.flap()
		timeSinceLastAnimation = 0
		nextAction = "WAIT"

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var colliderName = collision.get_collider().name
		if colliderName == "Wall" or colliderName == "Ceiling" or colliderName == "Floor":
			dead = true
			hide()
			# print("Collided with something")

	timeSinceLastScore += delta
	if timeSinceLastScore > 5000:
		print("EXPIRED")
		#scoreModifier = -1000
		#dead = true
		#hide()
	updateScore()
	pass

func reset():
	show()
	pointScore = 0
	scoreModifier = 0
	$Score.text = str(0)
	global_position.y = 350
	global_position.x = 500
	initialX = global_position.x
	dead = false
	started = false

func evaluate():
	if nn == null:
		return
	
	var prediction = nn.predict(getArrayData())
	if prediction[0] >= prediction[1]:
		nextAction = "JUMP"
	else:
		nextAction = "WAIT"

func getData():
	return {
		"score": getScore(),
		"timeSinceLastJump": timeSinceLastAnimation, 
		"globalPosition": {"x": global_position.x, "y": global_position.y},  
		"nextWall": { 
			"top": {"x": nextTopWallPoint.x, "y": nextTopWallPoint.y},
			"bottom": {"x": nextBottomWallPoint.x, "y": nextBottomWallPoint.y}
		}
	}

func getArrayData() -> Array[float]:
	var ntX = -1
	var ntY = -1
	var nbX = -1
	var nbY = -1
	if nextBottomWallPoint:
		nbX = nextBottomWallPoint.x
		nbY = nextBottomWallPoint.y
	
	if nextTopWallPoint:
		ntX = nextTopWallPoint.x
		ntY = nextTopWallPoint.y
		
	return [
		float(global_position.y - (ntY - nbY) / 2),
		float(global_position.x - ntX), 
		float(global_position.y - ntY), 
		float(global_position.x - nbX), 
		float(global_position.y - nbY),
		float(timeSinceLastAnimation / JUMP_DELAY)
	]

func getScore():
	return pointScore + global_position.x - initialX + scoreModifier

func updateScore():
	$Score.text = str(round(getScore()))

func incrementPointScore():
	pointScore += 1
	timeSinceLastScore = 0
	updateScore()
