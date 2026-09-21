extends CharacterBody2D

@export var move_distance: float = 50.0  # Distance to patrol from starting position
@export var speed: float = 70.0          # Patrol movement speed

var start_x: float
var direction: int = 1  # 1 = moving right, -1 = moving left

func _ready():
	start_x = position.x

func _physics_process(_delta):
	# Apply lateral movement
	velocity.x = direction * speed
	move_and_slide()
	
	# Reverse direction when reaching max patrol distance
	if abs(position.x - start_x) >= move_distance:
		direction *= -1
		
		# Flip Sprite2D horizontally if it exists as a child node
		if has_node("Sprite2D"):
			$Sprite2D.flip_h = direction < 0
