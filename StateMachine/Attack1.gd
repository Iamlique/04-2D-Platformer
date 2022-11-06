extends Node

onready var SM = get_parent()
onready var player = get_node("../..")

var attackPoints = 3
var attack_cooldown_time = 30
var next_attack_time = 0
var attack_damage = 30

func _ready():
	yield(player, "ready")

func _process(_delta):
	if player.is_on_floor():
		if attackPoints == 3 and Input.is_action_just_pressed("attack"):
			#Check if player can attack
			var now = OS.get_ticks_msec()
			if now >= next_attack_time:
				$AttackReset.start()
				player.set_animation("Attack1")
				next_attack_time = now + attack_cooldown_time
			attackPoints -= 1
		elif attackPoints == 2 and Input.is_action_just_pressed("attack"):
			var now = OS.get_ticks_msec()
			if now >= next_attack_time:
				$AttackReset.start()
				player.set_animation("Attack2")
				next_attack_time = now + attack_cooldown_time
			attackPoints -= 1
		elif attackPoints == 1 and Input.is_action_just_pressed("attack"):
			var now = OS.get_ticks_msec()
			if now >= next_attack_time:
				$AttackReset.start()
				player.set_animation("Attack3")
				next_attack_time = now + attack_cooldown_time
			attackPoints -= 1

func physics_process(_delta):
	if not player.animating:
		SM.set_state("Idle")

func _on_AttackReset_timeout():
	attackPoints = 3


