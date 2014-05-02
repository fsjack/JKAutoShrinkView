//
//  JKAutoShirnkInteractiveTransiting.m
//  JKAutoShrinkViewDemo
//
//  Created by Jackie CHEUNG on 14-1-16.
//  Copyright (c) 2014年 Jackie. All rights reserved.
//

#import "JKAutoShirnkInteractiveTransiting.h"
#import "UIScrollView+JKMultiDelegatesSupport.h"

static CGFloat const _JKAutoShrinkAnimationDuration = 0.12f;
static CGFloat const _JKAutoShrinkNavigationBarMinimumHeight = 20.0f;
static CGFloat const _JKAutoShrinkScrollViewVelocityThreshold = 0.8f;

typedef NS_ENUM(NSUInteger, JKAutoShrinkScrollViewDraggingDirection) {
    JKAutoShrinkScrollViewDraggingDirectionOther,
    JKAutoShrinkScrollViewDraggingDirectionUp,
    JKAutoShrinkScrollViewDraggingDirectionDown
};

typedef NS_ENUM(NSUInteger, JKAutoShrinkNavigationBarState) {
    JKAutoShrinkNavigationBarStateNormal,
    JKAutoShrinkNavigationBarStateShrinked
};

@interface JKAutoShirnkInteractiveTransiting ()
@property (nonatomic, weak)     UINavigationController  *navigationController;
@property (nonatomic, weak)     UIScrollView            *scrollView;
@property (nonatomic, readonly) UINavigationBar<JKAutoShirnkInteractiveTransitingDelegate>  *navigationBar;
@property (nonatomic, readonly) UIToolbar<JKAutoShirnkInteractiveTransitingDelegate>        *toolbar;

@property (nonatomic) CGFloat shrinkingContentOffsetY; /* shrinkingContentOffsetY is where navigation bar should do shrinking transform. */

@property (nonatomic, readonly) JKAutoShrinkNavigationBarState navigationBarState;

@property (nonatomic, readonly) BOOL shouldNavigationBarAutoShrink;

@property (nonatomic, weak) CADisplayLink *displayLink;
@property (nonatomic) CGFloat animationProgress;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic,readonly) CGFloat currentAnimationProgress;
@end

@implementation JKAutoShirnkInteractiveTransiting

- (id)init{
    [NSException raise:NSGenericException format:@"Please init JKAutoShirnkInteractiveTransiting by using method 'initWithNavigationController:' instead."];
    return nil;
}

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController{
    self = [super init];
    if(self){
        _navigationController = navigationController;
    }
    return self;
}

#pragma mark - Property
- (BOOL)shouldNavigationBarAutoShrink{
    
    CGFloat topLayoutGuideLength = [self.navigationController.topViewController.topLayoutGuide length];
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    CGFloat navigationBarMaximumHeight = (topLayoutGuideLength - statusBarHeight);
    
    BOOL isScrollViewStickToScreen = CGPointEqualToPoint(self.scrollView.frame.origin, CGPointZero); /* Not accurcy if scrollView is cantained in other view like UIWebView. */
    BOOL IsScrollViewAutomaticallyAdjustInset = (isScrollViewStickToScreen && topLayoutGuideLength);
    BOOL isNavigationBarHidden = self.navigationController.navigationBarHidden;
    BOOL isNavigationBarTooShort = (navigationBarMaximumHeight < _JKAutoShrinkNavigationBarMinimumHeight);
    
    BOOL isScrollViewContentSizeLargeEnough = (self.scrollView.contentSize.height + self.scrollView.contentInset.top + self.scrollView.contentInset.bottom > CGRectGetHeight(self.scrollView.frame));
    return (isScrollViewContentSizeLargeEnough && IsScrollViewAutomaticallyAdjustInset && !isNavigationBarHidden && !isNavigationBarTooShort);
}

