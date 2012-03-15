//
//  CVViewController.m
//  CoverView
//
//  Created by Yi Gu on 3/14/12.
//  Copyright (c) 2012  All rights reserved.
//

#import "CVViewController.h"

#define THRESHOLD               44.0f
#define VISIBLE_BORDER_WIDTH    40.0f

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
    // 初始化PanGestureRecognizer
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self.coverView addGestureRecognizer:recognizer];
    // 记录视图的初始位置
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
            CGFloat absolute = ABS(delta);
            
            CGRect currentFrame = containerFrameStartedToPan;
            CoverPosition stopPosition = currentPosition;
            
            // 滑动小于44点时，不移动
            if (absolute >= THRESHOLD) {
                // 滑动超过44点时，执行滑动
                int direction = delta < 0 ? -1 : 1;
                stopPosition = currentPosition + direction;
                
                if (stopPosition == CoverPositionCenter) {
                    currentFrame.origin.x = 0;
                } else {
                    currentFrame.origin.x = direction * (currentFrame.size.width - VISIBLE_BORDER_WIDTH);
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
