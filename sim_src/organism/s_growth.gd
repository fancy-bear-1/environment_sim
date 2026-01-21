class_name GrowthSystem
extends System

# only affects living organisms
func query():
    return QueryBuilder.new(world).with_all([C_Growth, {C_Health: {"alive": true}}]).execute()

func _metabolism(entity: Entity):
    entity.get_component(C_Growth) as c_growth
    entity.get_component(C_Health) as health

    if c_growth.food_storage > metabolic_rate:
        c_growth.food_storage -= metabolic_rate
        c_growth.energy_stores += c_growth.metabolic_rate * c_growth.energy_constant
        if health.starving: health.starving = 
    else:
        var temp = food_storage - metabolic_rate
        c_growth.food_storage = 0.0
        c_growth.energy_stores += temp
        if c_growth.energy_stores <= 0:
            health.starving = true
            health.health += c_growth.energy_stores
            c_growth.energy_stores = 0.0

func _process(entity: Entity, _delta: float):
    entity.get_component(C_Growth) as c_growth

    # handle metablism first
    _metabolism(entity)


    # handle growth
    if c_growth.can_grow:

        c_growth.mass_rate = c_growth.mass * c_growth.growth_rate_constant * \
        (1 - (c_growth.mass / c_growth.max_mass))

        c_growth.mass += c_growth.mass_rate * _delta * c_growth.growth_constant

    else:
        max_mass -= 