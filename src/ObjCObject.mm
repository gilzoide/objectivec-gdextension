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

#include "objc_invocation.hpp"

#include <Foundation/Foundation.h>
#include <objc/runtime.h>

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

Variant ObjCObject::invoke(const String& selector) {
	CharString chars = selector.ascii();
	SEL sel = sel_registerName(chars.get_data());
	if ([obj respondsToSelector:sel]) {
		return perform_selector( obj, sel);
	}
	else {
		ERR_FAIL_V_EDMSG(Variant(), String("Object does not support selector %s") % selector);
	}
}

void ObjCObject::_bind_methods() {
	ClassDB::bind_method(D_METHOD("invoke"), &ObjCObject::invoke);
}

bool ObjCObject::_get(const StringName& name, Variant& r_value) {
	ERR_FAIL_COND_V_EDMSG(!obj, false, "ObjCObject is null");

	CharString chars = ((String) name).ascii();
	SEL selector = sel_registerName(chars.get_data());
	if ([obj respondsToSelector:selector]) {
		r_value = perform_selector(obj, selector);
		return true;
	}
	else {
		return false;
	}
}

String ObjCObject::_to_string() {
	if (obj) {
		return perform_selector(obj, @selector(description));
	}
	else {
		return Variant().stringify();
	}
}

}
