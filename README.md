# Objective-C GDExtension
[![Build and test](https://github.com/gilzoide/objectivec-gdextension/actions/workflows/build.yml/badge.svg)](https://github.com/gilzoide/objectivec-gdextension/actions/workflows/build.yml)

Experimental GDExtension for calling Object-C methods at runtime in Godot 4.1+

**Warning**: misusage may crash the Godot editor and built projects.
Use at your own risk.


## Features
- All calls are made using the Objective-C runtime, so that all classes and methods are available
- Supports macOS, iOS and iOS Simulator builds, as well as the Godot editor running on macOS
- Uses [Key-Value Coding](https://developer.apple.com/documentation/objectivec/nsobject/nskeyvaluecoding) for getting and setting properties.
  Just use the same property names as in Objective-C and you're good to go.
- Automatic reference counting of Objective-C objects, since they are wrapped in `RefCounted` subclasses
- Automatic conversion from Godot data to Objective-C:
  + `String`, `StringName`, `NodePath` -> `NSMutableString`
  + `Array` -> `NSMutableArray`
  + `Dictionary` -> `NSMutableDictionary`
  + `PackedByteArray` -> `NSMutableData`
- Automatic conversion from Objective-C data to Godot:
  + `NSString` -> `String`
  + `NSNumber` -> `bool`, `int` or `float`
- `to_array` method for converting Objective-C objects that support enumeration, like `NSArray` and `NSSet`, to Godot `Array`
- `to_dictionary` method for converting Objective-C objects that support enumeration and the `objectForKey:` message, like `NSDictionary`, to Godot `Dictionary`
- Other useful methods, like `is_kind_of_class`, `responds_to_selector` and `conforms_to_protocol`


## Caveats
- Currently only supports macOS and iOS.
  In multiplatform projects, you must check if you are in a supported platform before trying to use the API.
- This plugin makes its best to check for type compatibility between Godot and Objective-C and catch exceptions when sending messages, but it is possible for crashes to happen if the library is misused.
- For now, there is no support for structs, blocks and pointers in general.


## How to use
```gdscript
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
```
<img src="extras/hello_from_godot.png" height="256" alt="Native macOS alert window showing the message text set via GDScript" />
<img src="extras/hello_from_godot-ios.png" height="256" alt="Native iOS alert window showing the message text set via GDScript" />


## How to install
1. Go to the [Actions](https://github.com/gilzoide/objc-gdextension/actions) tab
2. Open the last successful build, or another successful one that targets the branch/commit you want to use
3. Download the "objc-gdextension" artifact
4. Extract it into your project
5. Open the Godot editor at least once after installing the extension
6. Enjoy 🍾
