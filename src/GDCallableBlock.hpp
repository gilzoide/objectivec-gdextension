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
#ifndef __GDCALLABLE_BLOCK_HPP__
#define __GDCALLABLE_BLOCK_HPP__

#include <Foundation/Foundation.h>

#include <godot_cpp/variant/variant.hpp>

using namespace godot;

/**
 * Object that conforms to the block ABI and forwards block invocations to a Godot Callable.
 *
 * @note The implementations receive a fixed number of arguments as integers,
 * so there are no special registers involved. If you pass this to a block that
 * is invoked with float/double or struct values, your app will likely crash.
 */
@interface GDCallableBlock : NSObject

@property(readonly) NSMethodSignature *signature;

+ (instancetype)blockWithCallable:(const Callable&)callable signature:(NSMethodSignature *)signature;
- (instancetype)initWithCallable:(const Callable&)callable signature:(NSMethodSignature *)signature;

- (void)invokeWithArgs:(const void *)argsBuffer;

@end

#endif  // __GDCALLABLE_BLOCK_HPP__
