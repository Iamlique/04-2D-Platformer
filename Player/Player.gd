extends KinematicBody2D

signal hp_max_changed(new_hp_max)
signal hp_changed(new_hp)
signal died

onready var SM = $StateMachine
onready var hurtbox = $Hurtbox
onready var Backup = get_node("/root/Game/Player_Container/Backup_Camera")
var enemy = load("res://Entity/Enitity_Base.gd").new()

var jump_power = Vector2.ZERO
var direction = 1

export var gravity = Vector2(0,30)

export var move_speed = 20
export var max_move = 200

export var jump_speed = 100
export var max_jump = 1000

export var leap_speed = 100
export var max_leap = 1000

var moving = false
var is_jumping = false
var animating = false

export var hp_max: int = 100 setget set_hp_max
export var hp: int = hp_max setget set_hp, get_hp
export(int) var defense: int = 0

export(bool) var receives_knockback: bool = true
export(float) var knockback_modifier: float = 0.1

export(int) var speed: int = 20
var velocity = Vector2.ZERO

export var slice = 20
export var slice1 = 25
export var slice2 = 30
export var moving_slice = 35
export var knockback = 7000
export var knockup = 1000

const INDICATOR_DAMAGE = preload("res://UI/DamageIndicator.tscn")
onready var healthbar = $Healthbar


func get_hp():
	return hp

func set_hp(value):
	if value != hp:
		hp = clamp(value, 0, hp_max)
		emit_signal("hp_changed", hp)
		if hp == 0:
			emit_signal("died")
		elif hp != hp_max:
			healthbar.show()

func set_hp_max(value):
	if value != hp_max:
		hp_max = max(0, value)
		emit_signal("hp_max_changed", hp_max)
		#healthbar.max_value = hp_max
		self.hp = hp

func _physics_process(_delta):
	velocity.x = clamp(velocity.x,-max_move,max_move)
	
	if Input.is_action_just_pressed("attack") and $Attack/Attack1.is_colliding():
		print("Player recognized Object")
		var collider = $Attack/Attack1.get_collider()
		print(collider)
		$Hitbox.monitorable = true
		print($Hitbox.monitorable)
	elif Input.is_action_just_pressed("attack") and $Attack/Moving_Attack1.is_colliding():
		print("Player recognized Object")
		var collider = $Attack/Moving_Attack1.get_collider()
		print(collider)
		$Hitbox.monitorable = true
		print($Hitbox.monitorable)
	else:
		$Hitbox.monitorable = false
		
	if direction < 0 and not $AnimatedSprite.flip_h: $AnimatedSprite.flip_h = true
	if direction > 0 and $AnimatedSprite.flip_h: $AnimatedSprite.flip_h = false
	Backup.position = position

func is_moving():
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		return true
	return false

func move_vector():
	return Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),1.0)

func _unhandled_input(event):
	if event.is_action_pressed("left"):
		direction = -1
	if event.is_action_pressed("right"):
		direction = 1

func set_animation(anim):
	animating = true
	if $AnimatedSprite.animation == anim: return
	if $AnimatedSprite.frames.has_animation(anim): $AnimatedSprite.play(anim)
	else: $AnimatedSprite.play()


func _on_AnimatedSprite_animation_finished():
	animating = false

func die():
	Backup.current = true
	queue_free()

func receive_damage(base_damage: int):
	var actual_damage = base_damage
	actual_damage -= defense
	
	self.hp -= actual_damage
	print(name + " received " + str(actual_damage) + " damage ")
	return actual_damage
	
func receive_knockback(damage_source_pos: Vector2, received_damage: int):
	if receives_knockback:
		var knockback_direction = damage_source_pos.direction_to(self.global_position)
		var knockback_strength = received_damage * knockback_modifier
		var knockback = knockback_direction * knockback_strength
		
		global_position = knockback

func _on_Hurtbox_area_entered(hitbox):
	#var actual_damage = receive_damage(hitbox.damage)
	#receive_knockback(self.global_position, actual_damage)
	receive_damage(hitbox.damage)
	spawn_dmgIndicator(hitbox.damage)

func _on_Player1_died():
	die()
	print("Player died")


func _on_Hitbox_area_entered(Hurtbox):
	pass

func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position):
	if EFFECT:
		var effect = EFFECT.instance()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position
		return effect
	
	
func spawn_dmgIndicator(damage: int):
	var indicator = spawn_effect(INDICATOR_DAMAGE)
	if indicator:
		indicator.label.text = str(damage)

