extends RefCounted

static var ObjectiveC = Engine.get_singleton("ObjectiveC")

const ENUMERATE_STOP_COUNT = 2


var array_correctly_enumerated = true
var array_stop_enumeration_count = 0
var no_args_called = false


func test_array_enumerate() -> bool:
	var array = ObjectiveC.NSArray.alloc("initWithArray:", [0, 1, 2, 3, 4])
	var block = ObjectiveC.create_block("v@q", self.enumerate_block)
	assert(block, "Block is null!")
	array.perform_selector("enumerateObjectsUsingBlock:", block)
	assert(array_correctly_enumerated, "Array was not correctly enumerated")
	return true


func test_array_enumeration_stop() -> bool:
	var array = ObjectiveC.NSArray.alloc("initWithArray:", [0, 1, 2, 3, 4])
	var block = ObjectiveC.create_block("v@q^B", self.enumerate_block_stop)
	assert(block, "Block is null!")
	array.perform_selector("enumerateObjectsUsingBlock:", block)
	assert(array_stop_enumeration_count == ENUMERATE_STOP_COUNT, "Array enumeration was not stopped")
	return true


func test_no_args() -> bool:
	var array = ObjectiveC.NSArray.alloc("initWithArray:", [0])
	var block = ObjectiveC.create_block("v", self.no_args_method)
	assert(block, "Block is null!")
	array.perform_selector("enumerateObjectsUsingBlock:", block)
	assert(no_args_called, "Callable with no arguments was not called")
	return true


func enumerate_block(obj, i):
	array_correctly_enumerated = array_correctly_enumerated and obj == i


func enumerate_block_stop(obj, i, stop):
	array_stop_enumeration_count += 1
	if array_stop_enumeration_count == ENUMERATE_STOP_COUNT:
		stop.set_value(true)


func no_args_method():
	no_args_called = true
