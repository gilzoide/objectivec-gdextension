extends RefCounted

static var ObjectiveC = Engine.get_singleton("ObjectiveC")
const NOTIFICATION_NAME = "my cool notification"
const NOTIFICATION_USER_INFO = { hello = "world" }

var my_property = 5
var notification_called = false
var self_objc = ObjectiveC.wrap_object(self)


func test_property() -> bool:
	assert(self_objc.my_property == my_property)
	assert(self_objc.responds_to_selector("my_property"))
	assert(self_objc.invoke("my_property") == my_property)
	return true


func test_method() -> bool:
	assert(self_objc.responds_to_selector("intToBool:"))
	assert(self_objc.invoke("intToBool:", 1) == true)
	assert(self_objc.invoke("intToBool:", 0) == false)
	return true


func test_notification() -> bool:
	var NSNotificationCenter = ObjectiveC.NSNotificationCenter.defaultCenter
	NSNotificationCenter.invoke("addObserver:selector:name:object:", self_objc, "handleNotification:", NOTIFICATION_NAME, null)
	NSNotificationCenter.invoke("postNotificationName:object:userInfo:", NOTIFICATION_NAME, null, NOTIFICATION_USER_INFO)
	NSNotificationCenter.invoke("removeObserver:", self_objc)
	assert(notification_called, "Notification was not called")
	return true


func intToBool(value: int) -> bool:
	return bool(value)


func handleNotification(notification):
	assert(notification.name == NOTIFICATION_NAME)
	assert(notification.userInfo.to_dictionary() == NOTIFICATION_USER_INFO)
	notification_called = true


func methodSignatureForSelector(sel: String) -> String:
	match sel:
		"my_property":
			return "i@:"
		"intToBool:":
			return "B@:i"
		"handleNotification:":
			return "v@:@"
		_:
			return ""
