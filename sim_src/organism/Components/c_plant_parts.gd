class_name C_PlantParts
extends Component

@export var ratio: float = 0.0
@export var width: float = 0.0
@export var depth: float = 0.0
@export var width_depth_ratio: float = 0.0
@export var max_width: float = 0.0
@export var max_depth: float = 0.0
@export var preferred_width: float = 0.0
@export var preferred_depth: float = 0.0

func _init(part_dict: dict):
    ratio = part_dict["ratio"]
    width = 0.0
    depth = 0.0
    width_depth_ratio = part_dict["width_depth_ratio"]
    max_width = part_dict["max_width"]
    max_depth = part_dict["max_depth"]
    preferred_depth = part_dict["preferred_depth"]
    preferred_width = part_dict["preferred_width"]