- (JKAutoShrinkNavigationBarState)navigationBarState{
    
    CGFloat topLayoutGuideLength = [self.navigationController.topViewController.topLayoutGuide length];
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    CGFloat navigationBarHeight = (topLayoutGuideLength - statusBarHeight);
    
    JKAutoShrinkNavigationBarState navigationBarState = (navigationBarHeight == CGRectGetHeight(self.navigationBar.bounds)) ? JKAutoShrinkNavigationBarStateNormal : JKAutoShrinkNavigationBarStateShrinked;
    return navigationBarState;
}

- (UINavigationBar<JKAutoShirnkInteractiveTransitingDelegate> *)navigationBar{
    UINavigationBar<JKAutoShirnkInteractiveTransitingDelegate> *navigationBar = (UINavigationBar<JKAutoShirnkInteractiveTransitingDelegate> *)self.navigationController.navigationBar;
    return navigationBar;
}

- (UIToolbar<JKAutoShirnkInteractiveTransitingDelegate> *)toolbar{
    UIToolbar<JKAutoShirnkInteractiveTransitingDelegate> *toolbar = (UIToolbar<JKAutoShirnkInteractiveTransitingDelegate> *)self.navigationController.toolbar;
    return toolbar;
}

- (CGFloat)currentAnimationProgress{
    CGFloat topLayoutGuideLength = [self.navigationController.topViewController.topLayoutGuide length];
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    CGFloat navigationBarMaximumHeight = (topLayoutGuideLength - statusBarHeight);
    
    CGFloat currentAnimationProgress = (1.0f - (navigationBarMaximumHeight - CGRectGetHeight(self.navigationBar.bounds)) / (navigationBarMaximumHeight - _JKAutoShrinkNavigationBarMinimumHeight));
    
    return currentAnimationProgress;
}

- (void)setShrinkingContentOffsetY:(CGFloat)shrinkingContentOffsetY{
    if(shrinkingContentOffsetY < 0.0f)
        shrinkingContentOffsetY = 0.0f;
    _shrinkingContentOffsetY = shrinkingContentOffsetY;
}

#pragma mark - Private Methods
- (UIScrollView *)traverseSubviewsToGetViewOfClass:(Class)viewClass inView:(UIView *)view{
    if(!view) return nil;
    
    if([view isKindOfClass:[viewClass class]])
        return (UIScrollView *)view;
    else
        return [self traverseSubviewsToGetViewOfClass:viewClass inView:view.subviews.firstObject];
}

- (void)shrinkNavigationBarWithRatio:(CGFloat)ratio{
    CGFloat topLayoutGuideLength = [self.navigationController.topViewController.topLayoutGuide length];
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    
    CGFloat navigationBarMaximumHeight = (topLayoutGuideLength - statusBarHeight);
    CGFloat navigationBarCurrentHeight = (_JKAutoShrinkNavigationBarMinimumHeight + (navigationBarMaximumHeight - _JKAutoShrinkNavigationBarMinimumHeight) * ratio);
    if (navigationBarCurrentHeight < _JKAutoShrinkNavigationBarMinimumHeight)
        navigationBarCurrentHeight = _JKAutoShrinkNavigationBarMinimumHeight;
    
    UINavigationBar<JKAutoShirnkInteractiveTransitingDelegate> *navigationBar = self.navigationBar;
    if([navigationBar respondsToSelector:@selector(autoShirnkInteractiveTransiting:willShrinkViewWithPercent:)]){
        [navigationBar autoShirnkInteractiveTransiting:self willShrinkViewWithPercent:ratio];
    }
    
    navigationBar.frame = (CGRect){
        { CGRectGetMinX(navigationBar.frame) , CGRectGetMinY(navigationBar.frame) },
        { CGRectGetWidth(navigationBar.bounds) , navigationBarCurrentHeight }
    };
    [navigationBar layoutIfNeeded];
    
    self.scrollView.contentInset = (UIEdgeInsets){
        statusBarHeight + navigationBarCurrentHeight , self.scrollView.contentInset.left,
        self.scrollView.contentInset.bottom , self.scrollView.contentInset.right
    };
    
    if([navigationBar respondsToSelector:@selector(autoShirnkInteractiveTransiting:didShrinkViewWithPercent:)]){
        [navigationBar autoShirnkInteractiveTransiting:self didShrinkViewWithPercent:ratio];
    }
}

