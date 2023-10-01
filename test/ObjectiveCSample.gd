extends Node

const ALERT_TITLE = "Hello from Godot!"
const ALERT_BODY = "This is a message sponsored by Objective-C GDExtension, enjoy the library!"


func _ready():
	match OS.get_name():
		# Let's show a macOS native alert
		"macOS":
			# 1. Get the Objective-C class by name
			var NSAlert = ObjectiveC.get_class("NSAlert")

			# 2. Alloc and init objects
			var alert = NSAlert.alloc("init")

			# 3. Get and set values normally
			# Note that property names must match Objective-C ones
			alert.messageText = ALERT_TITLE
			alert.informativeText = ALERT_BODY

			# 4. Send messages
			alert.perform_selector("runModal")

		# Ok, let's try again with iOS alerts
		"iOS":
			# 1. Get the Objective-C classes by name
			var UIAlertController = ObjectiveC.get_class("UIAlertController")
			var UIAlertAction = ObjectiveC.get_class("UIAlertAction")
			var UIApplication = ObjectiveC.get_class("UIApplication")

			# 2. Alloc and init objects
			# Some classes provide factory methods to construct objects.
			# Note that Objective-C classes are also regular Objective-C
			# objects, so you can message them as well.
			var alert = UIAlertController.perform_selector("alertControllerWithTitle:message:preferredStyle:", ALERT_TITLE, ALERT_BODY, 1)
			var ok_action = UIAlertAction.perform_selector("actionWithTitle:style:handler:", "Ok", 0, null)
			
			# 3. Getting properties from classes is also supported.
			var view_controller = UIApplication.sharedApplication.delegate.window.rootViewController
			
			# 4. Send messages
			alert.perform_selector("addAction:", ok_action)
			view_controller.perform_selector("presentViewController:animated:completion:", alert, true, null)
		_:
			print("Sorry, alert available on macOS and iOS only")
