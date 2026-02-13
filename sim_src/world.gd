class_name World
extends Node3D
#
#const Chunk = preload("res://sim_src/chunk.gd")
#const Biome = preload("res://sim_src/biome.gd")
#const ClaySandSilt = preload("res://sim_src/soil/clay_silt_sand.gd")
const BIOME_LIST = preload("res://sim_src/biomes.json").data

static var width := 100
static var height := 100
static var num_biomes := 20
static var max_mountains := 100
static var min_mountains := 10
static var max_mountain_elevation := 100.0
static var max_mountain_radius := 20
static var max_mountain_peak_radius := 5

static var steepness_gradient_radius := 2

static var days_in_season := 90
static var steps_per_day := 2
static var day_to_day_variance := 20
static var world_scale := 1.0
static var weathering_radius := 1

static var body_of_water_threshold = 1.0


var chunklist: Array[Array] = []
var generated_biomelist: Array[Biome] = []
var year: int = 0
var day: int = 0
var day_subcount: int = 0
var years_to_next_css_change: int = 400
var years_to_next_css_tolerance: int = 1000
var mountains:Array[Vector2]
var selected_biome:Biome
var sun:DirectionalLight3D

var world_seed: int
@onready var world:World=$World

func generate_steepness(elevation_map):

    # initialize gradient map
    var res = []
    for x in range(width):
        var tmp = []
        for y in range(height):
            tmp.append(0.0)
        res.append(tmp)

    # for every chunk on the map
    for x in range(width):
        for y in range(height):
            var xm := max(x - 1, 0)
            var xp := min(x + 1, width - 1)
            var ym := max(y - 1, 0)
            var yp := min(y + 1, height - 1)

            var dx := (elevation_map[xp][y] - elevation_map[xm][y]) * 0.5
            var dy := (elevation_map[x][yp] - elevation_map[x][ym]) * 0.5

            res[x][y] = Vector2(dx, dy)

    return res


func elevation_second_derivative(steepness_map):
    # initialize gradient map
    var res = []
    for x in range(width):
        var tmp = []
        for y in range(height):
            tmp.append(0.0)
        res.append(tmp)

    # for every chunk on the map
    for x in range(width):
        for y in range(height):
            var xm := max(x - 1, 0)
            var xp := min(x + 1, width - 1)
            var ym := max(y - 1, 0)
            var yp := min(y + 1, height - 1)

            var dx := (steepness_map[xp][y].x - steepness_map[xm][y].x) * 0.5
            var dy := (steepness_map[x][yp].y - steepness_map[x][ym].y) * 0.5
            dy += (steepness_map[xp][y].y - steepness_map[xm][y].y) * 0.5
            dx += (steepness_map[x][yp].x - steepness_map[x][ym].x) * 0.5
            res[x][y] = Vector2(dx, dy)
    
    return res


func generate_mountains():
    var elevation_map:Array[Array] = []

    # start by creating blank map of normal scale
    for x in range(width):
        var tmp:Array[float]
        for y in range(height):
            tmp.append(1.0)
        elevation_map.append(tmp)

    for i in range((randi() % (max_mountains - min_mountains)) + min_mountains):
        print("mountain " + str(i + 1))
        var elevation: float = (randf() * 2 * max_mountain_elevation) - max_mountain_elevation
        print("elevation " + str(elevation))
        var peak_radius: int = randi() % max_mountain_peak_radius
        print("peak_radius " + str(peak_radius))
        var radius: int = (randi() % (max_mountain_radius - peak_radius))
        print("radius " + str(radius))
        var center:Vector2 = Vector2(randi() % width, randi() % height)
        print("center " + str(center))
        var step = elevation / (radius - peak_radius)
        print("step " + str(step))

        var tmp_x = center.x
        var tmp_y = center.y

        # first set the elevation to the peak elevation for any chunks within the radius
        var circle_diameter = 1 + (2 * radius)
        for x in range(circle_diameter):
            for y in range(circle_diameter):
                var iter_to_coord = Vector2((tmp_x + x) - (int(circle_diameter / 2) + 1), (tmp_y + y) - (int(circle_diameter / 2) + 1))
                if iter_to_coord.x >= 0 and iter_to_coord.x < width and iter_to_coord.y >= 0 and iter_to_coord.y < height:
                    var current_distance = center.distance_to(iter_to_coord)
                    if current_distance <= peak_radius:
                        # print("peak hit")
                        var current_val = elevation_map[int(iter_to_coord.x)][int(iter_to_coord.y)]
                        if current_val != 1.0: 
                            elevation_map[int(iter_to_coord.x)][int(iter_to_coord.y)] = (elevation + 1 + current_val) / 2
                        else:
                            elevation_map[int(iter_to_coord.x)][int(iter_to_coord.y)] = elevation + 1
                    elif current_distance <= radius:
                        # print("slope hit")
                        var current_val = elevation_map[int(iter_to_coord.x)][int(iter_to_coord.y)]
                        if current_val != 1.0: 
                            elevation_map[int(iter_to_coord.x)][int(iter_to_coord.y)] = \
                            (elevation - (step * (current_distance - peak_radius)) + 1 + current_val) / 2
                        else:
                            elevation_map[int(iter_to_coord.x)][int(iter_to_coord.y)] = elevation - (step * (current_distance - peak_radius)) + 1

    return elevation_map


