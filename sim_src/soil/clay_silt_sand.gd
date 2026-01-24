class_name ClaySandSilt
extends Node
#const Soil = preload("res://soil.gd")
#extends Soil

static var tolerance := 3

var clay: int
var silt: int
var sand: int

func _init(input, flag: bool):
    if flag:
        clay = input.clay;
        silt = input.silt;
        sand = input.sand;
    else:
        clay = input[0]
        silt = input[1]
        sand = input[2]

    self.change_by(randi() % tolerance)

func change_by(_amt:int):
    var tmp_array: Array[int] = [clay, silt, sand]

    var negative: bool = bool(randi() & 1)
    var order: Array[int] = [0, 1, 2]
    order.shuffle()

    if negative: _amt *= -1

    var smallest: int = -1 * int(_amt / 2) # warning-ignore:integer_division
    var rest: int = -1 * (_amt - smallest)

    tmp_array[order[0]] += _amt
    tmp_array[order[1]] += smallest
    tmp_array[order[2]] += rest

    clay = tmp_array[0]
    silt = tmp_array[1]
    sand = tmp_array[2]

func _to_string():
    var tmp = ''
    tmp += "clay: " + str(clay) 
    tmp += ", silt: " + str(silt)
    tmp += ", sand: " + str(sand)
    return tmp

func type_string():
    return "ClaySandSilt"
