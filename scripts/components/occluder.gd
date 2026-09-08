extends Area2D

@export var fade_time: float = 0.25

var target_node: CanvasItem
var current_player: Node2D
var fade_tween: Tween

func _ready() -> void:
    target_node = get_parent() as CanvasItem
    
    if target_node and target_node.has_node("Sprite2D"):
        target_node = target_node.get_node("Sprite2D")
        
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    set_process(true)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and target_node and target_node.material:
        current_player = body
        _animate_occlusion(1.0)

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player") and target_node and target_node.material:
        # Мы не стираем current_player сразу, чтобы дырка продолжала следить за ним, пока исчезает!
        _animate_occlusion(0.0)

func _animate_occlusion(target_val: float) -> void:
    if fade_tween and fade_tween.is_valid():
        fade_tween.kill()
    fade_tween = create_tween()
    
    var mat = target_node.material as ShaderMaterial
    var current_val = mat.get_shader_parameter("occlusion_amount")
    if current_val == null: current_val = 0.0
    
    fade_tween.tween_method(_set_occlusion, current_val, target_val, fade_time)
    
    if target_val == 0.0:
        # Только когда анимация исчезновения закончилась, отвязываем игрока
        fade_tween.tween_callback(func(): current_player = null)

func _set_occlusion(val: float) -> void:
    if target_node and target_node.material:
        target_node.material.set_shader_parameter("occlusion_amount", val)

func _process(delta: float) -> void:
    if current_player and target_node and target_node.material:
        target_node.material.set_shader_parameter("player_pos", current_player.global_position)
