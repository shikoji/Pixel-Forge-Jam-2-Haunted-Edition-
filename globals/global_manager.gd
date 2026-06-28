extends Node

#player
var player_speed = 5.0
const player_jump_vel = 2.5

const player_bob_feq = 2.0
const player_bob_amp = 0.06

#settings
var mouse_sense = 0.003
var volume = 100

#events
signal update_objective
var current_objective = 0

#objectives
var player_objectives = [
	
	"-escape your cell",
	"dsfdsdf",
	"asfdasdasd",
	"asdasd",
		
]
