class_name S_Producer
extends System

func _query():
    return QueryBuilder.new(world).with_all( \
        [{ C_Health: {"alive": true}, \
           C_FoodSource: {"producer": true}}]).execute()

func _process(entity: Entity, _delta: float):
    entity.get_component(C_FoodSource) as food_source

    var produce:bool = False

    # if growth is sun-reliant in any way (including photosensitive)...
    # check if the current sunlight level is within their tolerance range
    if "preferred_sunlight" in food_source.keys():
        # if light is within the tolerance range proceed to next check
        if abs(food_source["preferred_sunlight"] - entity.current_chunk.sunlight) \
        <= food_source["light_diff_tolerance"]:
            produce = True

    if "growing_medium" in food_source.keys():
        # TODO: once i update soil, but this will check CSV and other soil parameters to see
        # if they are within tolerance range for the individual, this will only set produce to false
        # as if there's no sunlight it doesn't matter if there's a growing medium
        pass
        
    var deficit:float = 0.0
    var deficit_ratio: float = 0.0

    # if nutrients are available and the light is within tolerance range
    if entity.current_chunk.nutrient_level > 0.0 and produce:
        entity.current_chunk.nutrient_level -= _delta * food_source["intake_rate"]
        if entity.current_chunk.nutrient_level < 0.0:
            deficit = entity.current_chunk.nutrient_level
            deficit_ratio = deficit / food_source["intake_rate"]
            entity.current_chunk.nutrient_level = 0

        food_source.