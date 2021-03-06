extends Line2D

# APPEARANCE DETAILS:
# This script will draw two seprate segments of interconnected lines, as outlines.
# Between the two lines mentioned, a polygon is drawn, bridging the two lines.
# At each end of the two lines mentioned, the polygon will have a unique color. (Four polygon colors in total.)
# Both of the mentioned lines will have a defined width and color for each end.
# All colors will fade into neighboring colors for each element.

# WORKING DETAILS:
# For any line that uses curves, the number of points should be "(X*3)+1", where X can be any integer.
# You can remove either line by setting both of it's widths to zero. (Width is applied at both ends.)
# You can remove the match line by making it not visible (by clicking the eye icon).
# - This feature is not supported for the main line.

# LINE TITLE DETAILS:
# This script is shaped by two Line2D nodes, including this node.
# The two shape-defining lines are the "main line", and the "match line".
# There are also two Line2D nodes used for outline drawing. They are created and managed in this script.

# MAIN LINE DETAILS (this node):
# The main line is the current node, which is also a Line2D node.
# In the inspector the main line's width is intend to be zero.
# This node can have any name

# MATCH LINE DETAILS (the child node):
# The match line is a child of the current node, which is also a Line2D node.
# In the inspector the match line's width is intend to be zero.
# This child node should be called "match_line".

onready var match_line = get_node("match_line") # match line
onready var draw_line_main = Line2D.new() # main line
onready var draw_line_match = Line2D.new() # match line

# init variables 
var curve_count = (get_point_count()-1)/3 # main line
var line_count_match # match line
# NOTE: If match_line_curve_mode is true, then line_count_match will count curves, not lines as implied.
var position_offset_match # match line

var primitive_points_array # main line AND match line
var primitive_colors_array # main line AND match line
var t = 0 # match line AND main line
var t2 = 0 # stores a value conversion from the entire line, to a single cuve.
var linear_middle # stores point for bezier transition from the second point to the third point (out of 4 points)
var current_point_index # stores current point index for building lines
var current_position # stores the current position for building lines
var t_segment # stores the shape's segment size as a value from 0 to 1

# CUSTOMIZATIONS
# NOTE: There is 18 digits of decimal precision. (Godot 3.2.2)
export(bool) var match_line_curve_mode = true # If true, match line will use bezier curves. Otherwise, the match line will be linear. (only the match line has this kind of switch)
export(int) var segments_per_curve = 30 # happens for the match line AND main line.
# segments_per_curve needs to be at least 6

# polygon colors (customizations)
export(Color) var polygon_main_color_start = Color.red
export(Color) var polygon_main_color_end = Color.yellow
export(Color) var polygon_match_color_start = Color.lime
export(Color) var polygon_match_color_end = Color.aqua

# main draw line details (customizations)
export(Color) var line_main_color_start = Color.blue
export(Color) var line_main_color_end = Color.fuchsia
export(float) var line_main_width_start = 2
export(float) var line_main_width_end = 10

# match draw line details (customizations)
export(Color) var line_match_color_start = Color.lightgray
export(Color) var line_match_color_end = Color.darkgray
export(float) var line_match_width_start = 10
export(float) var line_match_width_end = 2

func _ready():
	# init (continued)
	if match_line_curve_mode: line_count_match = floor((match_line.get_point_count()-1)/3) # main line # match line
	else: line_count_match = match_line.get_point_count()-1 # match line
	position_offset_match=match_line.position
	t_segment = 1/ float(segments_per_curve*curve_count) # segment size for match line AND main line. 0.1 means 10 segments for the whole shape.


