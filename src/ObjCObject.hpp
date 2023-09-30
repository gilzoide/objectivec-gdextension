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
#ifndef __OBJC_OBJECT_HPP__
#define __OBJC_OBJECT_HPP__

#include <gdextension_interface.h>
#include <godot_cpp/classes/ref_counted.hpp>

using namespace godot;

namespace objcgdextension::classes {

class NSObject : public RefCounted {
	GDCLASS(NSObject, RefCounted);

public:
	NSObject();
	NSObject(id obj);
	~NSObject();

	id get_obj();
	Variant perform_selector(const Variant **argv, GDExtensionInt argc, GDExtensionCallError& error);
	bool is_kind_of_class(const String& class_name) const;
	bool responds_to_selector(const String& selector) const;
	bool conforms_to_protocol(const String& protocol_name) const;

	Array to_array() const;
	Dictionary to_dictionary() const;

protected:
	static void _bind_methods();

	bool _set(const StringName& name, const Variant& value);
	bool _get(const StringName& name, Variant& r_value);

	String _to_string();

	id obj;
};

}

#endif  // __OBJC_OBJECT_HPP__
