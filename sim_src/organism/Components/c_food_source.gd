class_name C_FoodSource
extends Component

@export var intake_rate:float = 0.0
@export var producer:bool = null
@export var growing_medium:String = ""
@export var preferred_sunlight: float = 0.0
@export var light_diff_tolerance: float = 0.0

func _init(temp_dict):
    intake_rate = temp_dict["intake_rate"]

    # bool for plants
    producer = temp_dict["producer"]
    
    growing_medium = temp_dict["growing_medium"] # either for roots or for breathing
    # I.E. for a fish growing_medium would be water:gills
    # for a tree soil/strata:roots
    # for a human "air:lungs" etc.

    preferred_sunlight = temp_dict["preferred_sunlight"]
    light_diff_tolerance = temp_dict["light_diff_tolerance"]