- (void)shrinkToolbarBarWithRatio:(CGFloat)ratio{
    if (ratio > 0 && [self.navigationController isToolbarHidden]) {
        [self.navigationController setToolbarHidden:NO];
    }
    
    UIToolbar<JKAutoShirnkInteractiveTransitingDelegate> *toolbar = self.toolbar;
    if([toolbar respondsToSelector:@selector(autoShirnkInteractiveTransiting:willShrinkViewWithPercent:)]){
        [toolbar autoShirnkInteractiveTransiting:self willShrinkViewWithPercent:ratio];
    }
    CGFloat toolbarHeight = CGRectGetHeight(toolbar.frame);
    CGFloat bottomLayoutGuideLength = CGRectGetMaxY(self.navigationController.topViewController.view.frame);
    
    CGFloat toolbarDefaultOffsetY = bottomLayoutGuideLength;
    CGFloat toolbarCurrentOffsetY = (toolbarDefaultOffsetY - (toolbarHeight * ratio));

    toolbar.frame = (CGRect){
        { CGRectGetMinX(toolbar.frame) , toolbarCurrentOffsetY },
        { CGRectGetWidth(toolbar.bounds) , toolbarHeight }
    };
    [toolbar layoutIfNeeded];
    
    self.scrollView.contentInset = (UIEdgeInsets){
        self.scrollView.contentInset.top , self.scrollView.contentInset.left,
        (toolbarHeight * ratio) , self.scrollView.contentInset.right
    };
    
    if([toolbar respondsToSelector:@selector(autoShirnkInteractiveTransiting:didShrinkViewWithPercent:)]){
        [toolbar autoShirnkInteractiveTransiting:self didShrinkViewWithPercent:ratio];
    }
    
    if (ratio == 0) {
        [self.navigationController setToolbarHidden:YES];
    }
}

- (void)performShrinkingAnimation:(BOOL)isShrink{
    if(self.displayLink){
        [self.displayLink invalidate];
    }
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:isShrink ? @selector(updateShrinkingAnimationByFrame) : @selector(updateExpendingAnimationByFrame)];
    self.displayLink = displayLink;
    
    self.animationDuration = _JKAutoShrinkAnimationDuration;
    self.animationProgress = self.currentAnimationProgress;
    
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateExpendingAnimationByFrame{
    
    CGFloat delta = (1.0f / ((1.0f / self.displayLink.duration) * self.animationDuration));
    self.animationProgress = self.animationProgress + delta;
    if(self.animationProgress > 1.0f) {
        self.animationProgress = 1.0f;
        [self.displayLink invalidate];
    }
    
    [self shrinkNavigationBarWithRatio:self.animationProgress];
    [self shrinkToolbarBarWithRatio:self.animationProgress];
}

