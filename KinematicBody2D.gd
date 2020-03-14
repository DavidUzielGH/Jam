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

var anim_thread = Thread.new()
var speed_thread = Thread.new()
var animation_player
var anim_state

func _ready():
	anim_state = ANIMATE.Idle_right
	animation_player = get_node('AnimationPlayer') 
	anim_thread.start(self, "_animation_state_setter_thread", null)
	speed_thread.start(self, "_speed_based_animation_state_setter_thread", null)

func _physics_process(delta): #Calculo de movimiento
	if self.is_on_floor(): 
		if Input.is_action_pressed("Jump"): 
			going_idle = false
			velocity.y = -JUMP_HEIGHT
	else:
		velocity.y += delta * GRAVITY #Se calcula el descenso por gravedad tomando en cuenta el tiempo entre frames
	if Input.is_action_pressed("Left"):
		velocity.x -= 5 #Este decremento de velocidad es para evitar que el metodo se cicle
		_take_input_and_move_in_x(MOVING.Left)
	elif Input.is_action_pressed("Right"):
		velocity.x += 5
		_take_input_and_move_in_x(MOVING.Right)
	else:
		going_idle = true
		_deaccelerate_until_idle()
	move_and_slide(velocity, Vector2(0, -1))
	
	

func _take_input_and_move_in_x(speed_sign): #Recibe una constante que indica si la velocidad va a aumentar o reducir (1, -1)
	going_idle = false;
	if velocity.x < MAX_SPEED and velocity.x > -MAX_SPEED:
		velocity.x += ACCELERATION * speed_sign #Se multiplica la aceleración por la constante para hacerla negativa o positiva
	else:
		velocity.x = MAX_SPEED * speed_sign #Lo mismo aqui

func _deaccelerate_until_idle():
	if _get_sign_from(velocity.x) == -1:
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

func _get_sign_from(number):
	if number > 0:
		return 1
	elif number < 0:
		return -1
		
func _animation_state_setter_thread(userdata):	
	while true:
		match anim_state:
			ANIMATE.Idle_right:
				animation_player.play('Idle')
			ANIMATE.Idle_left:
				animation_player.play('Idle')
			ANIMATE.Walking_right:
				animation_player.play('Right')
			ANIMATE.Walking_left:
				animation_player.play('Left')
			ANIMATE.Turning_left:
				animation_player.play('Turning_left')
			ANIMATE.Turning_right:
				animation_player.play('Turning_right')
			_:
				print('Not possible')
		
func _speed_based_animation_state_setter_thread(userdata):
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
		if past_speed < -MAX_SPEED or past_speed > MAX_SPEED:
			past_speed = MAX_SPEED * _get_sign_from(past_speed)
