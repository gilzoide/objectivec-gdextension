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
#include "GDCallableBlock.hpp"

#include "objc_invocation.hpp"
#include "NSMethodSignature+ArgumentsFromData.hpp"

#include <array>
#include <objc/NSObjCRuntime.h>
#include <objc/runtime.h>

using namespace objcgdextension;

struct GDCallableBlockDescriptor {
    unsigned long reserved;
    unsigned long size;
};
static GDCallableBlockDescriptor BLOCK_DESCRIPTOR = { 0, class_getInstanceSize(GDCallableBlock.class) };

template<typename... Args>
void invoke_block(GDCallableBlock *block, Args... args) {
	// Objective-C runtime resets `isa` when copying the block, for some reason
	object_setClass(block, GDCallableBlock.class);
	NSMutableData *data = [NSMutableData data];
	([data appendBytes:&args length:sizeof(args)], ...);
	[block invokeWithArgs:data];
}

constexpr std::array<void *, 5> invoke_methods = {
	(void *) &invoke_block<>,
	(void *) &invoke_block<NSUInteger>,
	(void *) &invoke_block<NSUInteger, NSUInteger>,
	(void *) &invoke_block<NSUInteger, NSUInteger, NSUInteger>,
	(void *) &invoke_block<NSUInteger, NSUInteger, NSUInteger, NSUInteger>
};

@implementation GDCallableBlock

+ (instancetype)blockWithCallable:(const Callable&)callable signature:(NSMethodSignature *)signature {
	return [[[self alloc] initWithCallable:callable signature:signature] autorelease];
}

- (instancetype)initWithCallable:(const Callable&)callable signature:(NSMethodSignature *)signature {
	if (self = [super init]) {
		_flags = 0;
		NSUInteger totalSize = signature.totalArgumentSize;
		if (int index = totalSize / invoke_methods.size(); index < invoke_methods.size()) {
			_invoke = invoke_methods[index];
		}
		else {
			@throw [NSException exceptionWithName:@"InvalidSignatureException" reason:@"Too many arguments" userInfo:nil];
		}
		_descriptor = &BLOCK_DESCRIPTOR;
		_callable = callable;
		_signature = signature;
	}
	return self;
}

- (void)invokeWithArgs:(NSData *)argsData {
	Array args = [_signature arrayFromArgumentData:argsData];
	Variant result = _callable.callv(args);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self retain];
}

@end
