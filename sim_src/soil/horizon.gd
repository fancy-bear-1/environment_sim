class_name Horizon
extends Node

var porosity: float = 0.0 # 0 is solid rock, 100 is large gravel
var hardness: float = 0.0 # 0 is sphagnum moss, 100 is solid granite
var moisture: float = 0.0
var thickness: float = 0.0

# these 4 are percentages of the makeup of this horizon
var clay: float = 0.0
var silt: float = 0.0
var sand: float = 0.0
var organics: float = 0.0

func _init(horizon_dict:dict):
    porosity = horizon_dict["porosity"]
    moisture = horizon_dict["moisture"]
    hardness = horizon_dict["hardness"]

    clay = horizon_dict["clay"]
    silt = horizon_dict["silt"]
    sand = horizon_dict["sand"]
    organics = horizon_dict["organics"]