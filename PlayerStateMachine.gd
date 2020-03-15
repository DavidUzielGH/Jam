extends "res://StateMachine.gd"

func _state_logic(delta):
	add_states()
	if state == states.Idle:
		parent.goIdle()
	if state == states.WalkingRight:
		parent.bruhIdle()
	
	
func add_states():
	add_state("Idle")
	add_state("Walking")
	add_state("Hooked")
	add_state("Dashing")
	add_state("Jumping")
	

func _get_transition(delta):
	pass
				
	
func _enter_state(new_state, old_state):
	pass

func _exit_state(old_state, new_state):
	pass
func _ready():
	pass # Replace with function body.