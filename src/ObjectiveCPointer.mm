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
#include "ObjectiveCPointer.hpp"

#include "objc_marshalling.hpp"

#include <godot_cpp/variant/utility_functions.hpp>


namespace objcgdextension {

ObjectiveCPointer::ObjectiveCPointer() {}
ObjectiveCPointer::ObjectiveCPointer(const char *encoded_pointer_type, void *ptr)
		: element_type(encoded_pointer_type), pointer(ptr) {
	NSGetSizeAndAlignment(encoded_pointer_type, &element_size, NULL);
}

void *ObjectiveCPointer::get_pointer(int64_t index) const {
	return ((uint8_t *) pointer) + (index * element_size);
}

bool ObjectiveCPointer::is_null() const {
	return pointer == nullptr;
}

bool ObjectiveCPointer::set_value(const Variant& value, int64_t index) {
	Array string_holder;
	bool success = set_variant(element_type, get_pointer(index), value, string_holder);
	ERR_FAIL_COND_V_MSG(!string_holder.is_empty(), false, "Setting 'char *' with String is not supported, since they need to allocate extra memory.");
	return success;
}

Variant ObjectiveCPointer::get_value(int64_t index) const {
	return get_variant(element_type, get_pointer(index));
}

uint64_t ObjectiveCPointer::get_element_size() const {
	return element_size;
}

String ObjectiveCPointer::get_element_type() const {
	return String::utf8(element_type);
}

ObjectiveCPointer *ObjectiveCPointer::offset(int64_t index) const {
	return memnew(ObjectiveCPointer(element_type, get_pointer(index)));
}

void ObjectiveCPointer::_bind_methods() {
	ClassDB::bind_method(D_METHOD("is_null"), &ObjectiveCPointer::is_null);
	ClassDB::bind_method(D_METHOD("get_element_size"), &ObjectiveCPointer::get_element_size);
	ClassDB::bind_method(D_METHOD("get_element_type"), &ObjectiveCPointer::get_element_type);
	ClassDB::bind_method(D_METHOD("offset", "index"), &ObjectiveCPointer::offset);
	ClassDB::bind_method(D_METHOD("set_value", "value", "index"), &ObjectiveCPointer::set_value, DEFVAL(0));
	ClassDB::bind_method(D_METHOD("get_value", "index"), &ObjectiveCPointer::get_value, DEFVAL(0));
}

String ObjectiveCPointer::_to_string() {
	return UtilityFunctions::str("[ObjectiveCPointer:(^", element_type, ")0x", String::num_uint64((uint64_t) pointer, 16), "]");
}

}
