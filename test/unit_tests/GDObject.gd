extends RefCounted

static var ObjectiveC = Engine.get_singleton("ObjectiveC")

var my_property = 5


func test_property() -> bool:
	var objcObject = ObjectiveC.wrap_object(self)
	assert(objcObject.my_property == my_property)
	assert(objcObject.invoke("my_property") == my_property)
	return true


func methodSignatureForSelector(sel: String) -> String:
	match sel:
		"my_property":
			return "i@:"
		_:
			return ""
