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
#ifndef __OBJC_CONVERSIONS_HPP__
#define __OBJC_CONVERSIONS_HPP__

#include <Foundation/Foundation.h>

#include <godot_cpp/variant/variant.hpp>

using namespace godot;

namespace objcgdextension {

Class class_from_string(const String& string);
Protocol *protocol_from_string(const String& string);
SEL to_selector(const String& string);
String to_string(SEL selector);
String format_selector_call(id obj, const String& selector);

Variant to_variant(NSObject *obj);
Variant to_variant(NSString *string);
Variant to_variant(NSNumber *number);
Variant to_variant(NSArray *array);
Variant to_variant(NSDictionary *dictionary);
Variant to_variant(NSData *data);

NSObject *to_nsobject(const Variant& value);
NSMutableString *to_nsmutablestring(const String& string);
NSNumber *to_nsnumber(bool value);
NSNumber *to_nsnumber(int64_t value);
NSNumber *to_nsnumber(double value);
NSMutableArray *to_nsmutablearray(const Array& array);
NSMutableDictionary *to_nsmutabledictionary(const Dictionary& dictionary);
NSMutableData *to_nsmutabledata(const PackedByteArray& bytes);

}

#endif  // __OBJC_CONVERSIONS_HPP__
