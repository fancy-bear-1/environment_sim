class_name Soil
extends Node

@export var hardness: float = 0.0 #
@export var depth: float = 0.0 # how far down the soil object is
@export var bounds: Array[Vector3] = []# how far below depth the soil object extends

# for non-layer objects this is the radius of the object

func _init(soil_dict: dict):
    