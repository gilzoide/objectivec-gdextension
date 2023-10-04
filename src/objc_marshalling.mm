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
#include "objc_marshalling.hpp"

#include "ObjectiveCClass.hpp"
#include "objc_conversions.hpp"

namespace objcgdextension {

/**
 Objective-C type encodings (Reference: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100)
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

 Objective-C method encodings
	r	const
	n	in
	N	inout
	o	out
	O	bycopy
	R	byref
	V	oneway
 */

inline BOOL is_method_encoding(char c) {
	return c == 'r'
		|| c == 'n'
		|| c == 'N'
		|| c == 'o'
		|| c == 'O'
		|| c == 'R'
		|| c == 'V';
}
const char *skip_method_encodings(const char *type) {
	while (is_method_encoding(type[0])) {
		type++;
	}
	return type;
}

template<typename T>
T deref_as(const void *buffer) {
	return *static_cast<const T *>(buffer);
}

template<typename T>
T deref_as(NSInvocation *invocation) {
	T value;
	[invocation getReturnValue:&value];
	return value;
}

template<typename TDeref>
Variant get_variant(const char *objc_type, TDeref buffer) {
	objc_type = skip_method_encodings(objc_type);
	switch (objc_type[0]) {
		case 'B':
			return deref_as<bool>(buffer);

		case 'c': {
			char c = deref_as<char>(buffer);
			if (c == 0 || c == 1) {
				return (bool) c;
			}
			else {
				return String::utf8(&c, 1);
			}
		}
		case 'i':
			return (int64_t) deref_as<int>(buffer);
		case 's':
			return (int64_t) deref_as<short>(buffer);
		case 'l':
			return (int64_t) deref_as<long>(buffer);
		case 'q':
			return (int64_t) deref_as<long long>(buffer);

		case 'C':
			return (uint64_t) deref_as<unsigned char>(buffer);
		case 'I':
			return (uint64_t) deref_as<unsigned int>(buffer);
		case 'S':
			return (uint64_t) deref_as<unsigned short>(buffer);
		case 'L':
			return (uint64_t) deref_as<unsigned long>(buffer);
		case 'Q':
			return (uint64_t) deref_as<unsigned long long>(buffer);
		
		case '*':
			return deref_as<const char *>(buffer);
		
		case '@': {
			NSObject *obj = deref_as<NSObject *>(buffer);
			return to_variant(obj);
		}

		case '#': {
			Class cls = deref_as<Class>(buffer);
			return memnew(ObjectiveCClass(cls));
		}

		case ':': {
			SEL sel = deref_as<SEL>(buffer);
			return sel_getName(sel);
		}

		case 'v':
			return Variant();

		default:
			ERR_FAIL_V_EDMSG(Variant(), String("Value with Objective-C encoded type '%s' is not supported yet") % String(objc_type));
	}
}

Variant get_variant(const char *objc_type, const void *buffer) {
	return get_variant<const void *>(objc_type, buffer);
}

Variant get_result_variant(NSInvocation *invocation) {
	return get_variant<NSInvocation *>(invocation.methodSignature.methodReturnType, invocation);
}

template<typename T>
void set_value(void *buffer, const T& value) {
	*static_cast<T *>(buffer) = value;
}

void set_variant(const char *objc_type, void *buffer, const Variant& value, Array& string_holder) {
	objc_type = skip_method_encodings(objc_type);
	switch (objc_type[0]) {
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
			return set_value(buffer, (int64_t) value);
		
		case 'f':
		case 'd':
			return set_value(buffer, (double) value);
		
		case ':': {
			SEL sel = to_selector(value);
			return set_value(buffer, sel);
		}

		case '@': {
			NSObject *obj = to_nsobject(value);
			return set_value(buffer, obj);
		}
			
		case '#': {
			if (ObjectiveCClass *gdcls = Object::cast_to<ObjectiveCClass>(value)) {
				return set_value(buffer, gdcls->get_obj());
			}
			else {
				Class cls = class_from_string(value);
				return set_value(buffer, cls);
			}
		}

		case '*': {
			PackedByteArray chars;
			if (value.get_type() == Variant::PACKED_BYTE_ARRAY) {
				chars = value;
			}
			else {
				chars = value.stringify().to_utf8_buffer();
				chars.append(0);
				string_holder.append(chars);
			}
			return set_value(buffer, chars.ptr());
		}

		default:
			ERR_FAIL_MSG(String("Argument with Objective-C encoded type '%s' is not support yet.") % String(objc_type));
	}
}

}
