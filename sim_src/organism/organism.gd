class_name Organism
extends Entity

const ORGANISM_TYPE_LIST = preload("res://sim_src/organisms.json").data

@export var growth: C_Growth = null
@export var health: C_Health = null
@export var food_source: C_FoodSource = null

@export var current_chunk = null

func _init(name, parent):
    current_chunk = parent
    if name in ORGANISM_TYPE_LIST.keys():
        var temp_dict = ORGANISM_TYPE_LIST[name]
        growth = C_Growth.new(temp_dict["growth"])
        health = C_Health.new()
        food_source = C_FoodSource.new(temp_dict["food_source"])