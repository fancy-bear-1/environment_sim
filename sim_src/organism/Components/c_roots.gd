class_name C_Roots
extends C_PlantParts

@export var porosity_constant: float = 0.0

func _init(root_dict):
    super()
    porosity_constant = root_dict["porosity_constant"]