- (void)updateShrinkingAnimationByFrame{
    
    CGFloat delta = (1.0f / ((1.0f / self.displayLink.duration) * self.animationDuration));
    self.animationProgress = self.animationProgress - delta;
    if(self.animationProgress < 0.0f) {
        self.animationProgress = 0.0f;
        [self.displayLink invalidate];
    }
    
    [self shrinkNavigationBarWithRatio:self.animationProgress];
    [self shrinkToolbarBarWithRatio:self.animationProgress];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //[self.navigationController.view dumpView];
    
    /* NavigationBar or Toolbar should do nothing if scrollView contentSize less than the screen size. */
    if(!self.shouldNavigationBarAutoShrink)
        return;
    [self.displayLink invalidate];
    
    CGFloat ratio;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    
    /* Do navigationBar shrinking work. */
    contentOffsetY = contentOffsetY - self.shrinkingContentOffsetY;
    /* ScrollView has Propably been automatically inset topLayoutGuideLength. */
    CGFloat topLayoutGuideLength = [self.navigationController.topViewController.topLayoutGuide length];
    CGFloat navigationBarHeight = (topLayoutGuideLength - statusBarHeight);
    
    CGFloat realContentOffsetY = contentOffsetY + (statusBarHeight + navigationBarHeight);
    /*
     If scrollView stick to the top of the screen.
     Navigation will NOT automatically shrink if scrollView is not on the top of the screen by default.
     */
    if(realContentOffsetY < 0)
        realContentOffsetY = 0;
    else if(realContentOffsetY > (navigationBarHeight - _JKAutoShrinkNavigationBarMinimumHeight) )
        realContentOffsetY = (navigationBarHeight - _JKAutoShrinkNavigationBarMinimumHeight);
    
    /* NavigationBar will stop shrink when content offset Y reach statusBar height. */
    ratio = (1.0f - realContentOffsetY / (navigationBarHeight - _JKAutoShrinkNavigationBarMinimumHeight));
    [self shrinkNavigationBarWithRatio:ratio];
    
    /* Do Toolbar shrinking work. */
    [self shrinkToolbarBarWithRatio:ratio];
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    /* NavigationBar or Toolbar should change shape even scrollView not on the top or bottom,But change shape as velocity reach some kinda speed. */
    if(!self.shouldNavigationBarAutoShrink) return;
    
    JKAutoShrinkScrollViewDraggingDirection draggingDirection = JKAutoShrinkScrollViewDraggingDirectionOther;
    if(velocity.y > 0.0 )
        draggingDirection = JKAutoShrinkScrollViewDraggingDirectionDown;
    else if(velocity.y < 0.0 )
        draggingDirection = JKAutoShrinkScrollViewDraggingDirectionUp;
    
    CGFloat topLayoutGuideLength = [self.navigationController.topViewController.topLayoutGuide length];
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    BOOL inContentInsetRange = (contentOffsetY > -statusBarHeight && contentOffsetY < -topLayoutGuideLength);
    CGFloat velocityY = -velocity.y;
    
    BOOL isVelocityReachThreshold = velocityY >= _JKAutoShrinkScrollViewVelocityThreshold;
    
    if(draggingDirection == JKAutoShrinkScrollViewDraggingDirectionUp && self.navigationBarState == JKAutoShrinkNavigationBarStateShrinked && !inContentInsetRange){
        if(isVelocityReachThreshold){
            self.shrinkingContentOffsetY = contentOffsetY;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat topLayoutGuideLength = [self.navigationController.topViewController.topLayoutGuide length];
    
    if(self.navigationBarState == JKAutoShrinkNavigationBarStateNormal){
        self.shrinkingContentOffsetY = contentOffsetY + topLayoutGuideLength;
    }else{
        self.shrinkingContentOffsetY = 0.0f;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    /* Shrink or Expand navigationBar when scorllView stop scrolling. */
    if(!decelerate){
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        
        if(self.currentAnimationProgress > 0.9 || contentOffsetY < -(statusBarHeight + _JKAutoShrinkNavigationBarMinimumHeight) ){
            [self performShrinkingAnimation:NO];
        }else{
            [self performShrinkingAnimation:YES];
        }
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!self.scrollView) {
        [self navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.scrollView removeMultiDelegateByDelegateForwarder:self];
    UIScrollView *scrollView = [self traverseSubviewsToGetViewOfClass:[UIScrollView class] inView:viewController.view];
    [scrollView addMultiDelegateByDelegateForwarder:self];
    self.scrollView = scrollView;
    
    self.shrinkingContentOffsetY = 0.0f;
}

@end
