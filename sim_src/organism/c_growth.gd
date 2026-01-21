class_name C_Growth
extends Component

@export var growth: float = 0.0
@export var growth_constant: float = 0.0

@export var mass: float = 0.0
@export var max_mass: float = 0.0

@export var growth_rate_constant: float = 0.0

@export var food_storage: float = 0.0
@export var energy_stores: float = 0.0
@export var metabolic_rate: float = 0.0 # constant based on individual
@export var energy_constant: float = 0.0
@export var can_grow: bool = false
@export var reproductive_threshhold: float = 0.0

func _init(growth_dict):
    growth = 0.0
    growth_constant = growth_dict["growth_constant"]
    mass = growth_dict["mass"]
    mass_constant = growth_dict["mass_constant"]
    max_mass = growth_dict["max_mass"]
    growth_rate_constant = growth_dict["growth_rate_constant"]
    can_grow = false
    food_storage = 0.0
    energy_stores = 0.0
    metabolic_rate = growth_dict["metabolic_rate"]
    energy_constant = growth_dict["energy_constant"]