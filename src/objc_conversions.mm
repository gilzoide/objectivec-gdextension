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
#include "objc_conversions.hpp"

#include "ObjCObject.hpp"
#include "ObjCClass.hpp"

#include <objc/runtime.h>

namespace objcgdextension {

Class class_from_string(const String& string) {
	CharString chars = string.ascii();
	return objc_getClass(chars.get_data());
}

SEL to_selector(const godot::String& string) {
	CharString chars = string.ascii();
	return sel_registerName(chars.get_data());
}

NSString *nsstring_with_string(const godot::String& string) {
	CharString chars = string.utf8();
	return [NSString stringWithUTF8String:chars.get_data()];
}

String format_selector_call(id obj, const String& selector) {
	return String("%s[%s %s]") % Array::make(
		object_isClass(obj) ? "+" : "-",
		object_getClassName(obj),
		selector
	);
}

Variant to_variant(NSObject *obj) {
	if (obj == nil) {
		return Variant();
	}
	else if (object_isClass(obj)) {
		return memnew(ObjCClass(obj));
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

}
