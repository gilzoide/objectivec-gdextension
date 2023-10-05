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
#include "objc_invocation.hpp"

#include "ObjectiveCClass.hpp"
#include "ObjectiveCObject.hpp"
#include "objc_conversions.hpp"
#include "objc_marshalling.hpp"

#include <Foundation/Foundation.h>

#include <gdextension_interface.h>
#include <godot_cpp/core/error_macros.hpp>

namespace objcgdextension {

NSInvocation *prepare_and_invoke(id target, const String& selector, const godot::Variant **argv, GDExtensionInt argc) {
	SEL sel = to_selector(selector);
	ERR_FAIL_COND_V_EDMSG(
		![target respondsToSelector:sel],
		nil,
		String("Invalid call to %s: selector not supported") % format_selector_call(target, selector)
	);

	NSMethodSignature *signature = [target methodSignatureForSelector:sel];
	int expected_argc = signature.numberOfArguments - 2;
	ERR_FAIL_COND_V_MSG(
		expected_argc != argc,
		nil,
		String("Invalid call to %s: expected %d arguments, found %d") % Array::make(format_selector_call(target, selector), expected_argc, argc)
	);

	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.target = target;
	invocation.selector = sel;

	Array string_holder;
	PackedInt64Array args_buffer;
	args_buffer.resize(signature.numberOfArguments);
	uint64_t *buffer = (uint64_t *) args_buffer.ptrw();
	for (int i = 0; i < argc; i++) {
		int arg_number = i + 2;
		const char *type = [signature getArgumentTypeAtIndex:arg_number];
		set_variant(type, buffer, *argv[i], string_holder);
		[invocation setArgument:buffer atIndex:arg_number];
		buffer++;
	}
	[invocation invoke];

	return invocation;
}

id alloc_init(Class cls, const String& init_selector, const Variant **argv, GDExtensionInt argc) {
	@autoreleasepool {
		id instance = [cls alloc];
		NSInvocation *invocation = prepare_and_invoke(instance, init_selector, argv, argc);
		if (invocation) {
			[invocation getReturnValue:&instance];
			return instance;
		}
		else {
			return nil;
		}
	}
}

Variant invoke(id target, const godot::String& selector, const godot::Variant **argv, GDExtensionInt argc) {
	@autoreleasepool {
		NSInvocation *invocation = prepare_and_invoke(target, selector, argv, argc);
		if (invocation) {
			return get_result_variant(invocation);
		}
		else {
			return Variant();
		}
	}
}

}
