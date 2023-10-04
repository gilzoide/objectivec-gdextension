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
#include "ObjectiveCClass.hpp"

#include "ObjectiveCObject.hpp"
#include "objc_conversions.hpp"
#include "objc_invocation.hpp"

#include <godot_cpp/core/error_macros.hpp>

namespace objcgdextension {

ObjectiveCClass::ObjectiveCClass() : ObjectiveCObject() {}

ObjectiveCClass::ObjectiveCClass(id obj) : ObjectiveCObject(obj) {}

ObjectiveCObject *ObjectiveCClass::alloc(const Variant **argv, GDExtensionInt argc, GDExtensionCallError& error) {
	ERR_FAIL_COND_V_EDMSG(!obj, nullptr, "ObjectiveCClass is null");
	if (argc < 1) {
		error.error = GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS;
		error.argument = 1;
		return nullptr;
	}

	String init_selector = *argv[0];
	ERR_FAIL_COND_V_MSG(
		!init_selector.begins_with("init"),
		nullptr,
		String("Expected initializer selector to begin with 'init': got '%s'") % init_selector
	);

	id instance = alloc_init(obj, init_selector, argv + 1, argc - 1);
	return memnew(ObjectiveCObject(instance, false));
}

void ObjectiveCClass::_bind_methods() {
	{
		MethodInfo mi("alloc", PropertyInfo(Variant::STRING, "init_selector"));
		ClassDB::bind_vararg_method(METHOD_FLAGS_DEFAULT, "alloc", &ObjectiveCClass::alloc, mi);
	}
}

}