func generate_water(elevation_map, steepness_map):
    var body_of_water_map = []

    var second_derivative = elevation_second_derivative(steepness_map)

    for x in range(width):
        var tmp:Array[float]
        for y in range(height):
            tmp.append(false)
        body_of_water_map.append(tmp)

    # # first do a base layer of water at elevation 1 or less
    # for x in range(width):
    #     for y in range(height):
    #         if elevation_map[x][y] <= 0.0:
    #             body_of_water_map[x][y] = true

    for x in range(width):
        for y in range(height):
            # if the current point is a local minimum, set it to true on the map and fill out the rest of the body
            if steepness_map[x][y].magnitude() <= body_of_water_threshold and \
            second_derivative[x][y].x > 0 and second_derivative[x][y].y > 0:
                var tmp = fill_water_body(Vector2(x, y), x, y, elevation_map, steepness_map, second_derivative)
                # to fill it out, find the borders of the body by finding the other points where steepness is below the threshold but the second derivative is pointing away from the center
                for coord in tmp:
                    body_of_water_map[coord.x][coord.y] = true

    for x in range(width):
        for y in range(height):
            if body_of_water_map[x][y]:
                # TODO: render water polygons
                pass


func fill_water_body(center, x, y, elevation_map, steepness_map, second_derivative_map):
    var direction_from_center = Vector2(x - center.x, y - center.y).normalize()
    var res: Array[Vector2] = []
    
    # if the current chunk is out of bounds
    if x <= 0 or y <= 0: return []
    
    # if the current chunk is the center
    if center == Vector2(x, y):
        res.append(center)

    # if the current chunk is on the border
    elif steepness_map[x][y].magnitude() <= body_of_water_threshold:
        var tmp = second_derivative_map[x][y]
        # if the sign of the 2nd derivative is the same as the direction from the center, this tile IS part of the body of water
        if (tmp.x == 0 or tmp.x / abs(tmp.x) == direction_from_center.x / abs(direction_from_center.x)) and \
            (tmp.y == 0 or tmp.y / abs(tmp.y) == direction_from_center.y / abs(direction_from_center.y)):
            res.append(Vector2(x, y))

    # otherwise determine whether the current chunk is 
    else:
        var tmp = steepness_map[x][y]
        # if the sign of the 2nd derivative is the same as the direction from the center, this tile IS part of the body of water
        if (tmp.x == 0 or tmp.x / abs(tmp.x) == direction_from_center.x / abs(direction_from_center.x)) and \
            (tmp.y == 0 or tmp.y / abs(tmp.y) == direction_from_center.y / abs(direction_from_center.y)):
            res.append(Vector2(x, y))

    for dx in [1, 0, -1]:
        for dy in [1, 0, -1]:
            # if the change is not 0, 0
            if dx != 0 or dy != 0:
                # recursive call on next chunk
                res += fill_water_body(center, x + dx, y + dy, elevation_map, steepness_map, second_derivative_map)

    return res


func _phys_erosion():
    pass


func _chem_erosion():
    # based off of moisture

    pass


func _do_erosion():
    _chem_erosion()
    _phys_erosion()


