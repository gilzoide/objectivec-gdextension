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
#ifndef __OBJECTIVEC_POINTER_HPP__
#define __OBJECTIVEC_POINTER_HPP__

#include <Foundation/Foundation.h>
#include <godot_cpp/classes/ref_counted.hpp>

using namespace godot;

namespace objcgdextension {

class ObjectiveCPointer : public RefCounted {
	GDCLASS(ObjectiveCPointer, RefCounted);

public:
	ObjectiveCPointer();
	ObjectiveCPointer(const char *objc_element_type, void *ptr);

	void *get_pointer(int64_t index = 0) const;
	bool is_null() const;
	uint64_t get_element_size() const;
	String get_element_type() const;

	ObjectiveCPointer *offset(int64_t index) const;

	bool set_value(const Variant& value, int64_t index = 0);
	Variant get_value(int64_t index = 0) const;

protected:
	static void _bind_methods();

	String _to_string();

	void *pointer;
	const char *element_type;
	NSUInteger element_size;
};

}

#endif  // __OBJECTIVEC_POINTER_HPP__
