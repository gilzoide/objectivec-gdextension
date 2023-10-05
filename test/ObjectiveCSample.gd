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
			# 3.1. Get the Objective-C classes by name
			var NSAlert = ObjectiveC.NSAlert
			var NSApplication = ObjectiveC.NSApplication

			# 3.2. Alloc and init objects
			var alert = NSAlert.alloc("init")

			# 3.3. Get and set values normally
			# Note that property names must match the ones in Objective-C.
			# Note also that class properties work just as well.
			alert.messageText = ALERT_TITLE
			alert.informativeText = ALERT_BODY
			var window = NSApplication.sharedApplication.keyWindow

			# 3.4. Create blocks from Callable values
			# Note that you need to specify the Objective-C method signature,
			# since Callables don't have static typing, but blocks to.
			var alert_completion = func(): print("Alert dismissed!")
			var alert_completion_block = ObjectiveC.create_block("v", alert_completion)

			# 3.5. Send messages (a.k.a. invoke methods)
			alert.invoke("beginSheetModalForWindow:completionHandler:", window, alert_completion_block)

		# Ok, let's try again with iOS alerts
		"iOS":
			# 3.1. Get the Objective-C classes by name
			var UIAlertController = ObjectiveC.UIAlertController
			var UIAlertAction = ObjectiveC.UIAlertAction
			var UIApplication = ObjectiveC.UIApplication

			# 3.2. Create blocks from Callable values
			var alert_completion = func(): print("Alert dismissed!")
			var alert_completion_block = ObjectiveC.create_block("v", alert_completion)

			# 3.3. Alloc and init objects
			# Some classes provide factory methods to construct objects.
			# Note that Objective-C classes are also regular Objective-C
			# objects, so you can message them as well.
			var alert = UIAlertController.invoke("alertControllerWithTitle:message:preferredStyle:", ALERT_TITLE, ALERT_BODY, 1)
			var ok_action = UIAlertAction.invoke("actionWithTitle:style:handler:", "Ok", 0, alert_completion_block)

			# 3.4. Get and set values normally
			var view_controller = UIApplication.sharedApplication.delegate.window.rootViewController

			# 3.5. Send messages (a.k.a. invoke methods)
			alert.invoke("addAction:", ok_action)
			view_controller.invoke("presentViewController:animated:completion:", alert, true, null)
