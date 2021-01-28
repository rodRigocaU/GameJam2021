extends KinematicBody2D

const JUMP_FORCE = 750;
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			$Hook.this_shoot(position, event.position);
		else:
			$Hook.this_release();
			
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

	if Input.is_action_just_pressed("ui_up"):
		if grounded:
			velocity.y = -JUMP_FORCE;
		elif can_jump:
			can_jump = false;
			velocity.y = -JUMP_FORCE;

func _physics_process(_delta: float) -> void:
	var walk = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * MOVE_SPEED * _delta;
	velocity.y += GRAVITY;

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
	velocity += chain_velocity;

	move_and_slide(velocity + Vector2(walk, 0), Vector2.UP);

	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED);
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED);
	
	this_check_jumping(is_on_floor());
