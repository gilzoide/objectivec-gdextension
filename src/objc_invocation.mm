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

#include "ObjCObject.hpp"

#include <Foundation/Foundation.h>
#include <objc/runtime.h>

#include <gdextension_interface.h>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/variant/char_string.hpp>

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

SEL to_selector(const godot::String& string) {
	CharString chars = string.ascii();
	return sel_registerName(chars.get_data());
}

NSString *nsstring_with_string(const godot::String& string) {
	CharString chars = string.utf8();
	return [NSString stringWithUTF8String:chars.get_data()];
}

Variant to_variant(NSObject *obj) {
	if (obj == nil) {
		return Variant();
	}
	else if ([obj isKindOfClass:NSString.class]) {
		NSString *string = (NSString *) obj;
		return to_variant(string);
	}
	else if ([obj isKindOfClass:NSNumber.class]) {
		NSNumber *number = (NSNumber *) obj;
		return to_variant(number);
	}
	else {
		return memnew(ObjCObject(obj));
	}
}

Variant to_variant(NSString *string) {
	return [string UTF8String];
}

Variant to_variant(NSNumber *number) {
	switch (number.objCType[0]) {
		case 'B':
			return (bool) number.boolValue;

		case 'c':
		case 'C': {
			char c = number.charValue;
			if (c == 0 || c == 1) {
				return (bool) c;
			}
			// fallthrough
		}
		case 'i':
		case 's':
		case 'l':
		case 'q':
			return (int64_t) number.longValue;
		
		case 'I':
		case 'S':
		case 'L':
		case 'Q':
			return (uint64_t) number.unsignedLongValue;
		
		case 'f':
			return number.floatValue;

		case 'd':
			return number.doubleValue;
		
		default:
			ERR_FAIL_V_EDMSG(Variant(), String("NSNumber objCType '%s' is not valid") % String(number.objCType));
	}
}

template<typename TIn, typename TOut>
Variant to_variant(NSInvocation *invoked_invocation) {
	TIn value;
	[invoked_invocation getReturnValue:&value];
	return (TOut) value;
}

String format_selector_call(id obj, const String& selector) {
	return String("%s[%s %s]") % Array::make(
		object_isClass(obj) ? "+" : "-",
		object_getClassName(obj),
		selector
	);
}

Variant invoke(id obj, const godot::String& selector, const godot::Variant **argv, GDExtensionInt argc) {
	SEL sel = to_selector(selector);
	ERR_FAIL_COND_V_EDMSG(
		![obj respondsToSelector:sel],
		Variant(),
		String("Invalid call to %s: selector not supported") % format_selector_call(obj, selector)
	);

	NSMethodSignature *signature = [obj methodSignatureForSelector:sel];
	int expected_argc = signature.numberOfArguments - 2;
	ERR_FAIL_COND_V_MSG(
		expected_argc != argc,
		Variant(),
		String("Invalid call to %s: expected %d arguments, found %d") % Array::make(format_selector_call(obj, selector), expected_argc, argc)
	);

	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.target = obj;
	invocation.selector = sel;
	
	// for (int i = 0; i < args.size(); i++) {}
	
	[invocation invoke];

	const char *return_type = signature.methodReturnType;
	switch (return_type[0]) {
		case 'B':
			return to_variant<bool, bool>(invocation);

		case 'c': {
			char c;
			[invocation getReturnValue:&c];
			if (c == 0 || c == 1) {
				return (bool) c;
			}
			else {
				return String::utf8(&c, 1);
			}
		}
		case 'i':
			return to_variant<int, int64_t>(invocation);
		case 's':
			return to_variant<short, int64_t>(invocation);
		case 'l':
			return to_variant<long, int64_t>(invocation);
		case 'q':
			return to_variant<long long, int64_t>(invocation);

		case 'C':
			return to_variant<unsigned char, int64_t>(invocation);
		case 'I':
			return to_variant<unsigned int, uint64_t>(invocation);
		case 'S':
			return to_variant<unsigned short, uint64_t>(invocation);
		case 'L':
			return to_variant<unsigned long, uint64_t>(invocation);
		case 'Q':
			return to_variant<unsigned long long, uint64_t>(invocation);
		
		case '@': {
			NSObject *result;
			[invocation getReturnValue:&result];
			return to_variant(result);
		}

		case 'v':
			return Variant();

		default:
			ERR_FAIL_V_EDMSG(Variant(), String("Return value with Objective-C encoded type '%s' is not valid yet") % String(return_type));
	}
}

}
