extends RefCounted

static var ObjectiveC = Engine.get_singleton("ObjectiveC")


func test_construct_types() -> bool:
	var signature = ObjectiveC.NSMethodSignature.invoke("signatureWithObjCTypes:", "v@:")
	assert(signature != null)
	var return_type = signature.invoke("methodReturnType")
	assert(return_type == "v", "Return type is not void")
	var arg1_type = signature.invoke("getArgumentTypeAtIndex:", 0)
	assert(arg1_type == "@", "Argument 0 is not id")
	var arg2_type = signature.invoke("getArgumentTypeAtIndex:", 1)
	assert(arg2_type == ":", "Argument 1 is not SEL")
	return true
