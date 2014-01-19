//
//  UIScrollView+JKMultiDelegatesSupport.m
//  JKAutoShrinkViewDemo
//
//  Created by Jackie CHEUNG on 14-1-15.
//  Copyright (c) 2014年 Jackie. All rights reserved.
//

#import "UIScrollView+JKMultiDelegatesSupport.h"
#import "JKMultiDelegateForwarder.h"
#import <objc/runtime.h>

static void class_swizzleSelector(Class class, SEL originalSelector, SEL newSelector)
{
    Method origMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    if(class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

static NSString * JKMultiDelegatesSupportUIScrollViewDelegateProxy;

@implementation UIScrollView (JKMultiDelegatesSupport)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            class_swizzleSelector(self, @selector(setDelegate:), @selector(setDelegate_JKMultiDelegatesSupport:));
        }
    });
}

- (JKMultiDelegateForwarder *)multiDelegateProxy_JK{
    JKMultiDelegateForwarder *proxy = objc_getAssociatedObject(self, &JKMultiDelegatesSupportUIScrollViewDelegateProxy);
    if(!proxy){
        proxy = [[JKMultiDelegateForwarder alloc] init];
        objc_setAssociatedObject(self, &JKMultiDelegatesSupportUIScrollViewDelegateProxy, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return proxy;
}

- (void)setDelegate_JKMultiDelegatesSupport:(id<UIScrollViewDelegate>)delegate{
    if(delegate){
        [self.multiDelegateProxy_JK removeForwardingDelegate:self.delegate];
        [self.multiDelegateProxy_JK addForwardingDelegate:delegate];
    }else{
        [self.multiDelegateProxy_JK removeForwardingDelegate:self.delegate];
    }

    //Set Nil before setting delegate forwarder otherwise scrollView will do nothing if delegate being set is the same.
    [self setDelegate_JKMultiDelegatesSupport:nil];
    [self setDelegate_JKMultiDelegatesSupport:(id<UIScrollViewDelegate>)self.multiDelegateProxy_JK];
}

#pragma mark -
- (void)removeMultiDelegateByDelegateForwarder:(id<UIScrollViewDelegate>)delegate{
    [self.multiDelegateProxy_JK removeForwardingDelegate:delegate];
}

- (void)addMultiDelegateByDelegateForwarder:(id<UIScrollViewDelegate>)delegate{
    [self.multiDelegateProxy_JK addForwardingDelegate:self.delegate];
    [self.multiDelegateProxy_JK addForwardingDelegate:delegate];
    
    [self setDelegate_JKMultiDelegatesSupport:nil];
    [self setDelegate_JKMultiDelegatesSupport:(id<UIScrollViewDelegate>)self.multiDelegateProxy_JK];
}

@end
