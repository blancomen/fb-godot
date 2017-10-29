extends Node2D

var TracksMatrix = [];
var Percents = []
var label
var tracer

var font = load("res:///font.fnt")
func _ready():
	tracer = get_parent().get_node("draw_area")
	label = get_parent().get_node("Label1")
	pass
	
func _draw():
	print("DRAW")
	
	var i = 0
	var maxPercent = 0
	for p in Percents:
		if p > maxPercent:
			maxPercent = p
	
	for matrix in TracksMatrix:
		# DRAW MATRIX
		if matrix.size() > 0:
			var cell_size = 5
			var matrix_pos = Vector2()
			matrix_pos.x = i * cell_size * matrix.size() + i *10
			var mat_max = tracer.matrix_max_value(matrix)
			
			if Percents.size() >= i + 1:
				var text_pos = matrix_pos + Vector2(0, cell_size * matrix.size() + 15)
				draw_string(font, text_pos,String(Percents[i])+"%")
			
			for row in range(matrix.size()):
				for column in range(matrix[row].size()):
					var val = float(matrix[row][column]) / float(mat_max)
					var color = Color(float(val), 0, 0)
					if Percents.size() >= i + 1:
						if Percents[i] == maxPercent:
							color = Color(0, float(val), 0)
							
					draw_rect(
						Rect2(
							matrix_pos.x + column * cell_size,
							matrix_pos.y + row * cell_size, 
							cell_size,
							cell_size
						), 
						color
					)
					
		i+=1

func predict(matrix):
	Percents = []
	for i in range(TracksMatrix.size()):
		Percents.append(
		round(tracer.percent_include_matrix(matrix, TracksMatrix[i]) * 100)
	)
	update()
	print(Percents)

func addTrackMatrix(matrix):
	TracksMatrix.append(matrix)
	update()