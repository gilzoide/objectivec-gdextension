extends Node

const ALERT_TITLE = "Hello from Godot!"
const ALERT_BODY = "This is a message sponsored by Objective-C GDExtension, enjoy the library!"


func _ready():
	# 1. Check for availability
	if not Engine.has_singleton("ObjectiveC"):
		print("Sorry, ObjectiveC is available on macOS and iOS only")
		return

	# 2. Get the ObjectiveC singleton
	var ObjectiveC = Engine.get_singleton("ObjectiveC")

	match OS.get_name():
		# Let's show a macOS native alert
		"macOS":
			# 3.1. Get the Objective-C class by name
			var NSAlert = ObjectiveC.NSAlert

			# 3.2. Alloc and init objects
			var alert = NSAlert.alloc("init")

			# 3.3. Get and set values normally
			# Note that property names must match Objective-C ones
			alert.messageText = ALERT_TITLE
			alert.informativeText = ALERT_BODY

			# 3.4. Send messages
			alert.perform_selector("runModal")

		# Ok, let's try again with iOS alerts
		"iOS":
			# 3.1. Get the Objective-C classes by name
			var UIAlertController = ObjectiveC.UIAlertController
			var UIAlertAction = ObjectiveC.UIAlertAction
			var UIApplication = ObjectiveC.UIApplication

			# 3.2. Alloc and init objects
			# Some classes provide factory methods to construct objects.
			# Note that Objective-C classes are also regular Objective-C
			# objects, so you can message them as well.
			var alert = UIAlertController.perform_selector("alertControllerWithTitle:message:preferredStyle:", ALERT_TITLE, ALERT_BODY, 1)
			var ok_action = UIAlertAction.perform_selector("actionWithTitle:style:handler:", "Ok", 0, null)

			# 3.3. Get and set values normally
			# Classes are also supported, since they are also objects.
			var view_controller = UIApplication.sharedApplication.delegate.window.rootViewController

			# 3.4. Send messages
			alert.perform_selector("addAction:", ok_action)
			view_controller.perform_selector("presentViewController:animated:completion:", alert, true, null)
