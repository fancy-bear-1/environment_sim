class_name GrowthSystem
extends System

func query():
    return QueryBuilder.new(world).with_all([C_Growth]).execute()

func _process(entity: Entity, _delta: float):
    entity.get_component(C_Growth) as c_growth

    if c_growth.can_grow:

        c_growth.mass_rate = c_growth.mass * c_growth.growth_rate_constant * \
        (1 - (c_growth.mass / c_growth.max_mass))

        c_growth.mass += c_growth.mass_rate * _delta * c_growth.growth_constant

    else:
        max_mass -= 