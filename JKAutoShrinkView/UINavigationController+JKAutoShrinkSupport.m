//
//  UINavigationController+JKAutoShrinkSupport.m
//  JKAutoShrinkViewDemo
//
//  Created by Jackie CHEUNG on 14-1-16.
//  Copyright (c) 2014年 Jackie. All rights reserved.
//

#import "UINavigationController+JKAutoShrinkSupport.h"
#import <objc/runtime.h>
#import "JKMultiDelegateForwarder.h"
#import "JKAutoShrinkNavigationBar.h"
#import "JKAutoShirnkInteractiveTransiting.h"

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

static NSString * JKMultiDelegatesSupportDelegateProxyAssociationKey;
static NSString * JKAutoShrinkSupportAutoNavigationBarShirnkEnabledAssociationKey;
static NSString * JKAutoShrinkSupportAutoToolbarShirnkEnabledAssociationKey;
static NSString * JKAutoShrinkSupportAutoShirnkInteractiveTransitingAssociationKey;

@implementation UINavigationController (JKAutoShrinkSupport)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            class_swizzleSelector(self, @selector(setDelegate:), @selector(setDelegate_JKMultiDelegatesSupport:));
        }
    });
}

- (JKMultiDelegateForwarder *)multiDelegateProxy_JK{
    JKMultiDelegateForwarder *proxy = objc_getAssociatedObject(self, &JKMultiDelegatesSupportDelegateProxyAssociationKey);
    if(!proxy){
        proxy = [[JKMultiDelegateForwarder alloc] init];
        objc_setAssociatedObject(self, &JKMultiDelegatesSupportDelegateProxyAssociationKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return proxy;
}

- (JKAutoShirnkInteractiveTransiting *)autoShirnkInteractiveTransiting_JK{
    JKAutoShirnkInteractiveTransiting *transiting = objc_getAssociatedObject(self, &JKAutoShrinkSupportAutoShirnkInteractiveTransitingAssociationKey);
    if(!transiting){
        transiting = [[JKAutoShirnkInteractiveTransiting alloc] initWithNavigationController:self];
        objc_setAssociatedObject(self, &JKAutoShrinkSupportAutoShirnkInteractiveTransitingAssociationKey, transiting, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return transiting;
}

- (void)setDelegate_JKMultiDelegatesSupport:(id<UINavigationControllerDelegate>)delegate{
    if(delegate){
        [self.multiDelegateProxy_JK removeForwardingDelegate:self.delegate];
        [self.multiDelegateProxy_JK addForwardingDelegate:delegate];
    }else{
        [self.multiDelegateProxy_JK removeForwardingDelegate:self.delegate];
    }
    
    //Set Nil before setting delegate forwarder otherwise scrollView will do nothing if delegate being set is the same.
    [self setDelegate_JKMultiDelegatesSupport:nil];
    [self setDelegate_JKMultiDelegatesSupport:(id<UINavigationControllerDelegate>)self.multiDelegateProxy_JK];
}

#pragma mark -
- (void)setAutoNavigationBarShirnkEnabled:(BOOL)autoNavigationBarShirnkEnabled{
    
    if(![self.navigationBar conformsToProtocol:@protocol(JKAutoShirnkInteractiveTransitingDelegate)]){
        [NSException raise:NSInvalidArgumentException format:@"UINavigationController need to be init with method 'initWithNavigationBarClass:toolbarClass:' and pass a navigationBar that conform to JKAutoShirnkInteractiveTransitingDelegate protocol as argument."];
        return;
    }
    
    if(autoNavigationBarShirnkEnabled && !self.autoToolbarShirnkEnabled){
        [self _setDelegateProxy];
    }else if (!autoNavigationBarShirnkEnabled && !self.autoToolbarShirnkEnabled){
        [self _removeDelegateProxy];
    }
    objc_setAssociatedObject(self, &JKAutoShrinkSupportAutoNavigationBarShirnkEnabledAssociationKey, @(autoNavigationBarShirnkEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)autoNavigationBarShirnkEnabled{
    return [objc_getAssociatedObject(self, &JKAutoShrinkSupportAutoNavigationBarShirnkEnabledAssociationKey) boolValue];
}

- (void)setAutoToolbarShirnkEnabled:(BOOL)autoToolbarShirnkEnabled{
    
    if(![self.navigationBar conformsToProtocol:@protocol(JKAutoShirnkInteractiveTransitingDelegate)]){
        [NSException raise:NSInvalidArgumentException format:@"UINavigationController need to be init with method 'initWithNavigationBarClass:toolbarClass:' and pass a navigationBar that conform to JKAutoShirnkInteractiveTransitingDelegate protocol as argument."];
        return;
    }
    
    if(autoToolbarShirnkEnabled && !self.autoNavigationBarShirnkEnabled){
        [self _setDelegateProxy];
    }else if (!autoToolbarShirnkEnabled && !self.autoNavigationBarShirnkEnabled){
        [self _removeDelegateProxy];
    }
    objc_setAssociatedObject(self, &JKAutoShrinkSupportAutoToolbarShirnkEnabledAssociationKey, @(autoToolbarShirnkEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)autoToolbarShirnkEnabled{
    return [objc_getAssociatedObject(self, &JKAutoShrinkSupportAutoToolbarShirnkEnabledAssociationKey) boolValue];
}

- (void)_setDelegateProxy{
    if ([self multiDelegateProxy_JK] == nil)
        [self.multiDelegateProxy_JK addForwardingDelegate:self.delegate];
    [self.multiDelegateProxy_JK addForwardingDelegate:self.autoShirnkInteractiveTransiting_JK];
    
    [self setDelegate_JKMultiDelegatesSupport:nil];
    [self setDelegate_JKMultiDelegatesSupport:(id<UINavigationControllerDelegate>)self.multiDelegateProxy_JK];
}

- (void)_removeDelegateProxy{
    [self.multiDelegateProxy_JK removeForwardingDelegate:self.autoShirnkInteractiveTransiting_JK];
}

@end
