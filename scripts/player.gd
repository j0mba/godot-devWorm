extends CharacterBody2D

var enemy_in_attack_range = false
var enemy_attack_coldown = true
var health = 100
var player_alive = true  # Variável de controle para a vida do jogador

const SPEED = 100.0
var current_dir = "down"
var attack_in_progress = false

func _ready():
	play_animation()

func _physics_process(delta):
	if player_alive:  # Verifica se o jogador está vivo antes de processar a lógica
		attack()
		handle_input()
		move_and_slide()
		enemy_attack()
		curent_camera()
		update_health()
	
	if health <= 0 and player_alive:
		player_alive = false
		$AnimatedSprite2D.play("death")
		$DeathTimer.start()

func handle_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	# Normaliza a velocidade para garantir que a velocidade seja constante
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
	
	update_direction()
	play_animation()

func update_direction():
	if velocity.x > 0:
		current_dir = "right"
	elif velocity.x < 0:
		current_dir = "left"
	elif velocity.y > 0:
		current_dir = "down"
	elif velocity.y < 0:
		current_dir = "up"

func play_animation():
	# Se um ataque está em progresso, mantenha a animação atual
	if attack_in_progress:
		return

	var anim = $AnimatedSprite2D
	match current_dir:
		"right":
			anim.flip_h = false
			if velocity.x != 0 or velocity.y != 0:
				anim.play("side_walk")
			else:
				anim.play("side_idle")
		"left":
			anim.flip_h = true
			if velocity.x != 0 or velocity.y != 0:
				anim.play("side_walk")
			else:
				anim.play("side_idle")
		"down":
			if velocity.y != 0 or velocity.x != 0:
				anim.play("front_walk")
			else:
				anim.play("front_idle")
		"up":
			if velocity.y != 0 or velocity.x != 0:
				anim.play("back_walk")
			else:
				anim.play("back_idle")

func player():
	pass

func _on_player_hit_box_body_entered(body):
	if body.has_method("enemy"):
		enemy_in_attack_range = true

func _on_player_hit_box_body_exited(body):
	if body.has_method("enemy"):
		enemy_in_attack_range = false
		
func enemy_attack():
	if enemy_in_attack_range and enemy_attack_coldown == true:
		health -= 20
		enemy_attack_coldown = false
		$EnemyAttackColdown.start()


func attack():
	# Verifique se o ataque está em progresso
	if attack_in_progress:
		return  # Evita iniciar outro ataque se um já estiver em progresso
	
	# Define a direção do ataque
	var dir = current_dir
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_in_progress = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
		elif dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
		elif dir == "down":
			$AnimatedSprite2D.play("front_attack")
		elif dir == "up":
			$AnimatedSprite2D.play("back_attack")
		
		$DealAttackTimer.start()

func _on_deal_attack_timer_timeout():
	$DealAttackTimer.stop()
	global.player_current_attack = false
	attack_in_progress = false
	
	# Após o ataque, continue a permitir o movimento
	play_animation()

func curent_camera():
	if global.current_scene == "world":
		$WorldCamera.enabled = true
		$CliffSideCamera.enabled = false
	elif global.current_scene =="cliff_side":
		$WorldCamera.enabled = false
		$CliffSideCamera.enabled = true

func update_health():
	var healthBar = $HealthBar
	healthBar.value = health
	if health >= 100:
		healthBar.visible = false
	else:
		healthBar.visible = true

func _on_regen_timer_timeout():
	if health < 100:
		health += 5
		if health > 100:
			health = 100
	if health <= 0:
		health = 0

func _on_death_timer_timeout():
	get_tree().reload_current_scene()


func _on_enemy_attack_coldown_timeout():
	enemy_attack_coldown = true

