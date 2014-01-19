//
//  JKMultiDelegateProxy.m
//  JKAutoShrinkViewDemo
//
//  Created by Jackie CHEUNG on 14-1-15.
//  Copyright (c) 2014年 Jackie. All rights reserved.
//

#import "JKMultiDelegateForwarder.h"

@interface JKMultiDelegateForwarder ()
@property (nonatomic, copy) NSArray *forwardingDelegates;
@end

@implementation JKMultiDelegateForwarder
@synthesize forwardingDelegates = _forwardingDelegates;
#pragma mark -
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector{
    NSMethodSignature *signature;
    for (id delegate in self.forwardingDelegates){
        signature = [delegate methodSignatureForSelector:selector];
        if (signature){
            break;
        }
    }
	return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    NSString *returnType = [NSString stringWithCString:invocation.methodSignature.methodReturnType encoding:NSUTF8StringEncoding];
    BOOL voidReturnType = [returnType isEqualToString:@"v"];
    
    for (id delegate in self.forwardingDelegates){
        if ([delegate respondsToSelector:invocation.selector]){
            [invocation invokeWithTarget:delegate];
            if (!voidReturnType){
                return;
            }
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    for (id delegate in self.forwardingDelegates){
        if ([delegate respondsToSelector:aSelector]){
            if ([delegate isKindOfClass:[UITextField class]] && [[UITextField class] instancesRespondToSelector:aSelector]){
                continue;
            }
            return YES;
        }
    }
    return NO;
}

#pragma mark - 
- (NSArray *)forwardingDelegates{
    NSMutableArray *delegatesBuilder = [NSMutableArray arrayWithCapacity:[_forwardingDelegates count]];
    for (NSValue *delegateValue in _forwardingDelegates){
        [delegatesBuilder addObject:[delegateValue nonretainedObjectValue]];
    }
    return [delegatesBuilder copy];
}

- (void)setForwardingDelegates:(NSArray *)forwardingDelegates{
    NSMutableArray *delegatesUnretainedBuilder = [NSMutableArray array];
    for (id delegate in forwardingDelegates){
        [delegatesUnretainedBuilder addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
    _forwardingDelegates = [delegatesUnretainedBuilder copy];
}


#pragma mark -
- (void)addForwardingDelegate:(id)delegate{
    if(delegate) self.forwardingDelegates = [self.forwardingDelegates arrayByAddingObject:delegate];
}

- (void)removeForwardingDelegate:(id)delegate{
    NSMutableArray *forwardingDelegates = [NSMutableArray arrayWithArray:self.forwardingDelegates];
    [forwardingDelegates removeObject:delegate];
    self.forwardingDelegates = forwardingDelegates;
}

@end
