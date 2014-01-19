//
//  JKAutoShirnkInteractiveTransiting.h
//  JKAutoShrinkViewDemo
//
//  Created by Jackie CHEUNG on 14-1-16.
//  Copyright (c) 2014年 Jackie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JKAutoShirnkInteractiveTransiting;

@protocol JKAutoShirnkInteractiveTransitingDelegate <NSObject>
@optional
/* protocol methods below will only be called by navigationBar of the navigationController */
- (void)autoShirnkInteractiveTransiting:(JKAutoShirnkInteractiveTransiting *)transiting willShrinkViewWithPercent:(CGFloat)percentComplete;
- (void)autoShirnkInteractiveTransiting:(JKAutoShirnkInteractiveTransiting *)transiting didShrinkViewWithPercent:(CGFloat)percentComplete;

@end

@interface JKAutoShirnkInteractiveTransiting : NSObject<UINavigationControllerDelegate,UIScrollViewDelegate>

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@property (nonatomic, weak ,readonly) UINavigationController *navigationController;

@end
