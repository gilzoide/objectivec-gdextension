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
#include "GDObject.hpp"

#import "NSMethodSignature+ArgumentsFromData.hpp"
#import "objc_conversions.hpp"
#import "objc_marshalling.hpp"

#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/classes/ref_counted.hpp>

using namespace objcgdextension;

@implementation GDObject {
	Object *_obj;
}

+ (instancetype)objectWithObject:(Object *)object {
	return [[[self alloc] initWithObject:object] autorelease];
}

- (instancetype)initWithObject:(Object *)object {
	if (self = [super init]) {
		_obj = object;
		if (RefCounted *ref = Object::cast_to<RefCounted>(object)) {
			ref->reference();
		}
	}
	return self;
}

- (void)dealloc {
	if (RefCounted *ref = Object::cast_to<RefCounted>(_obj)) {
		ref->unreference();
	}
	[super dealloc];
}

- (instancetype)copyWithZone:(NSZone *)zone {
	return [self retain];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	@try {
		if (_obj) {
			String methodSignature = _obj->call("methodSignatureForSelector", to_string(aSelector));
			if (!methodSignature.is_empty()) {
				return [NSMethodSignature signatureWithObjCTypes:methodSignature.ascii().get_data()];
			}
		}
	}
	@catch (NSException *ex) {
		ERR_PRINT(ex.description.UTF8String);
	}
	return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	String methodName = [GDObject godotNameForSelector:anInvocation.selector];
	if (_obj) {
		if (_obj->has_method(methodName)) {
			Array args = [anInvocation.methodSignature arrayFromInvocationArguments:anInvocation];
			Variant result = _obj->callv(methodName, args);
			set_result_variant(anInvocation, result, args);
			return;
		}
		else if (anInvocation.methodSignature.numberOfArguments == 0) {
			Variant property = _obj->get(methodName);
			Array string_holder;
			set_result_variant(anInvocation, property, string_holder);
			return;
		}
	}
	[super forwardInvocation:anInvocation];
}

- (Variant)variant {
	return Variant(_obj);
}

+ (BOOL)isCompatibleObject:(Object *)object {
	if (object) {
		return object->has_method("methodSignatureForSelector");
	}
	else {
		return NO;
	}
}

+ (String)godotNameForSelector:(SEL)selector {
	if (selector) {
		return String(sel_getName(selector))
			.trim_suffix(":")
			.replace(":", "_");
	}
	else {
		return "";
	}
}

@end
