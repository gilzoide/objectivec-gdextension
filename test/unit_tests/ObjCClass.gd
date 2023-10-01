extends RefCounted


func test_from_string() -> bool:
	var NSObject = ObjectiveCClass.from_string("NSObject")
	assert(NSObject != null)
	return true
	
	
func test_invalid_class() -> bool:
	var should_be_null = ObjectiveCClass.from_string("invalid-class-name")
	assert(should_be_null == null)
	return true
		
		
func test_class_stringify() -> bool:
	var NSObject = ObjectiveCClass.from_string("NSObject")
	assert(str(NSObject) == "NSObject")
	return true


func test_class_get_value() -> bool:
	var NSObject = ObjectiveCClass.from_string("NSObject")
	assert(NSObject.description == "NSObject")
	return true


func test_class_set_value() -> bool:
	var NSObject = ObjectiveCClass.from_string("NSObject")
	NSObject.version = 3
	assert(NSObject.version == 3)
	return true
