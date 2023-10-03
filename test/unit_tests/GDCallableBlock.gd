extends RefCounted

static var ObjectiveC = Engine.get_singleton("ObjectiveC")

var array_correctly_enumerated = true
var no_args_called = false


func test_array_enumerate() -> bool:
	var array = ObjectiveC.NSArray.alloc("initWithArray:", [0, 1, 2, 3, 4])
	var block = ObjectiveC.create_block("v@q", self.enumerate_block)
	assert(block, "Block is null!")
	array.perform_selector("enumerateObjectsUsingBlock:", block)
	assert(array_correctly_enumerated, "Array was not correctly enumerated")
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


func no_args_method():
	no_args_called = true
