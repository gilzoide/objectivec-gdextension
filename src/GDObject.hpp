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
#ifndef __GDOOBJECT_HPP__
#define __GDOOBJECT_HPP__

#include <Foundation/Foundation.h>

#include <godot_cpp/variant/variant.hpp>

using namespace godot;

/**
 * Objective-C object that wraps Godot objects.
 *
 * Messaging this object will forward the calls to the Godot object,
 * removing the last ":" and replacing the other ":" characters for "_".
 */
@interface GDObject : NSObject

+ (instancetype)objectWithObject:(Object *)object;
- (instancetype)initWithObject:(Object *)object;

+ (BOOL)isCompatibleObject:(Object *)object;
+ (String)godotNameForSelector:(SEL)selector;

@end

#endif  // __GDOOBJECT_HPP__
