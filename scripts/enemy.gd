extends CharacterBody2D

var speed = 40
var player_chase = false
var player = null

var health = 100
var player_in_attack_zone = false
var can_take_damage = true
var is_dead = false  # Variável de controle para a morte

func _physics_process(delta):
	deal_with_damage()
	
	if not is_dead:  # Se o inimigo não está morto
		if player_chase:
			position += (player.position - position)/speed
			
			$AnimatedSprite2D.play("side_walk")
			if(player.position.x - position.x) < 0 :
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.play("front_idle")
	else:
		$AnimatedSprite2D.play("death")

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true


func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	
func enemy():
	pass

func _on_enemy_hit_box_body_entered(body):
	if body.has_method("player"):
		player_in_attack_zone = true


func _on_enemy_hit_box_body_exited(body):
	if body.has_method("player"):
		player_in_attack_zone = false
		
func deal_with_damage():
	if player_in_attack_zone and global.player_current_attack == true:
		if can_take_damage:
			$EnemyHitBox/HittedSound.play()
			$TakeDamageColdown.start()
			can_take_damage = false
			health -= 20
			$HealthBar.value = health
			if health <= 0 and not is_dead:
				is_dead = true  # Marca o inimigo como morto
				$DeathTimer.start()  # Inicia o timer de morte

func _on_take_damage_coldown_timeout():
	can_take_damage = true


func _on_death_timer_timeout():
	queue_free()
