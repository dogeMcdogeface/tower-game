extends Node2D

@export var grid_cell_size: Vector2 = Vector2(GameDirector.block_size, GameDirector.block_size)
@export var grid_half_extents: Vector2 = Vector2(500, 500)  
@export var grid_color: Color = Color(0.5, 0.5, 0.5, 0.4)
@export var grid_thickness: float = 1.0

func _draw():
	var x_start = -grid_half_extents.x
	var x_end = grid_half_extents.x
	var y_start = -grid_half_extents.y
	var y_end = grid_half_extents.y

	# Vertical lines
	for x in range(ceil(x_start / grid_cell_size.x) * grid_cell_size.x, x_end + 1, grid_cell_size.x):
		draw_line(
			Vector2(x, y_start),
			Vector2(x, y_end),
			grid_color,
			grid_thickness
		)

	# Horizontal lines
	for y in range(ceil(y_start / grid_cell_size.y) * grid_cell_size.y, y_end + 1, grid_cell_size.y):
		draw_line(
			Vector2(x_start, y),
			Vector2(x_end, y),
			grid_color,
			grid_thickness
		)

	# Optional: draw origin cross
	draw_line(Vector2(-8, 0), Vector2(8, 0), Color.RED, 2)
	draw_line(Vector2(0, -8), Vector2(0, 8), Color.RED, 2)
