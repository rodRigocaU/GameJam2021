extends KinematicBody2D

class_name Character

const JUMP_FORCE = 800;
const MOVE_SPEED = 20000;
const GRAVITY = 60;
const MAX_SPEED = 1000;
const FRICTION_AIR = 0.95;
const FRICTION_GROUND = 0.85;
const CHAIN_PULL = 50;

var velocity : Vector2;
var chain_velocity : Vector2;
var can_jump : bool;

func _ready():
	velocity = Vector2(0,0);
	chain_velocity = Vector2(0,0);
	can_jump = false;
	$MainCharCamera.current = true;
	PlayerStats.player = self;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left_click"):
		$Hook.this_shoot(event.position - get_viewport().size * 0.5);
	elif event.is_action_released("mouse_left_click"):
		$Hook.this_release();
	
func this_check_hook_status(walk : float) -> void:
	if $Hook.is_sticked:
		chain_velocity = to_local($Hook.hook_head_pos).normalized() * CHAIN_PULL;
		if chain_velocity.y > 0:
			chain_velocity.y *= 0.55;
		else:
			chain_velocity.y *= 1.65;
		if sign(chain_velocity.x) != sign(walk):
			chain_velocity.x *= 0.7;
	else:
		chain_velocity = Vector2(0,0);
			
func this_check_jumping(grounded : bool) -> void:
	if grounded:
		velocity.x *= FRICTION_GROUND;
		can_jump = true;
		if velocity.y >= 5:
			velocity.y = 5;
	elif is_on_ceiling() and velocity.y <= -5:
		velocity.y = -5;

	if !grounded:
		velocity.x *= FRICTION_AIR;
		if velocity.y > 0:
			velocity.y *= FRICTION_AIR;

	if Input.is_action_just_pressed("ui_key_w"):
		if grounded:
			velocity.y = -JUMP_FORCE;
		elif can_jump:
			can_jump = false;
			velocity.y = -JUMP_FORCE;

func _process(_delta : float) -> void:
	pass;
	#$MainCharCamera.position = position;

func _physics_process(_delta : float) -> void:
	var walk = (Input.get_action_strength("ui_key_d") - Input.get_action_strength("ui_key_a")) * MOVE_SPEED * _delta;
	velocity.y += GRAVITY;

	this_check_hook_status(walk);
	velocity += chain_velocity;

	move_and_slide(velocity + Vector2(walk, 0), Vector2.UP);

	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED);
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED);
	
	this_check_jumping(is_on_floor());
	
	PlayerStats.this_hability_handler(_delta);
