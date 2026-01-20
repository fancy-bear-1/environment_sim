class_name C_Growth
extends Component

@export var growth: float = 0.0
@export var growth_constant: float = 0.0

@export var mass: float = 0.0
@export var mass_constant: float = 0.0
@export var max_mass: float = 0.0

@export var growth_rate: float = 0.0
@export var growth_rate_constant: float = 0.0

@export var food_source:Array[Entity] = []
@export var food_storage: float = 0.0
@export var energy_stores: float = 0.0
@export var metabolic_rate: float = 0.0 # constant based on individual

@export var can_grow: bool = false
@export var reproductive_threshhold: float = 0.0

func _init(_growth, _growth_constant, _mass, _mass_constant, _max_mass, _growth_rate, _growth_rate_constant, _food_source, _can_grow, _reproductive_threshhold):
    growth = _growth
    growth_constant = _growth_constant
    mass = _mass
    mass_constant = _mass_constant
    max_mass = _max_mass
    growth_rate = _growth_rate
    growth_rate_constant = _growth_rate_constant
    can_grow = _can_grow
    food_source = _food_source
    reproductive_threshhold = _reproductive_threshhold
