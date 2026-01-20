class_name Organism
extends Entity

@export var growth: C_Growth = null
@export var health: C_Health = null

func _init(name):
    growth = C_Growth.new()