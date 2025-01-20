class_name NeuralNetwork

static var mutationRate = 0.5

var best: bool = false
var input_nodes: int
var hidden_nodes: int
var hidden_nodes_2: int
var output_nodes: int

var weights_input_hidden: Matrix
var weights_input_hidden_2: Matrix
var weights_hidden_output: Matrix

var bias_hidden: Matrix
var bias_hidden_2: Matrix
var bias_output: Matrix

var activation_function: Callable
var activation_function_2: Callable
var activation_function_3: Callable

func _init(_input_nodes: int, _hidden_nodes: int, _hidden_nodes_2: int, _output_nodes: int, is_set: bool = false) -> void:
	if !is_set:
		randomize()
		input_nodes = _input_nodes;
		hidden_nodes = _hidden_nodes;
		hidden_nodes_2 = _hidden_nodes_2;
		output_nodes = _output_nodes;

		weights_input_hidden = Matrix.rand(Matrix.new(hidden_nodes, input_nodes))
		weights_input_hidden_2 = Matrix.rand(Matrix.new(hidden_nodes_2, hidden_nodes))
		weights_hidden_output = Matrix.rand(Matrix.new(output_nodes, hidden_nodes_2))

		bias_hidden = Matrix.rand(Matrix.new(hidden_nodes, 1))
		bias_hidden_2 = Matrix.rand(Matrix.new(hidden_nodes_2, 1))
		bias_output = Matrix.rand(Matrix.new(output_nodes, 1))
	set_activation_function()

func set_activation_function(callback: Callable = Callable(Activation, "sigmoid"), callback2: Callable = Callable(Activation, "tanh_"), callback3: Callable = Callable(Activation, "tanh_")) -> void:
	activation_function = callback
	activation_function_2 = callback2
	activation_function_3 = callback3

func predict(input_array: Array[float]) -> Array:
	var inputs = Matrix.from_array(input_array)

	var hidden = Matrix.dot_product(weights_input_hidden, inputs)
	hidden = Matrix.add(hidden, bias_hidden)
	hidden = Matrix.map(hidden, activation_function)
	
	var hidden_2 = Matrix.dot_product(weights_input_hidden_2, hidden)
	hidden_2 = Matrix.add(hidden, bias_hidden)
	hidden_2 = Matrix.map(hidden, activation_function_2)

	var output = Matrix.dot_product(weights_hidden_output, hidden_2)
	output = Matrix.add(output, bias_output)
	output = Matrix.map(output, activation_function_3)

	return Matrix.to_array(output)

static func reproduce(a: NeuralNetwork, b: NeuralNetwork) -> NeuralNetwork:
	var result = NeuralNetwork.new(a.input_nodes, a.hidden_nodes, a.hidden_nodes_2, a.output_nodes)
	result.weights_input_hidden = Matrix.random(a.weights_input_hidden, b.weights_input_hidden)
	result.weights_input_hidden_2 = Matrix.random(a.weights_input_hidden_2, b.weights_input_hidden_2)
	result.weights_hidden_output = Matrix.random(a.weights_hidden_output, b.weights_hidden_output)
	result.bias_hidden = Matrix.random(a.bias_hidden, b.bias_hidden)
	result.bias_output = Matrix.random(a.bias_output, b.bias_output)

	return result

static func mutate(nn: NeuralNetwork, callback: Callable = Callable(NeuralNetwork, "mutate_callable_reproduced")) -> NeuralNetwork:
	var result = NeuralNetwork.new(nn.input_nodes, nn.hidden_nodes, nn.hidden_nodes_2, nn.output_nodes)
	result.weights_input_hidden = Matrix.map(nn.weights_input_hidden, callback, 1)
	result.weights_input_hidden_2 = Matrix.map(nn.weights_input_hidden_2, callback, 0.6)
	result.weights_hidden_output = Matrix.map(nn.weights_hidden_output, callback, 0.5)
	result.bias_hidden = Matrix.map(nn.bias_hidden, callback, 0)
	result.bias_output = Matrix.map(nn.bias_output, callback, 0)
	return result

static func mutate_callable_reproduced(value, _row, _col):
	seed(randi())
	randomize()
	value += randf_range(-mutationRate, mutationRate)
	return value

static func mutate_callable(value, _row, _col):
	seed(randi())
	randomize()
	value += randf_range(-0.5, 0.5)
	return value
