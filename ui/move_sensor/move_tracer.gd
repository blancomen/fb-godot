extends Container

var mouseOn = false
var isTouched = false
var isTrack = false
var mouseTrackCoordinates = Vector2Array()
var mode = 0

var lastTrack = Vector2Array()

var matrix_size = Vector2(18, 18)
var fited_matrix = zeros_matrix(matrix_size.x, matrix_size.y)
var target_matrix = zeros_matrix(matrix_size.x, matrix_size.y)

var LearnedMatrix


func norm_matrix(matrix):
	var max_val = matrix_max_value(matrix)
	var norm_m = zeros_matrix(matrix_size.x, matrix_size.y)
	for row in range(matrix.size()):
		for column in range(matrix[row].size()):
			norm_m[row][column] = float(matrix[row][column])/float(max_val)

	return norm_m	

func percent_include_matrix(matrix_a, matrix_b):
	matrix_b = norm_matrix(matrix_b)
	
	var accept = 0.0
	var penalty = 0.0
	var accept_count = 0.0
	var penalty_count = 0.0
	for row in range(matrix_a.size()):
		for column in range(matrix_a[row].size()):
			if matrix_a[row][column] > 0:
				if matrix_b[row][column] > 0:	
					accept += float(matrix_b[row][column])
					accept_count += 1.0
				else:
					penalty += float(matrix_a[row][column])
					penalty_count += 1.0
					
	for row in range(matrix_b.size()):
		for column in range(matrix_b[row].size()):
			if matrix_b[row][column] > 0:
				if matrix_a[row][column] == 0:	
					penalty += float(matrix_b[row][column])
					penalty_count += 1.0
				
	print("accept: ", accept, " | accept_count: ", accept_count, " | penalty: ", penalty, " | penalty_count: ", penalty_count)
	return accept/penalty

func matrix_max_value(matrix):
	var maxVal = matrix[0][0]
	for row in matrix:
		for column in row:
			if maxVal < column:
				maxVal = column
	return maxVal

func zeros_matrix(w, h):
	var matrix = []
	for i in range(h):
		matrix.push_back([])
		for j in range(w):
			matrix[i].push_back(0)
	return matrix 
	
func fit_matrix(matrix, track):
	track = crop_box(track)
	var box = find_box(track)
	var maxPoint = Vector2(
		max(box["max"].x, box["max"].y), 
		max(box["max"].x, box["max"].y)
	)

	var step_done_matrix = zeros_matrix(matrix_size.x, matrix_size.y)
	var prev_coord = null
	for coord in track:
		#coord.x /= maxPoint.x
		#coord.y /= maxPoint.y
		
		if prev_coord == null:
			prev_coord = coord
			continue
	
		var step = 1
		var from = prev_coord
		var to = coord
		var distance = from.distance_to(to)
		var steps = floor(distance / step)
		
		var line_coord = prev_coord
		for s in range(steps):
			var i = ceil(line_coord.y / maxPoint.y * (matrix_size.y-1))
			var j = ceil(line_coord.x / maxPoint.x * (matrix_size.x-1))
			
			line_coord = line_coord.linear_interpolate(to, s/steps)
		
			if step_done_matrix[i][j] == 0:
				matrix[i][j] += 1
				step_done_matrix[i][j] = 1
			
			prev_coord = coord
			
	return matrix

func _ready():
	set_process_input(true)
	set_process(true)
	set_fixed_process(true)
	LearnedMatrix = get_parent().get_node("learned_tracks_matrix")
	pass

func _fixed_process(delta):
	if (isTouched):
		if !isTrack:
			mouseTrackCoordinates = Vector2Array()
			isTrack = true
			
		if isTrack:
			var mouse_pos = get_global_mouse_pos()
			if mouseTrackCoordinates.size() < 100:
				mouseTrackCoordinates.push_back(mouse_pos)
			
			lastTrack = mouseTrackCoordinates
			update()
	else:
		if isTrack:
			if mouseTrackCoordinates.size() > 0:
				mouseTrackCoordinates = Vector2Array()
				
				var coords = crop_box(lastTrack)
				var box = find_box(coords)
				if box["max"].x > 5 || box["max"].y > 5:
					if mode == 0:
						fited_matrix = fit_matrix(fited_matrix, lastTrack)
						target_matrix = []
					
					if mode == 1:
						target_matrix =  zeros_matrix(matrix_size.x, matrix_size.y)
						target_matrix = fit_matrix(target_matrix, lastTrack)
						#var percent = percent_include_matrix(target_matrix, fited_matrix)
						LearnedMatrix.predict(target_matrix)
						
						#get_parent().get_node("Label1").set_text(String(percent*100)+"%")
						#print(percent*100,"%")
					
					#updateMatrixText()
					
				update()
				
		isTrack = false	

func approximate_points(from, to):
	pass

