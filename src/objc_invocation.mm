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

#include <Foundation/Foundation.h>

#include <gdextension_interface.h>
#include <godot_cpp/core/error_macros.hpp>

namespace objcgdextension {

/**
 Objective-C type encodings
	c	A char
	i	An int
	s	A short
	l	A longl is treated as a 32-bit quantity on 64-bit programs.
	q	A long long
	C	An unsigned char
	I	An unsigned int
	S	An unsigned short
	L	An unsigned long
	Q	An unsigned long long
	f	A float
	d	A double
	B	A C++ bool or a C99 _Bool
	v	A void
	*	A character string (char *)
	@	An object (whether statically typed or typed id)
	#	A class object (Class)
	:	A method selector (SEL)
	[array type]	An array
	{name=type...}	A structure
	(name=type...)	A union
	bnum	A bit field of num bits
	^type	A pointer to type
 */

template<typename T>
int set_argument(void *buffer, NSInvocation *invocation, int arg_number, const T& value) {
	*((T *) buffer) = value;
	[invocation setArgument:buffer atIndex:arg_number];
	return sizeof(T);
}

int setup_argument(void *buffer, NSInvocation *invocation, int arg_number, const Variant& value) {
	const char *type = [invocation.methodSignature getArgumentTypeAtIndex:arg_number];
	switch (type[0]) {
		case 'B':
		case 'c':
		case 'C':
		case 'i':
		case 'I':
		case 's':
		case 'S':
		case 'l':
		case 'L':
		case 'q':
		case 'Q':
			return set_argument(buffer, invocation, arg_number, (int64_t) value);
		
		case 'f':
		case 'd':
			return set_argument(buffer, invocation, arg_number, (double) value);
		
		case ':': {
			SEL sel = to_selector(value);
			return set_argument(buffer, invocation, arg_number, sel);
		}

		case '@': {
			NSObject *obj = to_nsobject(value);
			return set_argument(buffer, invocation, arg_number, obj);
		}
			
		case '#': {
			if (ObjectiveCClass *gdcls = Object::cast_to<ObjectiveCClass>(value)) {
				return set_argument(buffer, invocation, arg_number, gdcls->get_obj());
			}
			else {
				Class cls = class_from_string(value);
				return set_argument(buffer, invocation, arg_number, cls);
			}
		}

		case '*':
			// TODO: support 'const char *' arguments
		default:
			ERR_FAIL_V_MSG(0, String("Argument with Objective-C encoded type '%s' is not support yet.") % String(type));
	}
	return 0;
}

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

	PackedByteArray buffer_holder;
	buffer_holder.resize(signature.frameLength);
	uint8_t *buffer = buffer_holder.ptrw();
	for (int i = 0; i < argc; i++) {
		buffer += setup_argument(buffer, invocation, i + 2, *argv[i]);
	}
	[invocation invoke];

	return invocation;
}

id alloc_init(Class cls, const String& init_selector, const Variant **argv, GDExtensionInt argc) {
	@autoreleasepool {
		id instance = [cls alloc];
		NSInvocation *invocation = prepare_and_invoke(instance, init_selector, argv, argc);
		[invocation getReturnValue:&instance];
		return instance;
	}
}

Variant invoke(id target, const godot::String& selector, const godot::Variant **argv, GDExtensionInt argc) {
	@autoreleasepool {
		NSInvocation *invocation = prepare_and_invoke(target, selector, argv, argc);
		return result_to_variant(invocation);
	}
}

}
