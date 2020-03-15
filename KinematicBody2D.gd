extends KinematicBody2D

const GRAVITY = 850.0
const MAX_SPEED = 300
const JUMP_HEIGHT = 350
const ACCELERATION = 30
const WEIGHT = 5

enum MOVING {Idle = 0, Right = 1, Left = -1, Jumping = 2} #Utilizadas para cosas de movimiento
enum ANIMATE {Idle_right, Idle_left, Turning_left, Turning_right, Walking_right, Walking_left} #Utilizadas para el thread de animacion

var idle_direction = MOVING.Right
var going_idle = true

var velocity = Vector2()

var tpDistance = 30

var anim_thread = Thread.new()
var speed_thread = Thread.new()
var anim_state

func _ready():
	anim_state = ANIMATE.Idle_right
	speed_thread.start(self, "speed_based_animation_state_setter_thread", null)

func is_going_idle():
	return going_idle

func is_walking():
	return not going_idle

func is_airborne():
	if self.is_on_floor():
		return true
	else:
		return false
		
func _physics_process(delta):
	if !self.is_on_floor():
		velocity.y += delta * GRAVITY 
		#Se calcula el descenso por gravedad tomando en 
		#cuenta el tiempo entre frames
	if Input.is_action_pressed("Left"):
		going_idle = false
		velocity.x -= 1 
		#Este decremento de velocidad 
		#es para evitar que el metodo se cicle
		_take_input_and_move_in_x(MOVING.Left)
	elif Input.is_action_pressed("Right"):
		velocity.x += 1
		going_idle = false
		_take_input_and_move_in_x(MOVING.Right)
	else:
		going_idle = true
		_deaccelerate_until_idle()
	
	if Input.is_action_pressed("Jump") and self.is_on_floor(): 
		going_idle = false
		velocity.y = -JUMP_HEIGHT
		
	if Input.is_action_pressed("tp"):
		teleport()
		
	move_and_slide(velocity, Vector2(0, -1))	

func _take_input_and_move_in_x(speed_sign): #Recibe una constante que indica 
	#si la velocidad va a aumentar o reducir (1, -1)
	going_idle = false
	if velocity.x < MAX_SPEED and velocity.x > -MAX_SPEED:
		velocity.x += ACCELERATION * speed_sign #Se multiplica la aceleración 
		#por la constante para hacerla negativa o positiva
	else:
		velocity.x = MAX_SPEED * speed_sign #Lo mismo aqui

func teleport():
	if anim_state == ANIMATE.Idle_left:
		self.position.x += +30
	elif anim_state == ANIMATE.Idle_right:
		self.position.x += -30

func _deaccelerate_until_idle():
	if get_sign_from(velocity.x) == -1:
		idle_direction = MOVING.Left
	else:
		idle_direction = MOVING.Right
		
	if velocity.x != MOVING.Idle:
		if idle_direction == MOVING.Right:
			velocity.x -= ACCELERATION
			if velocity.x < 0:
				velocity.x = 0
		if idle_direction == MOVING.Left:
			velocity.x += ACCELERATION
			if velocity.x > 0:
				velocity.x = 0

func get_sign_from(number):
	if number > 0:
		return 1
	elif number < 0:
		return -1
		
func speed_based_animation_state_setter_thread(userdata):
	var curr_speed = velocity.x
	var past_speed = curr_speed
	while true:
		curr_speed = velocity.x
		if velocity.x > 0:
			if curr_speed < past_speed:
				anim_state = ANIMATE.Turning_left
			else:
				anim_state = ANIMATE.Walking_right	
		elif velocity.x < 0:
			if curr_speed > past_speed:
				anim_state = ANIMATE.Turning_right
			else:
				anim_state = ANIMATE.Walking_left	
		elif going_idle == true:
			if past_speed < 0:
				anim_state = ANIMATE.Idle_left
			else:
				anim_state = ANIMATE.Idle_right
		past_speed = curr_speed
		if past_speed < -MAX_SPEED or past_speed > MAX_SPEED: #NO RECUERDO QUE HACE ESTO, PERO NO TOCAR
			past_speed = MAX_SPEED * get_sign_from(past_speed)
