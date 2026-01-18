class_name World
extends Node3D

const Chunk = preload("res://sim_src/chunk.gd")
const Biome = preload("res://sim_src/biome.gd")
const ClaySandSilt = preload("res://sim_src/soil/clay_silt_sand.gd")
const BIOME_LIST = preload("res://sim_src/biomes.json").data

static var width := 100
static var height := 100
static var num_biomes := 20
static var max_mountains := 100
static var max_mountain_elevation := 20.0
static var max_mountain_radius := 20
static var max_mountain_peak_radius := 5

static var days_in_season := 90
static var steps_per_day := 2
static var day_to_day_variance := 20
static var world_scale := 1.0
static var weathering_radius := 1

var chunklist: Array[Array] = []
var generated_biomelist: Array[Biome] = []
var year: int = 0
var day: int = 0
var day_subcount: int = 0
var years_to_next_css_change: int = 400
var years_to_next_css_tolerance: int = 1000
var mountains:Array[Vector2]
var selected_biome:Biome

var world_seed: int

func generate_mountains():
    var elevation_map:Array[Array] = []

    # start by creating blank map of normal scale
    for x in range(width):
        var tmp:Array[float]
        for y in range(height):
            tmp.append(1.0)
        elevation_map.append(tmp)

    for i in range(randi() % max_mountains):
        print("mountain " + str(i + 1))
        var elevation: float = randf() * max_mountain_elevation
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

func _phys_erosion():
    pass

func _chem_erosion():
    # based off of 
    pass

func _do_erosion():
    _chem_erosion()
    _phys_erosion()

func _save():
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

    if world_seed == null:
        randomize()
        world_seed = randi()
        seed(world_seed)  # Apply it globally
        print("Seed: ", world_seed)

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

    print("job done")

    print("generating elevation map")
    var elevation_map = generate_mountains()
    print("job done")

    var birdseye_cam = get_node(NodePath('birds-eye cam'))
    birdseye_cam.position = Vector3(width * .5, max_mountain_elevation * 3, height * .75)

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
            add_child(chunk_row[-1])
            
        chunklist.append(chunk_row)
    print("job done")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    day_subcount += 1
    if day_subcount >= steps_per_day:
        day_subcount = 0
        day += 1
    if day % days_in_season == 0 and day_subcount == 0:
        print("next season")

    if day > days_in_season * 4:
        day = 0
        year += 1
        years_to_next_css_change -= 1
        print("YEAR: " + str(year))

    if years_to_next_css_change <= 0:
        years_to_next_css_change = (randi() * years_to_next_css_tolerance) + (years_to_next_css_tolerance / 2)
