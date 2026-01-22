class_name C_Roots
extends Component

@export var ratio: float = 0.0
@export var width: float = 0.0
@export var depth: float = 0.0
@export var max_width: float = 0.0
@export var max_depth: float = 0.0
@export var preferred_width: float = 0.0
@export var preferred_depth: float = 0.0
@export var porosity_constant: float = 0.0

func _init(root_dict):
    ratio = root_dict["ratio"]
    width = root_dict["width"]
    depth = root_dict["depth"]
    max_width = root_dict["max_width"]
    max_depth = root_dict["max_depth"]
    preferred_depth = root_dict["preferred_depth"]
    preferred_width = root_dict["preferred_width"]
    porosity_constant = root_dict["porosity_constant"]