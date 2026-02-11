class_name C_Health
extends Component

@export var health:float = 100.0
@export var starving:bool = false
@export var dehydrating: bool = false
@export var stress_level: int = 0 # is 0 at equilibrium/optimal levels, otherwise things like salinity imbalance or lack of nutrients increase this
                                  # at lower levels, increases storage growth rate(fat/starch), then at higher levels reduce that once again before hitting
                                  # starving levels or dying from salinity imbalance
@export var alive:bool = true