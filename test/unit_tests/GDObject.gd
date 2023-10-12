extends RefCounted

static var ObjectiveC = Engine.get_singleton("ObjectiveC")

var my_property = 5


func test_property() -> bool:
	var objcObject = ObjectiveC.wrap_object(self)
	assert(objcObject.my_property == my_property)
	assert(objcObject.invoke("my_property") == my_property)
	return true


func test_method() -> bool:
	var objcObject = ObjectiveC.wrap_object(self)
	assert(objcObject.invoke("intToBool:", 1) == true)
	assert(objcObject.invoke("intToBool:", 0) == false)
	return true


func intToBool(value: int) -> bool:
	return bool(value)


func methodSignatureForSelector(sel: String) -> String:
	match sel:
		"my_property":
			return "i@:"
		"intToBool:":
			return "B@:i"
		_:
			return ""
