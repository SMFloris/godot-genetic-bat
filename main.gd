extends Node2D

var _stream = null

const SEED = 1337
const NO_OBSTACLES = 100
const MINIMUM_SPACING = 250
const START_X = 100

const MAX_GENERATIONS = 1000
const CROSSOVER_RATE = 0.3
const POPULATION_SIZE = 100
const ELITES = 10

var currentGeneration = 0
var currentPlayers = []
var playersAlive = 0
var maxScore = 0
var started = false

const NeuralNetwork = preload("res://NeuralNetwork/Neural_Network.gd")

func ga_resetPop():
	for p in currentPlayers:
		p.queue_free()
	currentPlayers = []

func ga_spawn(index, nn = null):
	var player = %Player.duplicate()
	player.name = "Player"+str(index)
	if nn:
		player.nn = nn
	else:
		player.nn = NeuralNetwork.new(6, 6, 6, 2)
	self.add_child(player)
	player.reset()
	return player

func ga_initPop(popNo):
	for popCount in range(0, popNo):
		var player = ga_spawn(popCount)
		currentPlayers.append(player)
		player.started = true
	
	for i in range(0, len(currentPlayers)):
		for j in range(0, len(currentPlayers)):
			if i > j:
				continue
			currentPlayers[i].add_collision_exception_with(currentPlayers[j])

func ga_evaluate():
	for currentPlayer in currentPlayers:
		currentPlayer.evaluate()
		if currentPlayer.getScore() > maxScore:
			maxScore = currentPlayer.getScore()
	pass

func ga_shouldAdvanceGeneration():
	var allPlayersDead = true
	var furthestPlayer = currentPlayers[0]
	for currentPlayer in currentPlayers:
		if currentPlayer.global_position.x > furthestPlayer.global_position.x:
			furthestPlayer = currentPlayer
		if currentPlayer.dead == false:
			allPlayersDead = false
	%Camera.setTargetNode(furthestPlayer)
	return allPlayersDead

func ga_shouldStop():
	if currentGeneration > MAX_GENERATIONS:
		return true
	return false

func ga_selectParent():
	var index = randi_range(0, ELITES);
	return currentPlayers[index]

func ga_selectParent_roulette(players):
	var populationFitness = 0
	for currentPlayer in players:
		populationFitness += currentPlayer.getScore()
	
	randomize()
	var rouletteWheelPosition = randf() * populationFitness
	
	var spinwheel = 0
	for currentPlayer in players:
		spinwheel += currentPlayer.getScore()
		if spinwheel >= rouletteWheelPosition:
			return currentPlayer
	
	return players[0]

func sort_by_score(pA, pB):
	return pA.getScore() >= pB.getScore()

func ga_sortedByScore():
	var sorted = currentPlayers
	sorted.sort_custom(Callable(self, "sort_by_score"))
	return sorted

func ga_crossover():
	var newGeneration = []
	var sortedPlayers = ga_sortedByScore()
	var selectedElites = 0
	var eliteBreeded = 0
	for i in range(0, len(currentPlayers)):
		if selectedElites < ELITES / 2:
			print(str(i) + " Elite Spawn " + str(sortedPlayers[selectedElites].getScore()))
			var offspring = ga_spawn(i, sortedPlayers[selectedElites].nn)
			newGeneration.push_back(offspring)
			selectedElites += 1
			continue
			
		if eliteBreeded < ELITES:
			var parentA = sortedPlayers[i]
			var parentB = sortedPlayers[i+1]
			print(str(i) + " ELITE CROSS " + str(parentA.getScore()))
			var offspring = ga_spawn(i, NeuralNetwork.reproduce(parentA.nn, parentB.nn))
			newGeneration.push_back(offspring)
			eliteBreeded += 1
			continue

		randomize()
		if CROSSOVER_RATE > randf():
			print(str(i) + " CROSS!")
			var parentA = ga_selectParent_roulette(sortedPlayers)
			var parentB = ga_selectParent_roulette(sortedPlayers)
			var offspring = ga_spawn(i, NeuralNetwork.reproduce(parentA.nn, parentB.nn))
			newGeneration.push_back(offspring)
		else:
			print(str(i) + " RANDOM PARENT!")
			var randomParent = ga_selectParent_roulette(sortedPlayers)
			var newParent = ga_spawn(i, randomParent.nn)
			newGeneration.push_back(newParent)

	ga_resetPop()
	currentPlayers = newGeneration
	for i in range(0, len(currentPlayers)):
		for j in range(0, len(currentPlayers)):
			if i > j:
				continue
			currentPlayers[i].add_collision_exception_with(currentPlayers[j])

func ga_mutation():
	var selectedElites = 0
	for currentPlayer in currentPlayers:
		# skip best elites of last generation from mutation
		#if selectedElites < ELITES / 10:
			#selectedElites += 1
			#continue
		currentPlayer.nn = NeuralNetwork.mutate(currentPlayer.nn)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	seed(SEED)
	
	var nextX = START_X
	var obstacleCount = 0

	while(obstacleCount < NO_OBSTACLES):
		var lastObstacle = %Obstacle.duplicate() 
		lastObstacle.name = "Obstacle"+str(obstacleCount )
		lastObstacle.setUp(randi_range(1,3), nextX, randf_range(-1,1));
		nextX += randi_range(MINIMUM_SPACING, MINIMUM_SPACING+300)
		self.add_child(lastObstacle)
		obstacleCount += 1

	ga_initPop(POPULATION_SIZE)
	ga_evaluate()
	started = true

func _process(delta):
	if started == false:
		return

	if ga_shouldStop():
		print("DONE")
		return
	
	if ga_shouldAdvanceGeneration():
		print("ALL DEAD")
		
		var populationFitness = 0
		for currentPlayer in currentPlayers:
			populationFitness += currentPlayer.getScore()
		if currentGeneration == 0 and populationFitness < 5:
			print("NO ONE REACHED THE WALL. KILLING THEM.")
			ga_initPop(POPULATION_SIZE)
			ga_evaluate()

		ga_crossover()
		ga_mutation()
		currentGeneration += 1
		for currentPlayer in currentPlayers:
			currentPlayer.started = true
	
	if Input.is_action_just_pressed("ui_down"):
		modifyTimeScale(-1)
	
	if Input.is_action_just_pressed("ui_up"):
		modifyTimeScale(1)

	%GenLabel.text = str(currentGeneration) + "\t (MaxScore: " + str(maxScore) + ")"
	ga_evaluate()

func modifyTimeScale(rate: int):
	var nextScale = Engine.time_scale + rate
	if nextScale <= 1:
		nextScale = 1
	Engine.time_scale = nextScale
	%TimeScale.text = "x"+str(Engine.time_scale)

func _on_player_scored(body):
	for player in currentPlayers:
		if player.name == body.name:
			player.incrementPointScore()
	pass # Replace with function body.
