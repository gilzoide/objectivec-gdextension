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
#ifndef __OBJECTIVEC_HPP__
#define __OBJECTIVEC_HPP__

#include <godot_cpp/classes/ref_counted.hpp>

using namespace godot;

namespace objcgdextension {

class ObjectiveCClass;
class ObjectiveCObject;

class ObjectiveCAPI : public RefCounted {
	GDCLASS(ObjectiveCAPI, RefCounted);

public:
	ObjectiveCAPI();

	ObjectiveCClass *find_class(const String& name) const;
	ObjectiveCObject *create_block(const String& objCTypes, const Callable& implementation) const;
	ObjectiveCObject *wrap_object(Object *godot_object, bool retaining_reference = false) const;
	
	static ObjectiveCAPI *get_singleton();

protected:
	static void _bind_methods();

	bool _get(const StringName& name, Variant& r_value);

private:
	static ObjectiveCAPI *instance;
};

}

#endif  // __OBJECTIVEC_HPP__
