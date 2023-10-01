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
  + `String`, `StringName`, `NodePath` -> `NSString`
  + `Array` -> `NSMutableArray`
  + `Dictionary` -> `NSMutableDictionary`
  + `PackedByteArray` -> `NSMutableData`
- Automatic conversion from Objective-C data to Godot:
  + `NSString` -> `String`
  + `NSNumber` -> `bool`, `int` or `float`
- `to_array` method for converting Objective-C objects that conform to `NSFastEnumeration` protocol, like `NSArray` and `NSSet`, to Godot `Array`
- `to_dictionary` method for converting Objective-C objects that conform to `NSFastEnumeration` protocol and support `objectForKey:` message, like `NSDictionary`, to Godot `Dictionary`
- Other useful methods, like `is_kind_of_class`, `responds_to_selector` and `conforms_to_protocol`


## Caveats
- Currently only supports macOS and iOS.
  In multiplatform projects, you must check if you are in a supported platform before trying to use the API.
- This plugin makes its best to check for type compatibility between Godot and Objective-C and catch exceptions when sending messages, but it is possible for crashes to happen if the library is misused.
- For now, there is no support for structs, blocks and pointers in general.


## How to use
```gdscript
extends RefCounted


func _ready():
    if OS.get_name() != "macOS":
        print("Sorry, NSAlert is available in macOS only")
        return

    # 1. Get the Objective-C class by name
    var NSAlert = ObjectiveC.get_class("NSAlert")

    # 2. Alloc and init objects
    var alert = NSAlert.alloc("init")
    
    # 3. Get and set values normally
    #    Note that property names must match Objective-C ones
    alert.messageText = "Hello from Godot!"
    alert.informativeText = "This is a message sponsored by Objective-C GDExtension, enjoy the library!"

    # 4. Send messages
    alert.perform_selector("runModal")
```
<img src="extras/hello_from_godot.png" height="256" alt="Native macOS alert window showing the message text set via GDScript" />


## How to install
1. Go to the [Actions](https://github.com/gilzoide/objc-gdextension/actions) tab
2. Open the last successful build, or another successful one that targets the branch/commit you want to use
3. Download the "objc-gdextension" artifact
4. Extract it into your project
5. Open the Godot editor at least once after installing the extension
6. Enjoy 🍾