func _draw():
	if lastTrack == null:
		return 
		
	var track = normalize_coordinates(lastTrack)
	#track = approximate_by_grid(track)
	#track = move_to_center(track)
	track = moving_average(track, 2)
	
	var pos = get_parent().get_node("track").get_pos()
	var box = find_box(track)
	var maxCoord = Vector2(
		max(box["max"].x, box["max"].y), 
		max(box["max"].x, box["max"].y)
	)
	var scale = Vector2(400, 400) * maxCoord
	var step = 0.5
	var prevCoord = null
	for coordinate in track:
		if prevCoord != null:
			var from = prevCoord * scale
			var to = coordinate * scale
			var distance = from.distance_to(to)
			var steps = floor(distance / step)
			var line_coord = prevCoord * scale
			#for s in range(steps):
			#	draw_rect(Rect2(pos + line_coord, Vector2(1, 1)), Color(255, 255, 255))
			#	line_coord = line_coord.linear_interpolate(to, s/steps)
			draw_line(
				pos + prevCoord * scale, 
				pos + coordinate * scale, 
				Color(255, 255, 255),2
			)
			#draw_circle(
			#	pos + prevCoord * scale,3, 
			#	Color(255, 255, 0)
			#)	
		prevCoord = coordinate
	
	if isTrack:
		var track = lastTrack
		track = moving_average(track, 3)
		draw_track(track, Color(255, 255, 255),2)
	
	# DRAW MATRIX
	if fited_matrix.size() > 0 && !isTrack:
		var cell_size = 32*6/fited_matrix.size()
		var matrix_node = get_parent().get_node("tracks_matrix")
		var matrix_pos = matrix_node.get_pos() - Vector2(32*3, 32*3)
		var mat_max = matrix_max_value(fited_matrix)
		
		for row in range(fited_matrix.size()):
			for column in range(fited_matrix[row].size()):
				var val = float(fited_matrix[row][column]) / float(mat_max)
				if val > 0:
					draw_rect(
						Rect2(
							matrix_pos.x + column * cell_size,
							matrix_pos.y + row * cell_size, 
							cell_size,
							cell_size
						), 
						Color(float(val), 0, 0)
					)
					
	# DRAW MATRIX
	if target_matrix.size() > 0 && !isTrack:
		var cell_size = 32.0*6.0/float(target_matrix.size())
		var matrix_node = get_parent().get_node("tracks_matrix")
		var matrix_pos = matrix_node.get_pos() - Vector2(32*3, 32*3)
		var mat_max = matrix_max_value(target_matrix)
		
		for row in range(target_matrix.size()):
			for column in range(target_matrix[row].size()):
				var val = float(target_matrix[row][column]) / float(mat_max)
				if val > 0:
					draw_rect(
						Rect2(
							matrix_pos.x + column * cell_size,
							matrix_pos.y + row * cell_size, 
							cell_size,
							cell_size
						), 
						Color(0, float(val), 0)
					)	
			
			
func draw_track(track, color, width):	
	var prevCoord = null
	for coordinate in track:
		if prevCoord != null:
			draw_line(prevCoord, coordinate, color, width
			)		
		prevCoord = coordinate

func _input(event):
	if (event.type == InputEvent.SCREEN_TOUCH):
		if (event.pressed):
			isTouched = true
		else:
			isTouched = false
			

func _on_draw_area_mouse_enter():
	mouseOn = true
	pass


func _on_draw_area_mouse_exit():
	mouseOn = false
	pass

func approximate_by_grid(coords):
	var grid_size = 0.05
	var approximated = Vector2Array()
	for coord in coords:
		coord.x = floor(coord.x / grid_size) * grid_size + grid_size / 2
		coord.y = floor(coord.y / grid_size) * grid_size + grid_size / 2
		approximated.push_back(coord)

	return approximated

func normalize_coordinates(coords):
	coords = crop_box(coords)
	var box = find_box(coords)
	var maxPoint = Vector2(
		max(box["max"].x, box["max"].y), 
		max(box["max"].x, box["max"].y)
	)
	
	var centerCoords = Vector2Array()
	for coord in coords:
		coord.x -= box["max"].x/2
		coord.y -= box["max"].y/2
		centerCoords.push_back(coord)
	
	var normCoords = Vector2Array()
	for coord in centerCoords:
		coord.x /= maxPoint.x
		coord.y /= maxPoint.y
		normCoords.push_back(coord)
	
	return normCoords

func moving_average(coords, window):	
	var movavg_coords = Vector2Array()
	for i in range(coords.size()):
		if i >= window:
			var sum = Vector2()
			for j in range(window):
				sum += coords[i-j]
			movavg_coords.push_back(sum/window)
			
	return movavg_coords
	
# Обрезает координаты по боксу
func crop_box(coords):
	# Crop
	var box = find_box(coords)
	var cropedCoords = Vector2Array()
	var minPoint = Vector2(box["min"].x, box["min"].y)
	
	for coord in coords:
		cropedCoords.push_back(coord - minPoint)
	
	return cropedCoords
	
	
func find_box(coords):
	var box = {
		"min": Vector2(999999999, 999999999),
		"max": Vector2(-999999999, -999999999),
	}
	
	for coord in coords:
		box["min"].x = min(box["min"].x, coord.x)
		box["min"].y = min(box["min"].y, coord.y)
		box["max"].x = max(box["max"].x, coord.x)
		box["max"].y = max(box["max"].y, coord.y)
		
	return box


func _on_TouchScreenButton_released():
	fited_matrix = zeros_matrix(matrix_size.x, matrix_size.y)

func _on_TouchScreenButton1_pressed():
	if mode == 0:
		mode = 1
	elif mode == 1:
		mode = 0
		
	get_parent().get_node("Label").set_text("Mode: " + String(mode))
	

func _on_TouchScreenButton2_pressed():
	var m = matrix_max_value(fited_matrix)
	if m > 0:
		LearnedMatrix.addTrackMatrix(fited_matrix)
		fited_matrix = zeros_matrix(matrix_size.x, matrix_size.y)
		update()
