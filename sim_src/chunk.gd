class_name Chunk
extends Control

# const ClaySandSilt = preload("res://sim_src/soil/clay_silt_sand.gd")

static var tolerance := 5.0
static var elevation_const := -3.0
static var buffer := 10
static var elevation_noise_const := 1.0

var chunk_coord: Vector2
var temperature: float
var humidity: float
var nutrient_level: float
var nutrient_retention: float
var water_retention: float
var moisture: float
var css: ClaySandSilt
var raining: bool
var elevation: float
var _biome: Biome
var _world_scale: float

func _rand_by_tolerance(num:float) -> float:
    return (num + ((randf() * tolerance) - (tolerance / 2)))

func _refresh_biome_vars():
    # set all the elevation dependent variables
    temperature = _rand_by_tolerance(_biome.temperature) - ((elevation - 1) * elevation_const)
    humidity = _rand_by_tolerance(_biome.humidity) + ((elevation - 1) * elevation_const)
    nutrient_retention = _rand_by_tolerance(_biome.nutrient_retention)  - ((elevation - 1) * elevation_const)
    water_retention = _rand_by_tolerance(_biome.water_retention)  - ((elevation - 1) * elevation_const)
    
    # set the rest of the variables
    nutrient_level = _rand_by_tolerance(_biome.nutrient_level)
    moisture = _rand_by_tolerance(_biome.moisture)
    css = ClaySandSilt.new(_biome.css, true)

func _draw_chunk():
    # reponsible for drawing the chunk graphically and connecting the signal to the parent biome 

    # init variables
    var cube:MeshInstance3D = MeshInstance3D.new()
    var collision:CollisionShape3D = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    var area = Area3D.new()
    
    area.input_ray_pickable = true

    # set the shape size to use for collision box
    shape.extents = Vector3(1, buffer + elevation, 1)
    collision.shape = shape
    area.add_child(collision)

    # then create box graphically using the world scale and elevation
    # divided by 2 because this will create a flat bottom for the world
    cube.mesh = BoxMesh.new()
    cube.position = Vector3(_world_scale * chunk_coord.x, buffer + (_world_scale * elevation / 2), _world_scale * chunk_coord.y)
    area.position = Vector3(_world_scale * chunk_coord.x, buffer + (_world_scale * elevation / 2), _world_scale * chunk_coord.y)
    cube.scale = Vector3(_world_scale, _world_scale, _world_scale)
    cube.mesh.size = Vector3(1, buffer + elevation, 1)

    # then create a surface material and set the color
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(_biome.color[0], _biome.color[1], _biome.color[2])
    set_mouse_filter(1)
    
    # then set graphical box color and set children/add to group
    cube.mesh.surface_set_material(0, material)
    add_child(area)
    add_child(cube)
    add_to_group(_biome.name)

    # connect mouse_entered event to the biome's on_mouse_entered
    area.mouse_entered.connect(_biome.on_mouse_entered)

# Called when the node enters the scene tree for the first time.
func _init(coord, biome, world_scale, _elevation) -> void:

    # init basic vars
    chunk_coord = coord
    name = biome.name + ":" + str(chunk_coord.x) + ","  + str(chunk_coord.y)
    elevation = _elevation + ((randf() * elevation_noise_const) - (elevation_noise_const / 2))
    _biome = biome
    _world_scale = world_scale

    _refresh_biome_vars()
    
    _draw_chunk()

func _to_string():
    var tmp = name
    tmp += '\n\ttemp: ' + str(temperature)
    tmp += '\n\thum: ' + str(humidity)
    tmp += '\n\tnutl: ' + str(nutrient_level)
    tmp += '\n\tnutr: ' + str(nutrient_retention)
    tmp += '\n\twatr: ' + str(water_retention)
    tmp += '\n\tmois: ' + str(moisture)
    tmp += '\n\tcss: ' + str(css)
    return tmp

func rain():
    moisture += 1
    raining = true

func next_season():
    temperature = _rand_by_tolerance(_biome.temperature) - ((elevation - 1) * elevation_const)
    humidity = _rand_by_tolerance(_biome.humidity) + ((elevation - 1) * elevation_const)

func _do_tick():
    # water
    if raining:
        moisture += water_retention

        nutrient_level -= (nutrient_level * (randf() * (100 - nutrient_retention)) / 100)

    else:
        if randf() * 100 > water_retention:
            # moisture -= moisture * (randf() * 5) / 100
            moisture -= moisture * (randf() * water_retention) / 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if randi() * 100 <= humidity:
        rain()
    else:
        raining = false

    _do_tick()