func _draw():
	add_child(draw_line_main)
	add_child(draw_line_match)
	
	while t<1-t_segment:
		# reset primitive data
		primitive_points_array = [] # main line AND match line (for polygon)
		primitive_colors_array = [] # main line AND match line (for polygon)
		
		# main line for polygon
		current_point_index = floor(t*curve_count)*3
		linear_middle = lerp(get_point_position(current_point_index+1), get_point_position(current_point_index+2), t2)
		current_position = lerp( lerp( lerp(get_point_position(current_point_index), get_point_position(current_point_index+1), t2) , linear_middle , t2) , lerp( linear_middle , lerp(get_point_position(current_point_index+2), get_point_position(current_point_index+3), t2)  , t2) , t2)
		primitive_points_array.push_back(Vector2(current_position))
		primitive_colors_array.push_back(lerp(polygon_main_color_start, polygon_main_color_end, t))
		
		# main draw line
		draw_line_main.add_point(Vector2(current_position))
		
		# match line for polygon
		t2 = (t * line_count_match) - floor(t * line_count_match)
		if match_line_curve_mode: 
			current_point_index = floor(t*line_count_match)*3
			linear_middle = lerp(match_line.get_point_position(current_point_index+1), match_line.get_point_position(current_point_index+2), t2)
			current_position = lerp( lerp( lerp(match_line.get_point_position(current_point_index), match_line.get_point_position(current_point_index+1), t2) , linear_middle , t2) , lerp( linear_middle , lerp(match_line.get_point_position(current_point_index+2), match_line.get_point_position(current_point_index+3), t2)  , t2) , t2)
		else:
			current_point_index = floor(t*line_count_match)
			current_position = lerp(match_line.get_point_position(current_point_index), match_line.get_point_position(current_point_index+1), t2)
		primitive_points_array.push_back(Vector2(current_position+position_offset_match))
		primitive_colors_array.push_back(lerp(polygon_match_color_start, polygon_match_color_end, t))
		
		# match draw line
		draw_line_match.add_point(Vector2(current_position+position_offset_match))
		
		# go to next segment
		t += t_segment
		t2 = (t * line_count_match) - floor(t * line_count_match)
		
		# match line for polygon
		if match_line_curve_mode: 
			current_point_index = floor(t*line_count_match)*3
			linear_middle = lerp(match_line.get_point_position(current_point_index+1), match_line.get_point_position(current_point_index+2), t2)
			current_position = lerp( lerp( lerp(match_line.get_point_position(current_point_index), match_line.get_point_position(current_point_index+1), t2) , linear_middle , t2) , lerp( linear_middle , lerp(match_line.get_point_position(current_point_index+2), match_line.get_point_position(current_point_index+3), t2)  , t2) , t2)
		else:
			current_point_index = floor(t*line_count_match)
			current_position = lerp(match_line.get_point_position(current_point_index), match_line.get_point_position(current_point_index+1), t2)
		primitive_points_array.push_back(Vector2(current_position+position_offset_match))
		primitive_colors_array.push_back(lerp(polygon_match_color_start, polygon_match_color_end, t))
		
		# main line for polygon
		current_point_index = floor(t*curve_count)*3
		t2 = (t * curve_count) - floor(t * curve_count)
		linear_middle = lerp(get_point_position(current_point_index+1), get_point_position(current_point_index+2), t2)
		current_position = lerp( lerp( lerp(get_point_position(current_point_index), get_point_position(current_point_index+1), t2) , linear_middle , t2) , lerp( linear_middle , lerp(get_point_position(current_point_index+2), get_point_position(current_point_index+3), t2)  , t2) , t2)
		primitive_points_array.push_back(Vector2(current_position))
		primitive_colors_array.push_back(lerp(polygon_main_color_start, polygon_main_color_end, t))
		
		draw_primitive(primitive_points_array,primitive_colors_array,PoolVector2Array(),null,30,null)
	
	# last point of the main draw line
	draw_line_main.add_point(Vector2(current_position))
	
	# color the main draw line
	draw_line_main.gradient = Gradient.new()
	draw_line_main.gradient.set_offset(0, 0)
	draw_line_main.gradient.set_offset(1, 1)
	draw_line_main.gradient.set_color(0, line_main_color_start)
	draw_line_main.gradient.set_color(1, line_main_color_end)
	
	# set the main draw line width
	draw_line_main.width_curve = Curve.new()
	draw_line_main.width=max(line_main_width_start, line_main_width_end)
	if line_main_width_start>line_main_width_end:
		if line_main_width_start!=0: # no need for "and visible == true" because _draw() would stop if it were false.
			draw_line_main.width_curve.add_point(Vector2(0,1),0,0,0,0)
			draw_line_main.width_curve.add_point(Vector2(1,line_main_width_end/line_main_width_start),0,0,0,0)
		else:
			draw_line_main.width_curve.add_point(Vector2(0,0),0,0,0,0)
			draw_line_main.width_curve.add_point(Vector2(1,0),0,0,0,0)
	else:
		if line_main_width_start!=0: # no need for "and visible == true" because _draw() would stop if it were false.
			draw_line_main.width_curve.add_point(Vector2(0,line_main_width_start/line_main_width_end),0,0,0,0)
			draw_line_main.width_curve.add_point(Vector2(1,1),0,0,0,0)
		else:
			draw_line_main.width_curve.add_point(Vector2(0,0),0,0,0,0)
			draw_line_main.width_curve.add_point(Vector2(1,0),0,0,0,0)
	
	# last point of the match draw line
	if match_line_curve_mode: current_position = match_line.get_point_position(line_count_match*3)
	else: current_position = match_line.get_point_position(line_count_match)
	draw_line_match.add_point(Vector2(current_position+position_offset_match))
	
	# color the match draw line
	draw_line_match.gradient = Gradient.new()
	draw_line_match.gradient.set_offset(0, 0)
	draw_line_match.gradient.set_offset(1, 1)
	draw_line_match.gradient.set_color(0, line_match_color_start)
	draw_line_match.gradient.set_color(1, line_match_color_end)
	
	# set the match draw line width
	draw_line_match.width_curve = Curve.new()
	draw_line_match.width=max(line_match_width_start, line_match_width_end)
	if line_match_width_start>line_match_width_end:
		if line_match_width_start!=0 and match_line.visible == true:
			draw_line_match.width_curve.add_point(Vector2(0,1),0,0,0,0)
			draw_line_match.width_curve.add_point(Vector2(1,line_match_width_end/line_match_width_start),0,0,0,0)
		else:
			draw_line_match.width_curve.add_point(Vector2(0,0),0,0,0,0)
			draw_line_match.width_curve.add_point(Vector2(1,0),0,0,0,0)
	else:
		if line_match_width_end!=0 and match_line.visible == true:
			draw_line_match.width_curve.add_point(Vector2(0,line_match_width_start/line_match_width_end),0,0,0,0)
			draw_line_match.width_curve.add_point(Vector2(1,1),0,0,0,0)
		else:
			draw_line_match.width_curve.add_point(Vector2(0,0),0,0,0,0)
			draw_line_match.width_curve.add_point(Vector2(1,0),0,0,0,0)
