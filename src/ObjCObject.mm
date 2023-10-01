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

namespace objcgdextension {

ObjCObject::ObjCObject() : obj() {}

ObjCObject::ObjCObject(id obj) {
	if (obj) {
		this->obj = [obj retain];
	}
	else {
		obj = nil;
	}
}

ObjCObject::~ObjCObject() {
	if (obj) {
		[obj release];
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

bool ObjCObject::is_kind_of_class(const String& class_name) const {
	Class cls = class_from_string(class_name);
	ERR_FAIL_COND_V_MSG(!cls, false, "Objective-C class not found: " + class_name);
	return [obj isKindOfClass:cls];
}

bool ObjCObject::responds_to_selector(const String& selector) const {
	SEL sel = to_selector(selector);
	ERR_FAIL_COND_V_MSG(!sel, false, "Invalid selector: " + selector);
	return [obj respondsToSelector:sel];
}

bool ObjCObject::conforms_to_protocol(const String& protocol_name) const {
	Protocol *protocol = protocol_from_string(protocol_name);
	ERR_FAIL_COND_V_MSG(!protocol, false, "Invalid protocol: " + protocol_name);
	return [obj conformsToProtocol:protocol];
}

Array ObjCObject::to_array() const {
	if (!obj) {
		return Array();
	}
	@try {
		Array array;
		for (id value in obj) {
			array.append(to_variant((NSObject *) value));
		}
		return array;
	}
	@catch (NSException *ex) {
		ERR_FAIL_V_MSG(Array(), ex.description.UTF8String);
	}
}

Dictionary ObjCObject::to_dictionary() const {
	if (!obj) {
		return Dictionary();
	}
	@try {
		Dictionary dictionary;
		for (id key in obj) {
			id value = [obj objectForKey:key];
			dictionary[to_variant((NSObject *) key)] = to_variant((NSObject *) value);
		}
		return dictionary;
	}
	@catch (NSException *ex) {
		ERR_FAIL_V_MSG(Dictionary(), ex.description.UTF8String);
	}
}

void ObjCObject::_bind_methods() {
	{
		MethodInfo mi("perform_selector", PropertyInfo(Variant::STRING, "selector"));
		ClassDB::bind_vararg_method(METHOD_FLAGS_DEFAULT, "perform_selector", &ObjCObject::perform_selector, mi);
	}
	ClassDB::bind_method(D_METHOD("is_kind_of_class", "class_name"), &ObjCObject::is_kind_of_class);
	ClassDB::bind_method(D_METHOD("responds_to_selector", "selector"), &ObjCObject::responds_to_selector);
	ClassDB::bind_method(D_METHOD("conforms_to_protocol", "protocol_name"), &ObjCObject::conforms_to_protocol);
	ClassDB::bind_method(D_METHOD("to_array"), &ObjCObject::to_array);
	ClassDB::bind_method(D_METHOD("to_dictionary"), &ObjCObject::to_dictionary);
}

bool ObjCObject::_set(const StringName& name, const Variant& value) {
	ERR_FAIL_COND_V_EDMSG(!obj, false, "ObjCObject is null");

	@try {
		NSString *key = to_nsstring(name);
		[obj setValue:to_nsobject(value) forKey:key];
		return true;
	}
	@catch (NSException *ex) {
		ERR_FAIL_V_MSG(false, ex.description.UTF8String);
	}
}

bool ObjCObject::_get(const StringName& name, Variant& r_value) {
	ERR_FAIL_COND_V_EDMSG(!obj, false, "ObjCObject is null");

	@try {
		NSString *key = to_nsstring(name);
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
