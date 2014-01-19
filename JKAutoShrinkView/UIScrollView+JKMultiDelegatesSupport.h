//
//  UIScrollView+JKMultiDelegatesSupport.h
//  JKAutoShrinkViewDemo
//
//  Created by Jackie CHEUNG on 14-1-15.
//  Copyright (c) 2014年 Jackie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JKMultiDelegateForwarder;
@interface UIScrollView (JKMultiDelegatesSupport)

- (void)addMultiDelegateByDelegateForwarder:(id<UIScrollViewDelegate>)delegate;
- (void)removeMultiDelegateByDelegateForwarder:(id<UIScrollViewDelegate>)delegate;

@end
