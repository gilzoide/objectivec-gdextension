/**
 * Copyright (C) 2023-2025 Gil Barbosa Reis.
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
#include "ObjectiveCAPI.hpp"

#include "GDObject.hpp"
#include "GDCallableBlock.hpp"
#include "ObjectiveCClass.hpp"
#include "ObjectiveCObject.hpp"
#include "objc_conversions.hpp"

#include <Foundation/Foundation.h>

#include <godot_cpp/core/error_macros.hpp>

namespace objcgdextension {

ObjectiveCAPI *ObjectiveCAPI::instance;

ObjectiveCAPI::ObjectiveCAPI() {
	ERR_FAIL_COND(instance != nullptr);
	instance = this;
}

ObjectiveCClass *ObjectiveCAPI::find_class(const String& name) const {
	Class cls = class_from_string(name);
	if (cls) {
		return memnew(ObjectiveCClass(cls));
	}
	else {
		return nullptr;
	}
}

ObjectiveCObject *ObjectiveCAPI::create_block(const String& objCTypes, const Callable& implementation) const {
	@try {
		NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:objCTypes.ascii().get_data()];
		return memnew(ObjectiveCObject([GDCallableBlock blockWithCallable:implementation signature:signature]));
	}
	@catch (NSException *ex) {
		ERR_FAIL_V_MSG(NULL, String("Invalid Objective-C type encoding '%s': %s") % Array::make(objCTypes, String(ex.description.UTF8String)));
	}
}

ObjectiveCObject *ObjectiveCAPI::wrap_object(Object *godot_object, bool retaining_reference) const {
	ERR_FAIL_COND_V_MSG(![GDObject isCompatibleObject:godot_object], nullptr, "Object must implement 'func methodSignatureForSelector(String) -> String'");
	return memnew(ObjectiveCObject([[GDObject alloc] initWithObject:godot_object retainingReference:retaining_reference], false));
}

ObjectiveCAPI *ObjectiveCAPI::get_singleton() {
	return instance;
}

void ObjectiveCAPI::_bind_methods() {
	ClassDB::bind_method(D_METHOD("find_class", "name"), &ObjectiveCAPI::find_class);
	ClassDB::bind_method(D_METHOD("create_block",  "objc_types", "implementation"), &ObjectiveCAPI::create_block);
	ClassDB::bind_method(D_METHOD("wrap_object",  "object", "retaining_reference"), &ObjectiveCAPI::wrap_object, DEFVAL(false));
}

bool ObjectiveCAPI::_get(const StringName& name, Variant& r_value) {
	auto cls = find_class(name);
	if (cls) {
		r_value = cls;
		return true;
	}
	else {
		return false;
	}
}

}
