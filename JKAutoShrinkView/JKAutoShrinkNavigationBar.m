//
//  JKAutoShrinkNavigationBar.m
//  JKAutoShrinkNavigationBarDemo
//
//  Created by Jackie CHEUNG on 14-1-13.
//  Copyright (c) 2014年 Jackie. All rights reserved.
//

#import "JKAutoShrinkNavigationBar.h"
#import "UIScrollView+JKMultiDelegatesSupport.h"
#import "JKAutoShirnkInteractiveTransiting.h"

static CGFloat const _JKAutoShrinkNavigationItemiewFadeAnimationDuration = 0.3;

@interface JKAutoShrinkNavigationBar ()<JKAutoShirnkInteractiveTransitingDelegate>
@property (nonatomic) BOOL isShrinking;

@property (nonatomic, readonly) NSArray *leftBarButtonViews;
@property (nonatomic, readonly) NSArray *rightBarButtonViews;

@property (nonatomic, readonly) UIView *internalTitleView;
@property (nonatomic, readonly) UIView *backBarButtonView;

@property (nonatomic, readonly) UIView *defaultTitleView;
@end

@implementation JKAutoShrinkNavigationBar

#pragma mark - Property
- (UIView *)internalTitleView{
    UINavigationItem *topNavigationitem = self.items.lastObject;
    UIView *titleView = topNavigationitem.titleView;
    
    if(titleView)
        return titleView;
    else
        return self.defaultTitleView;;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if ([self.subviews count] > 0) {
        UIView *view = [self subviews][0];
        CGRect viewFrame = [view frame];
        if (viewFrame.size.height < frame.size.height + 20.0) {
            viewFrame.origin.y = -20.0;
            viewFrame.size.height = 20.0 + frame.size.height;
        }
        [view setFrame:viewFrame];
    }
}

- (void) setCenter:(CGPoint)center
{
    if (center.y < 42) {
        center.y = 42;
    }
    [super setCenter:center];
    
    if ([self.subviews count] > 0) {
        UIView *view = [self subviews][0];
        CGRect frame = [view frame];
        if (frame.size.height < 64.0)
            frame.size.height = 64.0;
        [view setFrame:frame];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.subviews count] > 0) {
            UIView *view = [self subviews][0];
            CGRect frame = [view frame];
            if (frame.size.height < 64.0) {
                frame.origin.y = -20.0;
                frame.size.height = 64.0;
            }
            [view setFrame:frame];
        }
    });
}

- (NSArray *)leftBarButtonViews{
    UINavigationItem *topNavigationitem = self.items.lastObject;
    NSArray *leftBarButtonitems = topNavigationitem.leftBarButtonItems;
    NSMutableArray *leftBarButtonViews = [NSMutableArray arrayWithCapacity:leftBarButtonitems.count];
    for (UIBarButtonItem *barButtonItem in leftBarButtonitems) {
        UIView *barButtonView = [barButtonItem valueForKey:@"_view"];
        [leftBarButtonViews addObject:barButtonView];
    }
    
    UIView *backBarButtonView = self.backBarButtonView;
    if(backBarButtonView) [leftBarButtonViews addObject:backBarButtonView];
    
    return [leftBarButtonViews copy];
}

- (NSArray *)rightBarButtonViews{
    UINavigationItem *topNavigationitem = self.items.lastObject;
    NSArray *leftBarButtonitems = topNavigationitem.rightBarButtonItems;
    NSMutableArray *leftBarButtonViews = [NSMutableArray arrayWithCapacity:leftBarButtonitems.count];
    for (UIBarButtonItem *barButtonItem in leftBarButtonitems) {
        UIView *barButtonView = [barButtonItem valueForKey:@"_view"];
        [leftBarButtonViews addObject:barButtonView];
    }
    
    return [leftBarButtonViews copy];
}

- (UIView *)defaultTitleView{
    UINavigationItem *topNavigationitem = self.items.lastObject;
    return [topNavigationitem valueForKey:@"_defaultTitleView"];
}

- (UIView *)backBarButtonView{
    UINavigationItem *topNavigationitem = self.items.lastObject;
    UIBarButtonItem *backButtonItem = topNavigationitem.backBarButtonItem;
    return [backButtonItem valueForKey:@"_view"];
}

#pragma mark - Private Methods
- (void)shrinkNavigationBarItemViewWithPercent:(CGFloat)percentComplete{
    
    CGFloat alphaRatio = (percentComplete < (1.0f - _JKAutoShrinkNavigationItemiewFadeAnimationDuration)) ? 0.0f : ((percentComplete - (1.0f - _JKAutoShrinkNavigationItemiewFadeAnimationDuration)) * (1.0f/_JKAutoShrinkNavigationItemiewFadeAnimationDuration) );
    CGFloat transformScaleRatio = percentComplete;
    
    {
        self.internalTitleView.center = CGPointMake( self.internalTitleView.center.x , CGRectGetMinY(self.internalTitleView.frame) );
        self.internalTitleView.layer.anchorPoint = CGPointMake( 0.5f , 0.0f );
        self.internalTitleView.transform = CGAffineTransformMakeScale( transformScaleRatio, transformScaleRatio );
        self.internalTitleView.alpha = alphaRatio;
    }
    
    {
        for (UIView *subview in self.leftBarButtonViews) {
            subview.center = CGPointMake(CGRectGetMinX(subview.frame), CGRectGetMinY(subview.frame));
            subview.layer.anchorPoint = CGPointZero;
            subview.transform = CGAffineTransformMakeScale( transformScaleRatio, transformScaleRatio );
            subview.alpha = alphaRatio;
        }
        
        for (UIView *subview in self.rightBarButtonViews) {
            subview.center = CGPointMake(CGRectGetMaxX(subview.frame), CGRectGetMinY(subview.frame) );
            subview.layer.anchorPoint = CGPointMake( 1.0f , 0.0f );
            subview.transform = CGAffineTransformMakeScale( transformScaleRatio, transformScaleRatio );
            subview.alpha = alphaRatio;
        }
    }
    
    
}

#pragma mark - JKAutoShirnkInteractiveTransitingDelegate
- (void)autoShirnkInteractiveTransiting:(JKAutoShirnkInteractiveTransiting *)transiting willShrinkViewWithPercent:(CGFloat)percentComplete{
    self.isShrinking = YES;
    [self shrinkNavigationBarItemViewWithPercent:percentComplete];
}

- (void)autoShirnkInteractiveTransiting:(JKAutoShirnkInteractiveTransiting *)transiting didShrinkViewWithPercent:(CGFloat)percentComplete{
    self.isShrinking = NO;
}

- (void)layoutSubviews{
    if(!self.isShrinking)
        [super layoutSubviews];
    else {
        CGRect frame = [self frame];
        frame.origin.x = 10.0;
        frame.origin.y = 0.0;
        frame.size.width = frame.size.width - 20.0;
        frame.size.height = 44.0;
        [self.internalTitleView setFrame:frame];
    }
}

@end