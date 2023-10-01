extends RefCounted


func test_get_class() -> bool:
	var NSObject = ObjectiveC.get_class("NSObject")
	assert(NSObject != null)
	return true
	
	
func test_invalid_class() -> bool:
	var should_be_null = ObjectiveC.get_class("invalid-class-name")
	assert(should_be_null == null)
	return true
		
		
func test_class_stringify() -> bool:
	var NSObject = ObjectiveC.get_class("NSObject")
	assert(str(NSObject) == "NSObject")
	return true


func test_class_get_value() -> bool:
	var NSObject = ObjectiveC.get_class("NSObject")
	assert(NSObject.description == "NSObject")
	return true


func test_class_set_value() -> bool:
	var NSObject = ObjectiveC.get_class("NSObject")
	NSObject.version = 3
	assert(NSObject.version == 3)
	return true
