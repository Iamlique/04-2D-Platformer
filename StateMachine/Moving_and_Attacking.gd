extends Node

onready var SM = get_parent()
onready var player = get_node("../..")

onready var prev_direction = player.direction

var attackPoints = 3

func _ready():
	yield(player, "ready")

func _process(_delta):
	if player.is_on_floor() and player.is_moving():
		player.move_and_slide(player.velocity, Vector2.UP)
		
		if attackPoints == 3 and Input.is_action_just_pressed("attack"):
			$AttackReset1.start()
			player.set_animation("Move_Attack1")
			attackPoints -= 1
		elif attackPoints == 2 and Input.is_action_just_pressed("attack"):
			$AttackReset1.start()
			player.set_animation("Move_Attack2")
			attackPoints -= 1
		elif attackPoints == 1 and Input.is_action_just_pressed("attack"):
			$AttackReset1.start()
			player.set_animation("Move_Attack3")
			attackPoints -= 1

func physics_process(_delta):
	if not player.animating:
		var moving_slice = player.get_node("Attack/Moving_Attack1")
		if moving_slice.is_colliding():
			var enemy = moving_slice.get_collider()
			if enemy.has_method("damage"):
				enemy.damage(player.moving_slice)
		SM.set_state("Moving")

func _on_AttackReset1_timeout():
	attackPoints = 3
