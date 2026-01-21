class_name C_FoodSource
extends Component

@export var intake_rate:float = 0.0
@export var producer:bool = null

func _init(temp_dict):
    intake_rate = temp_dict["intake_rate"]

    # bool for plants
    producer = temp_dict["producer"]
    
    growing_medium = temp_dict["growing_medium"] # either for roots or for breathing
    # I.E. for a fish growing_medium would be water:gills
    # for a tree soil/strata:roots
    # for a human "air:lungs" etc.
