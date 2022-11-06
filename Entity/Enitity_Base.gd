extends KinematicBody2D

signal hp_max_changed(new_hp_max)
signal hp_changed(new_hp)
signal died

export(int) var hp_max: int = 100 setget set_hp_max
export(int) var hp: int = hp_max setget set_hp, get_hp
export(int) var defense: int = 0

export(int) var speed: int = 1000
var velocity = Vector2.ZERO

onready var animatedSprite = $AnimatedSprite
onready var collShape = $CollisionShape2D
onready var hurtbox = $Hurtbox
onready var healthbar = $Entity_Healthbar

export(bool) var receives_knockback: bool = true
export(float) var knockback_modifier: float = 0.1

const INDICATOR_DAMAGE = preload("res://UI/DamageIndicator.tscn")


func _physics_process(_delta):
	move()


func get_hp():
	return hp

func set_hp(value):
	if value != hp:
		hp = clamp(value, 0, hp_max)
		emit_signal("hp_changed", hp)
		healthbar.value = hp
		if hp == 0:
			emit_signal("died")
		elif hp != hp_max:
			healthbar.show()

func set_hp_max(value):
	if value != hp_max:
		hp = clamp(value, 0, hp_max)
		emit_signal("hp_max_changed", hp)
		#healthbar.max_value = hp_max
		self.hp = hp

#func _physics_process(_delta):
	#move()

func move():
	velocity = move_and_slide(velocity)
	
func die():
	queue_free()

func receive_damage(base_damage: int):
	var actual_damage = base_damage
	actual_damage -= defense
	
	self.hp -= actual_damage
	print(name + " received " + str(actual_damage) + " damage ")
	
	
func receive_knockback(damage_source_pos: Vector2, received_damage: int):
	if receives_knockback:
		var knockback_direction = damage_source_pos.direction_to(self.global_position)
		var knockback_strength = received_damage * knockback_modifier
		var knockback = knockback_direction * knockback_strength
		
		global_position = knockback

func _on_Hurtbox_area_entered(hitbox):
	receive_damage(hitbox.damage)
	spawn_dmgIndicator(hitbox.damage)
	


func _on_Enitity_Base_died():
	die()

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

