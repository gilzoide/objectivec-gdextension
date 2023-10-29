/**
 * Copyright (C) 2023 Gil Barbosa Reis.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the “Software”), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
#include <gdextension-lite/gdextension-lite.h>

#define REGISTER_DUMMY_CLASS(name) \
	{ \
		GDExtensionClassCreationInfo class_info = { \
			.is_abstract = 1, \
		}; \
		GDCLEANUP(godot_StringName) _name = godot_StringName_new_with_latin1_chars(#name); \
		godot_classdb_register_extension_class(p_library, &_name, &Object_str, &class_info); \
	}

static void initialize(void *p_library, GDExtensionInitializationLevel level) {
	if (level != GDEXTENSION_INITIALIZATION_SCENE) {
		return;
	}

	GDCLEANUP(godot_StringName) Object_str = godot_StringName_new_with_latin1_chars("Object");

	REGISTER_DUMMY_CLASS(ObjectiveCObject);
	REGISTER_DUMMY_CLASS(ObjectiveCClass);
	REGISTER_DUMMY_CLASS(ObjectiveCAPI);
	REGISTER_DUMMY_CLASS(ObjectiveCPointer);
}

static void deinitialize(void *p_library, GDExtensionInitializationLevel level) {}

GDExtensionBool objcgdextension_entrypoint(
	const GDExtensionInterfaceGetProcAddress p_getprocaccess,
	GDExtensionClassLibraryPtr p_library,
	GDExtensionInitialization *r_initialization
) {
	gdextension_lite_initialize(p_getprocaccess);
	r_initialization->userdata = p_library;
	r_initialization->initialize = &initialize;
	r_initialization->deinitialize = &deinitialize;
	return 1;
}

