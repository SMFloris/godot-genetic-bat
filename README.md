# Genetically trained Neural Network in Godot

Made a game that can play itself using a neural network.

In this project, we spawn multiple generation of bats controlled by a simple neural network. Each generation the weights of the neural network get tweaked by the genetic algorithm.
Stronger spawns carry their "genes" (weights) more than weaker spawns.

Huge inspiration for the NN code came from [davisbrandon02/simple-neural-network](https://github.com/davisbrandon02/simple-neural-network), which I've tweaked and re-imagined so they work better for the genetic inputs.

![Screenshot](./resources/imgs/screenshot.png?raw=true "Screenshot")

## Features

- A generation's individuals can run at the same time
- Can increase timestep in order to speed-up training
- Most of the genetic algorithm is implemented:
    + crossover  
    + mutation  
    + elitism  

## Motivation

Wanted to play with genetic algorithms for a long time. Finally got a chance to do it and also explore Godot a bit.
