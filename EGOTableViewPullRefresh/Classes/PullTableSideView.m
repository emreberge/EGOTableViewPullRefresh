//
//  PullTableSideView.m
//  
//  Created by Devin Doty on 10/14/09.
//  Rewritten by Marius Rackwitz on 10/18/12.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PullTableSideView.h"
#import "PullTableSideView+Protected.h"


@implementation PullTableSideView : UIView

@synthesize statusLabel;
@synthesize arrowLayer;
@synthesize activityView;
@synthesize delegate;
@synthesize state;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        isLoading = NO;
        
        CGFloat midY = self.innerViewsCenterY;

        // Config Status Updated Label
        UILabel* label         = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY - 10.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font             = [UIFont boldSystemFontOfSize:13.0f];
        label.shadowOffset     = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor  = [UIColor clearColor];
        label.textAlignment    = NSTextAlignmentCenter;
        //[self addSubview:label];
        statusLabel = label;
        
        // Config Arrow Image
        CALayer* layer         = [[CALayer alloc] init];
        layer.frame            = CGRectMake(0, midY - 20.0f, self.width, 55.0f);
        layer.contentsGravity  = kCAGravityCenter;
        if ([UIScreen.mainScreen respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [UIScreen.mainScreen scale];
        }
        [self.layer addSublayer:layer];
        arrowLayer = layer;
        
        // Config activity indicator
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:DEFAULT_ACTIVITY_INDICATOR_STYLE];
        view.frame = CGRectMake(25.0f, midY - 8.0f, 20.0f, 20.0f);
        [self addSubview:view];
        activityView = view;        
        
        [self setState:PullTableStateNormal];
        
        // Configure the default colors and arrow image
        [self setBackgroundColor:nil textColor:nil arrowImage:nil];
    }
    
    return self;
}


#pragma mark - Protected helpers

- (CGFloat)innerViewsCenterY                                                       PULL_TABLE_ABSTRACT_SEL;
- (CGFloat)scrollViewCurrentOffsetFromSide:(UIScrollView *)scrollView              PULL_TABLE_ABSTRACT_SEL;
- (CGFloat)scrollViewOuterOffsetForSide:(UIScrollView *)scrollView                 PULL_TABLE_ABSTRACT_SEL;
- (void)scrollView:(UIScrollView *)scrollView setContentInsetSideTo:(CGFloat)value PULL_TABLE_ABSTRACT_SEL;
- (CGFloat)rotationForState:(PullTableState)aState                                 PULL_TABLE_ABSTRACT_SEL;


#pragma mark - Overwritten implementations

- (BOOL)isUserInteractionEnabled {
    return state != PullTableStateDisabled;
}


#pragma mark - Setters

- (void)setState:(PullTableState)aState {
    switch (aState) {
        case PullTableStatePulling:
            statusLabel.text  = NSLocalizedStringFromTable(@"Release to refresh", @"PullTableViewLan", @"Release to refresh status");
            
            // Show arrow rotated by 180 degrees
           /* [CATransaction begin];
            [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            arrowLayer.opacity    = 1.0f;
            [CATransaction commit];*/
            arrowLayer.opacity    = 1.0f;
            break;
            
        case PullTableStateNormal:
            statusLabel.text = NSLocalizedStringFromTable(@"Pull down to refresh", @"PullTableViewLan", @"Pull down to refresh status");
            
            // Hide activity view
            [activityView stopAnimating];
           /* [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
            arrowLayer.opacity    = 0.0f;
            [CATransaction commit];*/
            break;
            
        case PullTableStateLoading:
            statusLabel.text = NSLocalizedStringFromTable(@"Loading...", @"PullTableViewLan", @"Loading Status");
            
            // Show activity view and hide arrow
            [activityView startAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
            arrowLayer.opacity    = 0.0f;
            [CATransaction commit];
            break;
            
        case PullTableStateDisabled:
            statusLabel.text    = nil;
            arrowLayer.opacity    = 0.0f;
            [activityView stopAnimating];
            break;
    }
    
    state = aState;
}

- (void)setBackgroundColor:(UIColor *)newBackgroundColor textColor:(UIColor *)newTextColor arrowImage:(UIImage *)newArrowImage {
    self.backgroundColor    = newBackgroundColor ? newBackgroundColor    : DEFAULT_BACKGROUND_COLOR;
    statusLabel.textColor   = newTextColor       ? newTextColor          : DEFAULT_TEXT_COLOR;
    if (newArrowImage) {
        arrowLayer.contents = (id)newArrowImage.CGImage;
    }    
    
    statusLabel.shadowColor = [statusLabel.textColor colorWithAlphaComponent:DEFAULT_SHADOW_ALPHA];
}


#pragma mark - ScrollView Methods

- (void)pullTableViewDidScroll:(UIScrollView *)scrollView {
    if (state == PullTableStateDisabled) {
        [self scrollView:scrollView setContentInsetSideTo:0];
        
    } else {
        CGFloat offset = [self scrollViewCurrentOffsetFromSide:scrollView];
        
        if (state == PullTableStateLoading) {
            offset = MAX(-offset, 0);
            offset = MIN(offset, PULL_AREA_HEIGHT);
            [self scrollView:scrollView setContentInsetSideTo:offset];
            
        } else if (scrollView.isDragging) {
            arrowLayer.opacity = ((0.7f / PULL_AREA_HEIGHT) * -offset) - 0.5f;
            NSLog(@"%f", arrowLayer.opacity);
            if (!isLoading) {
                if (state == PullTableStatePulling && offset > -PULL_TRIGGER_HEIGHT && offset < 0) {
                    [self setState:PullTableStateNormal];
                } else if (state == PullTableStateNormal && offset < -PULL_TRIGGER_HEIGHT) {
                    [self setState:PullTableStatePulling];
                }
            }
            
            if (scrollView.contentInset.top != 0) {
                [self scrollView:scrollView setContentInsetSideTo:0];
            }
        }
    }
}

- (void)pullTableViewStartAnimating:(UIScrollView *)scrollView {
    isLoading = YES;
    
    [self setState:PullTableStateLoading];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:PULL_SHOW_DURATION];
    [self scrollView:scrollView setContentInsetSideTo:PULL_AREA_HEIGHT];
    [UIView commitAnimations];
    
    if ([self scrollViewCurrentOffsetFromSide:scrollView] <= 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, [self scrollViewOuterOffsetForSide:scrollView]) animated:YES];
    }    
}

- (void)pullTableViewWillBeginDragging:(UIScrollView *)scrollView {
}

- (void)pullTableViewDidEndDragging:(UIScrollView *)scrollView {
    if (!self.userInteractionEnabled) {
        return;
    }
    if ([self scrollViewCurrentOffsetFromSide:scrollView] <= - PULL_TRIGGER_HEIGHT && !isLoading) {
        if ([delegate respondsToSelector:@selector(pullTableSideViewDidTrigger:)]) {
            [delegate pullTableSideViewDidTrigger:self];
        }
        if (self.hidesOnDragEnd) {
            [self pullTableViewDataSourceDidFinishedLoading:scrollView];
        } else {
            [self pullTableViewStartAnimating:scrollView];
        }
    }
}

- (void)pullTableViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {    
    isLoading = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:PULL_HIDE_DURATION];
    [self scrollView:scrollView setContentInsetSideTo:0];
    [UIView commitAnimations];
    
    [self setState:PullTableStateNormal];
}

@end
