extends Control

const ALERT_TITLE = "Hello from Godot!"
const ALERT_BODY = "This is a message sponsored by Objective-C GDExtension, enjoy the library!"


func _ready():
	if not OS.get_name() in ["macOS", "iOS"]:
		print("Sorry, NSAlert and UIAlert are available in macOS and iOS only")
		$AlertButton.disabled = true
		return


func _on_alert_button_pressed():
	match OS.get_name():
		"macOS":
			var alert = ObjCClass.from_string("NSAlert").alloc("init")
			alert.messageText = ALERT_TITLE
			alert.informativeText = ALERT_BODY
			alert.perform_selector("runModal")
		"iOS":
			var UIAlertController = ObjCClass.from_string("UIAlertController")
			var UIAlertAction = ObjCClass.from_string("UIAlertAction")
			var alert = UIAlertController.perform_selector("alertControllerWithTitle:message:preferredStyle:", ALERT_TITLE, ALERT_BODY, 0)
			alert.perform_selector("addAction:", UIAlertAction.perform_selector("actionWithTitle:style:handler:", "Ok", 0, null))
			var view_controller = ObjCClass.from_string("UIApplication").sharedApplication.delegate.window.rootViewController
			view_controller.perform_selector("presentViewController:animated:completion:", alert, true, null)
		_:
			assert(false, "Alert is only supported in macOS and iOS")
	
