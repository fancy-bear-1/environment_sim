class_name S_Roots
extends System

func query():
    return QueryBuilder.new(world).with_all([C_Roots, {C_Growth: {"alive": true}}]).execute()

func _process(_delta):
