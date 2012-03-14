//
//  CVViewController.m
//  CoverView
//
//  Created by Yi Gu on 3/14/12.
//  Copyright (c) 2012  All rights reserved.
//

#import "CVViewController.h"

typedef enum {
    CoverPositionCenter = 0,
    CoverPositionLeft   = -1,
    CoverPositionRight  = 1,
} CoverPosition;

@interface CVViewController () {
    CGRect containerFrameStartedToPan;
    CoverPosition currentPosition;
}
- (void)onPan:(UIPanGestureRecognizer *)recognizer;
@end

@implementation CVViewController
@synthesize coverView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //初始化PanGestureRecognizer
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self.coverView addGestureRecognizer:recognizer];
    //记录视图的初始位置
    currentPosition = CoverPositionCenter;
}

- (void)viewDidUnload
{
    [self setCoverView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)onPan:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"onPan");
    CGPoint translation = [recognizer translationInView:self.view];
    CGRect containerFrame;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Pan began.");
            containerFrameStartedToPan = self.coverView.frame;
            break;
            
        case UIGestureRecognizerStateChanged:
            containerFrame = containerFrameStartedToPan;
            containerFrame.origin.x += translation.x;
            self.coverView.frame = containerFrame;
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Pan ended.");
            CGFloat delta = self.coverView.frame.origin.x - containerFrameStartedToPan.origin.x;
            CGFloat absolution = delta < 0 ? -delta : delta;
            
            CGRect currentFrame = containerFrameStartedToPan;
            CoverPosition stopPosition = currentPosition;
            
            // 滑动小于44点时，不移动
            if (absolution >= 44) {
                // 滑动超过44点时，执行滑动
                if (delta < 0) {
                    //向左
                    NSLog(@"Move left");
                    //根据当前位置决定滑动的终止状态
                    if (currentPosition == CoverPositionCenter) {
                        currentFrame.origin.x = -280;
                        stopPosition = CoverPositionLeft;
                    }
                    if (currentPosition == CoverPositionRight) {
                        currentFrame.origin.x = 0;
                        stopPosition = CoverPositionCenter;
                    }
                    if (currentPosition == CoverPositionLeft) {
                        currentFrame.origin.x = -280;
                        stopPosition = CoverPositionLeft;
                    }
                    
                } else {
                    NSLog(@"Move right");
                    if (currentPosition == CoverPositionCenter) {
                        currentFrame.origin.x = 280;
                        stopPosition = CoverPositionRight;
                    }
                    if (currentPosition == CoverPositionRight) {
                        currentFrame.origin.x = 280;
                        stopPosition = CoverPositionRight;
                    }
                    if (currentPosition == CoverPositionLeft) {
                        currentFrame.origin.x = 0;
                        stopPosition = CoverPositionCenter;
                    }
                }
            }
            //移动coverView的动画
            [UIView animateWithDuration:0.25 animations:^{
                self.coverView.frame = currentFrame;
            } completion:^(BOOL finished){
                if (!finished) return;
                
                // 移动完成后更新当前的位置状态
                currentPosition = stopPosition;
            }];
            
            break;
        case UIGestureRecognizerStateCancelled:
            self.coverView.frame = containerFrameStartedToPan;
            break;
        default:
            break;
    }
}

@end