extends Node2D

# Variável para armazenar a cena do inimigo
var EnemyScene = preload("res://scenes/enemy.tscn")

# Limite de inimigos na cena
var max_enemies = 3
var current_enemies = 0

# Limites da área de spawn
var spawn_area_min = Vector2(50, 50)  # Ponto mínimo da área de spawn
var spawn_area_max = Vector2(351, 222)  # Ponto máximo da área de spawn

func _ready():
	# Configurar o Timer para o spawn de inimigos
	$SpawnTimer.start()

func _process(delta):
	change_scene()

func spawn_enemy(min_pos, max_pos):
	# Instancia a cena do inimigo
	var enemy_instance = EnemyScene.instantiate()
	
	# Gera uma posição aleatória dentro da área de spawn
	var random_position = Vector2(
		randf_range(min_pos.x, max_pos.x),
		randf_range(min_pos.y, max_pos.y)
	)
	
	# Define a posição do inimigo
	enemy_instance.position = random_position
	
	# Conecta o sinal para monitorar quando o inimigo for removido
	enemy_instance.connect("tree_exited", Callable(self, "_on_enemy_exited"))
	
	# Adiciona o inimigo como filho deste nó (World)
	add_child(enemy_instance)
	
	# Incrementa o contador de inimigos
	current_enemies += 1

	# Verifica se o número de inimigos atingiu o máximo
	if current_enemies >= max_enemies:
		$SpawnTimer.stop()
	else:
		$SpawnTimer.start()


func _on_enemy_exited():
	# Decrementa o contador de inimigos quando um inimigo for removido da cena
	current_enemies -= 1
	
	# Reinicia o Timer se o número de inimigos for menor que o máximo
	if current_enemies < max_enemies:
		$SpawnTimer.start()

func _on_cliff_side_transition_body_entered(body):
	if body.has_method("player"):
		global.transition_scene = true

func _on_cliff_side_transition_body_exited(body):
	if body.has_method("player"):
		global.transition_scene = false

func change_scene():
	if global.transition_scene:
		if global.current_scene == "world":
			get_tree().change_scene_to_file("res://scenes/cliff_side.tscn")
			global.finish_change_scene()

func _on_spawn_timer_timeout():
	if current_enemies < max_enemies:
		spawn_enemy(spawn_area_min, spawn_area_max)
