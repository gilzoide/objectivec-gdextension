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
#ifndef __OBJC_MARSHALLING_HPP__
#define __OBJC_MARSHALLING_HPP__

#include <Foundation/Foundation.h>
#include <godot_cpp/variant/variant.hpp>

using namespace godot;

namespace objcgdextension {

Variant get_variant(const char *objc_type, const void *buffer);
Variant get_result_variant(NSInvocation *invocation);
Variant get_argument_variant(NSInvocation *invocation, NSUInteger index);
bool set_variant(const char *objc_type, void *buffer, const Variant& value, Array& string_holder);
bool set_result_variant(NSInvocation *invocation, const Variant& value, Array& string_holder);

}

#endif  // __OBJC_MARSHALLING_HPP__
