extends AnimationPlayer
var state = null
var previous_state = null

var states = {}

onready var parent = get_parent()

func _ready():
	add_states()
	state = states.Idle
	print(state)

func _physics_process(delta):
	if state != null:
		state_logic(delta)
		var transition = get_transition(delta)
		if transition != null:
			set_state(transition)

func add_states():
	add_state("Idle")
	add_state("Walking")
	add_state("Jumping")
	add_state("Falling")

func state_logic(delta):
	print(state)
	print("bruh")
	self.play(state)

func get_transition(delta):
	match state:
		states.Idle:
			if parent.is_walking():
				return states.Walking
		states.Walking:
			if parent.is_going_idle():
				return states.Idle

func enter_state(new_state, old_state):
	pass

func exit_state(old_state, new_state):
	pass

func set_state(new_state):
	previous_state = state
	state = new_state
	if previous_state != null:
		exit_state(previous_state, new_state)
	if new_state != null:
		enter_state(new_state, previous_state)

func add_state(state_name):
		states[state_name] = state_name