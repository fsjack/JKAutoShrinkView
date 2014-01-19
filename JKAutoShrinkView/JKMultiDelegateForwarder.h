//
//  JKMultiDelegateProxy.h
//  JKAutoShrinkViewDemo
//
//  Created by Jackie CHEUNG on 14-1-15.
//  Copyright (c) 2014年 Jackie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKMultiDelegateForwarder : NSObject

- (void)addForwardingDelegate:(id)delegate;

- (void)removeForwardingDelegate:(id)delegate;

@end
