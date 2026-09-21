extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Stores initial spawn position
var spawn_position: Vector2

func _ready():
	# Save starting position when the scene loads
	spawn_position = global_position
	
	# Force add this object to the player group
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Animation selection based on horizontal movement
	if (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "default"
	
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction and handle movement/deceleration
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Execute movement
	move_and_slide()
	
	# --- DEBUGGED COLLISION CHECK ---
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider != self:
			var collider_name = collider.name.to_lower()
			
			# Check specifically for spikes or villains/enemies
			var is_hazard = collider_name.contains("spikes") or collider_name.contains("villain") or collider_name.contains("enemy")
			
			# Check if we hit the floor or a wall (TileMapLayer / StaticBody2D environment)
			var is_environment = collider is TileMapLayer or collider is TileMap or collider_name.contains("floor") or collider_name.contains("wall")
			
			# If it's explicitly a hazard, OR not environmental terrain, trigger respawn
			if is_hazard or not is_environment:
				print("Valid obstacle detected (", collider.name, ")! Triggering respawn...")
				respawn()

	# Flip the sprite based on movement direction
	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x < 0

# Resets player position back to starting point
func respawn():
	print("Respawning player!")
	velocity = Vector2.ZERO
	
	# Safely teleport the player outside the physics processing frame step
	call_deferred("set_global_position", spawn_position)
	
	# Forces Godot to update the rendering engine immediately so the character doesn't stretch or lag
	if has_method("reset_physics_interpolation"):
		call_deferred("reset_physics_interpolation")