func _save():
    var save_game = File.new()
    save_game.open("user://" + world_seed + ".save", File.WRITE)
    
    save_game.store_line(world_seed + ", " + "YEAR: " + str(year) + ", DAY: " + str(day))

    save_game.store_line("BIOMES")
    for biome in generated_biomelist:
        save_game.store_line(to_json(biome))

    save_game.store_line("CHUNKS")

    for chunk in chunklist:
        save_game.store_line(to_json(chunk))


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if world_seed == null:
        randomize()
        world_seed = randi()
        seed(world_seed)  # Apply it globally
        print("Seed: ", world_seed)

    var ui = get_node(NodePath("../Camera3D/CanvasLayer"))
    ui.find_child("VERSION").text += "\nSEED: " + str(world_seed)

    var biome_count:Dictionary = {}
    for biome in BIOME_LIST.keys():
        biome_count[biome] = 0

    print("generating biomes")
    # first generate biome centers
    for i in range(num_biomes):
        var new_biome_center = Vector2(randi() % width, randi() % height)
        var new_biome_name = BIOME_LIST.keys()[randi() % BIOME_LIST.size()]
        var tmp_name = ''
        if biome_count[new_biome_name] != 0:
            tmp_name = new_biome_name + " " + str(biome_count[new_biome_name] + 1)
        else:
            tmp_name = new_biome_name
        var new_biome = Biome.new(tmp_name, new_biome_center, BIOME_LIST[new_biome_name])
        generated_biomelist.append(new_biome)
        biome_count[new_biome_name] += 1
        new_biome.add_to_group("biomes")
        add_child(new_biome)

    selected_biome = generated_biomelist[0]

    print("job done")

    print("generating mountains")
    var elevation_map = generate_mountains()


    var steepness_map = generate_steepness(elevation_map)
    print("generating bodies of water")

    var elevation_map = generate_water()
    print("job done")

    var birdseye_cam = get_node(NodePath('../Camera3D/CanvasLayer/2d_map/birds-eye cam'))
    birdseye_cam.set_position(Vector3(width * .5, max_mountain_elevation * 10, height * .5))
    sun = DirectionalLight3D.new()
    sun.position = Vector3(width * .5, 10 + max_mountain_elevation * 3, height * .5)

    print("generating chunks")
    for y in range(height):
        var chunk_row: Array[Chunk] = []
        for x in range(width):
            var current_point = Vector2(x, y)
            var temp_biome = null
            var temp_distance = width * 100
            for biome in generated_biomelist:
                if current_point.distance_to(biome.center) < temp_distance:
                    temp_distance = current_point.distance_to(biome.center)
                    temp_biome = biome

            chunk_row.append(Chunk.new(current_point, temp_biome, world_scale, elevation_map[x][y]))
            temp_biome.chunklist.append(chunk_row[-1])
            add_child(chunk_row[-1])
            
        chunklist.append(chunk_row)
    print("job done")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    day_subcount += 1
    if day_subcount >= steps_per_day:
        day_subcount = 0
        day += 1
    if day % days_in_season == 0 and day_subcount == 0:
        # print("next season")
        for biome in generated_biomelist:
            biome.next_season()

    if day > days_in_season * 4:
        day = 0
        year += 1
        years_to_next_css_change -= 1
        # print("YEAR: " + str(year))

    if years_to_next_css_change <= 0:
        years_to_next_css_change = (randi() * years_to_next_css_tolerance) + (years_to_next_css_tolerance / 2)

    var ui = get_node(NodePath("../Camera3D/CanvasLayer"))
    if day_subcount == 0:
        ui.find_child("year_day").text = "YEAR: " + str(year) + " DAY: " + str(day)

    var tmp = ''
    var tmp_biome = ui.find_child("biome")
    if tmp_biome.text != "SELECTED BIOME: " + selected_biome.name:
        match int(day / 90): 
            0: tmp = "SUMMER" 
            1: tmp = "FALL"
            2: tmp = "WINTER"
            3: tmp = "SPRING"
        tmp_biome.text = "SELECTED BIOME: " + selected_biome.name + "\n\t\t\t\tSEASON: " + tmp

    tmp = "SEASON TEMPERATURE: " + str(snapped(selected_biome.temperature, 0.01)) + "\n"
    tmp += "SEASON HUMIDITY: " + str(snapped(selected_biome.humidity, 0.01)) + "\n"
    tmp += "NUTRIENT LEVEL: " + str(snapped(selected_biome.nutrient_level, 0.01)) + "\n"
    tmp += "NUTRIENT RETENTION: " + str(snapped(selected_biome.nutrient_retention, 0.01)) + "\n"
    tmp += "WATER RETENTION: " + str(snapped(selected_biome.water_retention, 0.01)) + "\n"
    tmp += "MOISTURE: " + str(snapped(selected_biome.moisture, 0.01)) + "\n"
    tmp += "RAINING: " + str(selected_biome.raining)
    if ui.find_child("biome_data").text != tmp:
        ui.find_child("biome_data").text = tmp

    var pie_chart = ui.find_child("PieChart")
    var graph_elements: Dictionary[String, float] = {}
    graph_elements["clay"] = float(selected_biome.css.clay)
    graph_elements["sand"] = float(selected_biome.css.sand)
    graph_elements["silt"] = float(selected_biome.css.silt)
    if graph_elements != pie_chart.elements:
        pie_chart.set_new_data(graph_elements)
