class_name Chunk
extends Control

const ClaySandSilt = preload("res://sim_src/soil/clay_silt_sand.gd")

static var tolerance := 1.0

var chunk_coord: Vector2
var temperature: float
var humidity: float
var nutrient_level: float
var nutrient_retention: float
var water_retention: float
var moisture: float
var css: ClaySandSilt
var raining: bool
var elevation: Dictionary

# Called when the node enters the scene tree for the first time.
func _init(coord, biome, world_scale, elevation) -> void:
    chunk_coord = coord
    elevation["level"] = elevation + ((randf() * tolerance) - (tolerance / 2))
    
    # init variables
    var cube:MeshInstance3D = MeshInstance3D.new()
    var collision:CollisionShape3D = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    var area = Area3D.new()
    
    area.input_ray_pickable = true

    # set the shape size to use for collision box
    shape.extents = Vector3(1, elevation, 1)
    collision.shape = shape
    area.add_child(collision)

    # then create box graphically
    cube.mesh = BoxMesh.new()
    cube.position = Vector3(world_scale * coord.x, (world_scale * elevation / 2), world_scale * coord.y)
    area.position = Vector3(world_scale * coord.x, (world_scale * elevation / 2), world_scale * coord.y)
    cube.scale = Vector3(world_scale, world_scale, world_scale)
    cube.mesh.size = Vector3(1, elevation, 1)

    var material = StandardMaterial3D.new()
    material.albedo_color = Color(biome.color[0], biome.color[1], biome.color[2])
    set_mouse_filter(1)

    name = biome.name + ":" + str(coord.x) + ","  + str(coord.y)
    
    # then set graphical box color and set children/add to group
    cube.mesh.surface_set_material(0, material)
    add_child(area)
    add_child(cube)
    add_to_group(biome.name)

    # connect mouse_entered event to the biome's on_mouse_entered
    area.mouse_entered.connect(biome.on_mouse_entered)

    temperature = biome.temperature + ((randf() * tolerance) - (tolerance / 2))
    humidity = biome.humidity + ((randf() * tolerance) - (tolerance / 2))
    nutrient_level = biome.nutrient_level + ((randf() * tolerance) - (tolerance / 2))
    nutrient_retention = biome.nutrient_retention + \
    ((randf() * tolerance) - (tolerance / 2))
    water_retention = biome.water_retention + ((randf() * tolerance) - (tolerance / 2))
    moisture = biome.moisture + ((randf() * tolerance) - (tolerance / 2))
    css = ClaySandSilt.new(biome.css, true)


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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if randi() * 100 <= humidity:
        rain()
    else:
        raining = false

    #NodePath
