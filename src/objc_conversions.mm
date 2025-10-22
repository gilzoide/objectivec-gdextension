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
#include "objc_conversions.hpp"

#include "GDObject.hpp"
#include "ObjectiveCClass.hpp"
#include "ObjectiveCObject.hpp"

#include <Foundation/Foundation.h>
#include <objc/runtime.h>

#include <godot_cpp/core/error_macros.hpp>

namespace objcgdextension {

Class class_from_string(const String& string) {
	CharString chars = string.ascii();
	return objc_getClass(chars.get_data());
}

Protocol *protocol_from_string(const String& string) {
	CharString chars = string.ascii();
	return objc_getProtocol(chars.get_data());
}

SEL to_selector(const String& string) {
	CharString chars = string.ascii();
	return sel_registerName(chars.get_data());
}

String to_string(SEL selector) {
	return String(sel_getName(selector));
}

String format_selector_call(id obj, const String& selector) {
	return String("%s[%s %s]") % Array::make(
		object_isClass(obj) ? "+" : "-",
		object_getClassName(obj),
		selector
	);
}

Variant to_variant(NSObject *obj) {
	if (obj == nil || obj == NSNull.null) {
		return Variant();
	}
	else if (object_isClass(obj)) {
		return memnew(ObjectiveCClass((Class) obj));
	}
	else if ([obj isKindOfClass:NSString.class]) {
		NSString *string = (NSString *) obj;
		return to_variant(string);
	}
	else if ([obj isKindOfClass:NSNumber.class]) {
		NSNumber *number = (NSNumber *) obj;
		return to_variant(number);
	}
	else if ([obj isKindOfClass:GDObject.class]) {
		GDObject *gdobj = (GDObject *) obj;
		return gdobj.variant;
	}
	else {
		return memnew(ObjectiveCObject(obj));
	}
}

Variant to_variant(NSString *string) {
	return string.UTF8String;
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

Variant to_variant(NSArray *array) {
	Array variant;
	for (NSObject *obj in array) {
		variant.append(to_variant(obj));
	}
	return variant;
}

Variant to_variant(NSDictionary *dictionary) {
	Dictionary variant;
	for (NSObject *key in dictionary) {
		variant[to_variant(key)] = to_variant((NSObject *) [dictionary objectForKey:key]);
	}
	return variant;
}

Variant to_variant(NSData *data) {
	PackedByteArray bytes;
	bytes.resize(data.length);
	[data getBytes:bytes.ptrw() length:data.length];
	return bytes;
}

NSObject *to_nsobject(const Variant& value) {
	switch (value.get_type()) {
		case godot::Variant::NIL:
			return nil;

		case godot::Variant::BOOL:
			return to_nsnumber(value.operator bool());

		case godot::Variant::INT:
			return to_nsnumber(value.operator int64_t());

		case godot::Variant::FLOAT:
			return to_nsnumber(value.operator double());

		case godot::Variant::STRING:
		case godot::Variant::STRING_NAME:
		case godot::Variant::NODE_PATH:
			return to_nsmutablestring(value);

		case godot::Variant::ARRAY:
			return to_nsmutablearray(value);

		case godot::Variant::DICTIONARY:
			return to_nsmutabledictionary(value);

		case godot::Variant::PACKED_BYTE_ARRAY:
			return to_nsmutabledata(value);

		case godot::Variant::OBJECT: {
			Object *obj = value;
			if (!obj) {
				return nil;
			}
			else if (auto objc_obj = Object::cast_to<ObjectiveCObject>(obj)) {
				return objc_obj->get_obj();
			}
			else if ([GDObject isCompatibleObject:obj]) {
				return [GDObject objectWithObject:obj retainingReference:NO];
			}
			else {
				ERR_FAIL_V_MSG(nil, String("Conversion from '%s' to NSObject* is not supported.") % obj->get_class());
			}
		}

		case godot::Variant::VECTOR2:
		case godot::Variant::VECTOR2I:
		case godot::Variant::RECT2:
		case godot::Variant::RECT2I:
		case godot::Variant::VECTOR3:
		case godot::Variant::VECTOR3I:
		case godot::Variant::TRANSFORM2D:
		case godot::Variant::VECTOR4:
		case godot::Variant::VECTOR4I:
		case godot::Variant::PLANE:
		case godot::Variant::QUATERNION:
		case godot::Variant::AABB:
		case godot::Variant::BASIS:
		case godot::Variant::TRANSFORM3D:
		case godot::Variant::PROJECTION:
		case godot::Variant::COLOR:
		case godot::Variant::RID:
		case godot::Variant::CALLABLE:
		case godot::Variant::SIGNAL:
		case godot::Variant::PACKED_INT32_ARRAY:
		case godot::Variant::PACKED_INT64_ARRAY:
		case godot::Variant::PACKED_FLOAT32_ARRAY:
		case godot::Variant::PACKED_FLOAT64_ARRAY:
		case godot::Variant::PACKED_STRING_ARRAY:
		case godot::Variant::PACKED_VECTOR2_ARRAY:
		case godot::Variant::PACKED_VECTOR3_ARRAY:
		case godot::Variant::PACKED_COLOR_ARRAY:
		default:
			ERR_FAIL_V_MSG(nil, String("Conversion from '%s' to NSObject* is not supported yet.") % Variant::get_type_name(value.get_type()));
	}
}

NSMutableString *to_nsmutablestring(const godot::String& string) {
	CharString chars = string.utf8();
	return [NSMutableString stringWithUTF8String:chars.get_data()];
}

NSNumber *to_nsnumber(bool value) {
	return [NSNumber numberWithBool:value];
}

NSNumber *to_nsnumber(int64_t value) {
	return [NSNumber numberWithInteger:value];
}

NSNumber *to_nsnumber(double value) {
	return [NSNumber numberWithDouble:value];
}

NSMutableArray *to_nsmutablearray(const Array& array) {
	NSMutableArray *mutable_array = [NSMutableArray arrayWithCapacity:array.size()];
	for (int i = 0; i < array.size(); i++) {
		[mutable_array addObject:to_nsobject(array[i])];
	}
	return mutable_array;
}

NSMutableDictionary *to_nsmutabledictionary(const Dictionary& dictionary) {
	NSMutableDictionary<NSObject *, NSObject *> *mutable_dictionary = [NSMutableDictionary dictionaryWithCapacity:dictionary.size()];
	Array keys = dictionary.keys();
	for (int i = 0; i < keys.size(); i++) {
		Variant key = keys[i];
		Variant value = dictionary[key];
		[mutable_dictionary setObject:to_nsobject(value) forKey:(id<NSCopying>)to_nsobject(key)];
	}
	return mutable_dictionary;
}

NSMutableData *to_nsmutabledata(const PackedByteArray& bytes) {
	return [NSMutableData dataWithBytes:bytes.ptr() length:bytes.size()];
}

}
