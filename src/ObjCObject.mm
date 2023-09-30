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
#include "ObjCObject.hpp"

#include "objc_conversions.hpp"
#include "objc_invocation.hpp"

#include <Foundation/Foundation.h>
#include <objc/runtime.h>

#include <gdextension_interface.h>
#include <godot_cpp/core/error_macros.hpp>

extern "C" id objc_retain(id);
extern "C" void objc_release(id);

namespace objcgdextension {

ObjCObject::ObjCObject() : obj() {}

ObjCObject::ObjCObject(id obj) {
	if (obj) {
		this->obj = objc_retain(obj);
	}
	else {
		obj = nil;
	}
}

ObjCObject::~ObjCObject() {
	if (obj) {
		objc_release(obj);
	}
}

id ObjCObject::get_obj() {
	return obj;
}

Variant ObjCObject::perform_selector(const Variant **argv, GDExtensionInt argc, GDExtensionCallError& error) {
	ERR_FAIL_COND_V_EDMSG(!obj, Variant(), "ObjCObject is null");
	if (argc < 1) {
		error.error = GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS;
		error.argument = 1;
		return Variant();
	}
	@try {
		return invoke(obj, String(*argv[0]), argv + 1, argc - 1);
	}
	@catch (NSException *ex) {
		ERR_FAIL_V_MSG(Variant(), ex.description.UTF8String);
	}
}

void ObjCObject::_bind_methods() {
	{
		MethodInfo mi("perform_selector", PropertyInfo(Variant::STRING, "selector"));
		ClassDB::bind_vararg_method(METHOD_FLAGS_DEFAULT, "perform_selector", &ObjCObject::perform_selector, mi);
	}
}

bool ObjCObject::_get(const StringName& name, Variant& r_value) {
	ERR_FAIL_COND_V_EDMSG(!obj, false, "ObjCObject is null");

	@try {
		NSString *key = nsstring_with_string(name);
		r_value = to_variant((NSObject *) [obj valueForKey:key]);
		return true;
	}
	@catch (NSException *ex) {
		ERR_FAIL_V_MSG(false, ex.description.UTF8String);
	}
}

String ObjCObject::_to_string() {
	if (obj) {
		return [obj description].UTF8String;
	}
	else {
		return Variant().stringify();
	}
}

}
