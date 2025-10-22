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
#import "NSMethodSignature+Godot.hpp"

#include "objc_marshalling.hpp"

using namespace objcgdextension;

@implementation NSMethodSignature (Godot)

- (NSUInteger)totalArgumentSize {
	NSUInteger totalSize = 0;
	for (int i = 0; i < self.numberOfArguments; i++) {
		NSUInteger size, align;
		NSGetSizeAndAlignment([self getArgumentTypeAtIndex:i], &size, &align);
		// TODO: consider alignment
		totalSize += size;
	}
	return totalSize;
}

- (String)completeSignature {
	String signature(self.methodReturnType);
	for (int i = 0; i < self.numberOfArguments; i++) {
		signature += [self getArgumentTypeAtIndex:i];
	}
	return signature;
}

- (Array)arrayFromArgumentData:(const void *)data {
	Array args;
	const uint8_t *ptr = (const uint8_t *) data;
	for (int i = 0; i < self.numberOfArguments; i++) {
		const char *type = [self getArgumentTypeAtIndex:i];
		args.append(get_variant(type, ptr));
		NSUInteger size, align;
		NSGetSizeAndAlignment(type, &size, &align);
		// TODO: consider alignment
		ptr += size;
	}
	return args;
}

@end
