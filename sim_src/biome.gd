class_name Biome
extends Node

# const ClaySandSilt = preload("res://sim_src/soil/clay_silt_sand.gd")

static var tolerance := 1.0
var chunks: Array[Chunk] = []

var center: Vector2
var temperature: float
var season_temperature: Array[float]
var humidity: float
var season_humidity: Array[float]
var nutrient_level: float
var nutrient_retention: float
var water_retention: float
var moisture: float
var css: ClaySandSilt
var color: Array
var selected_flag: bool
var chunklist: Array[Chunk]
var raining: bool
var season_index: int

func _rand_by_tolerance(num:float) -> float:
    return (num + ((randf() * tolerance) - (tolerance / 2)))

# Called when the node enters the scene tree for the first time.
func _init(biome_name, center_coord, biome_dict) -> void:
    center = center_coord
    name = biome_name
    season_index = 0

    season_temperature =[] 
    for current_season_temp in biome_dict["temperature"]:
        season_temperature.append(current_season_temp + ((randf() * tolerance) - (tolerance / 2)))
    for current_season_hum in biome_dict["humidity"]:
        season_humidity.append(current_season_hum + ((randf() * tolerance) - (tolerance / 2)))
    temperature = season_temperature[season_index] + ((randf() * tolerance) - (tolerance / 2))
    humidity = season_humidity[season_index] + ((randf() * tolerance) - (tolerance / 2))
    nutrient_level = biome_dict["nutrient_level"] + ((randf() * tolerance) - (tolerance / 2))
    nutrient_retention = biome_dict["nutrient_retention"] + \
    ((randf() * tolerance) - (tolerance / 2))
    water_retention = biome_dict["water_retention"] + ((randf() * tolerance) - (tolerance / 2))
    moisture = biome_dict["moisture"] + ((randf() * tolerance) - (tolerance / 2))
    css = ClaySandSilt.new(biome_dict["css"], false)
    #weathering_rate = biome_dict["weathering_rate"] + ((randf() * tolerance) - (tolerance / 2))
    color = biome_dict["color"]
    selected_flag = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var var_avg_dict = {"nutrient_level": 0.0, "moisture": 0.0, "clay": 0, "sand": 0, "silt": 0}
    var raining_counter = 0
    for chunk in chunklist:
        var_avg_dict["nutrient_level"] += chunk.nutrient_level
        var_avg_dict["moisture"] += chunk.moisture
        if chunk.raining: raining_counter += 1
        var_avg_dict["clay"] += chunk.css.clay
        var_avg_dict["sand"] += chunk.css.sand
        var_avg_dict["silt"] += chunk.css.silt

    nutrient_level = var_avg_dict["nutrient_level"]
    moisture = var_avg_dict["moisture"]
    raining = raining_counter > (len(chunklist) / 2) 
    
    css.clay = int(var_avg_dict["clay"] / len(chunklist))
    css.sand = int(var_avg_dict["sand"] / len(chunklist))
    css.silt = int(var_avg_dict["silt"] / len(chunklist))

func _next_season() -> void:
    if len(season_humidity) > 1:
        season_index += 1
        if season_index >= len(season_temperature):
            season_index = 0
        
        temperature = season_temperature[season_index]
        humidity = season_humidity[season_index]
        for chunk in chunklist:
            chunk.next_season()

func on_mouse_entered():
    if not selected_flag:
        selected_flag = true
        print("mouse entered biome " + name)
        var world_node = get_node(NodePath('../'))
        # while world_node.lock:
            # pass
        # world_node.lock = true
        world_node.selected_biome = self
        for biome in world_node.generated_biomelist:
            if biome != self:
                biome.selected_flag = false
        # world_node.lock = false
