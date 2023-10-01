extends RefCounted

static var ObjectiveC = Engine.get_singleton("ObjectiveC")


func test_get_class() -> bool:
	var NSObject = ObjectiveC.NSObject
	assert(NSObject != null)
	return true
		
		
func test_class_stringify() -> bool:
	var NSObject = ObjectiveC.NSObject
	assert(str(NSObject) == "NSObject")
	return true


func test_class_get_value() -> bool:
	var NSObject = ObjectiveC.NSObject
	assert(NSObject.description == "NSObject")
	return true


func test_class_set_value() -> bool:
	var NSObject = ObjectiveC.NSObject
	NSObject.version = 3
	assert(NSObject.version == 3)
	return true
