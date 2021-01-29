extends Node2D

class_name Hook

onready var chain_tex = $ChainTexture;
var direction := Vector2(0,0);
var hook_head_pos := Vector2(0,0);

const SPEED = 20;
const MAX_CHAIN_LENGTH = 1600;

var flying = false;
var is_sticked = false;

func this_shoot(end : Vector2) -> void:
	direction = end.normalized();
	hook_head_pos = self.global_position;
	flying = true;

func this_release() -> void:
	flying = false;
	is_sticked = false;

func _process(_delta: float) -> void:
	self.visible = flying or is_sticked;
	if self.visible:
		var hh_loc = to_local(hook_head_pos);
		var current_chain_length = hh_loc.length() * 4;
		chain_tex.rotation = self.position.angle_to_point(hh_loc) - deg2rad(90);
		$HookHead.rotation = chain_tex.rotation;
		chain_tex.position = hh_loc;
		if current_chain_length > MAX_CHAIN_LENGTH:
			this_release();
			return;
		chain_tex.region_rect.size.y = current_chain_length;
			

func _physics_process(_delta: float) -> void:
	$HookHead.global_position = hook_head_pos;
	if flying:
		if $HookHead.move_and_collide(direction * SPEED):
			is_sticked = true;
			flying = false;
	hook_head_pos = $HookHead.global_position;
