//
//  RefreshTableHeaderView.m
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

#import "RefreshTableHeaderView.h"
#import "PullTableSideView+Protected.h"
//#import "NSDate+LastUpdatedTime.h"
#import "TTTTimeIntervalFormatter.h"


@implementation RefreshTableHeaderView

static TTTTimeIntervalFormatter* timeIntervalFormatter;

@synthesize lastUpdatedLabel;


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		CGFloat midY = frame.size.height - PULL_AREA_HEIGHT/2;
        
        // Config Last Updated Label
		UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font             = [UIFont systemFontOfSize:12.0f];
		label.shadowOffset     = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor  = [UIColor clearColor];
		label.textAlignment    = NSTextAlignmentCenter;
		//[self addSubview:label];
		lastUpdatedLabel = label;
        
        // Move arrowLayer
        CGRect arrowLayerFrame = arrowLayer.frame;
        arrowLayerFrame.origin.y = midY - 35.0f;
        arrowLayer.frame = arrowLayerFrame;
        
        // Initialize status label position
        [self refreshLastUpdatedDate];
    }
	
    return self;	
}

- (void)setBackgroundColor:(UIColor *)newBackgroundColor textColor:(UIColor *)newTextColor arrowImage:(UIImage *)newArrowImage {
    [super setBackgroundColor:newBackgroundColor textColor:newTextColor arrowImage:newArrowImage];
    
    lastUpdatedLabel.textColor   = newTextColor ? newTextColor : DEFAULT_TEXT_COLOR;
    lastUpdatedLabel.shadowColor = [lastUpdatedLabel.textColor colorWithAlphaComponent:DEFAULT_SHADOW_ALPHA];
}

- (void)refreshLastUpdatedDate {
    NSDate* date = nil;
	if ([self.delegate respondsToSelector:@selector(pullTableSideViewDataSourceLastUpdated:)]) {
		date = [self.delegate pullTableSideViewDataSourceLastUpdated:self];
	}
    if (date) {
        if (!timeIntervalFormatter) {
            timeIntervalFormatter = [TTTTimeIntervalFormatter new];
            timeIntervalFormatter.usesIdiomaticDeicticExpressions = YES;
        }
        lastUpdatedLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:NSDate.date toDate:date];
    } else {
        lastUpdatedLabel.text = nil;
    }
    
    CGFloat midY = self.innerViewsCenterY;
    if (!lastUpdatedLabel.text) {
        // Center the status label if the lastUpdate is not available
        statusLabel.frame = CGRectMake(0.0f, midY - 8, self.frame.size.width, 20.0f);
    } else {
        statusLabel.frame = CGRectMake(0.0f, midY - 18, self.frame.size.width, 20.0f);
    }
}


#pragma mark - Protected helpers

- (CGFloat)innerViewsCenterY {
    return self.bounds.size.height - PULL_AREA_HEIGHT/2;
}

- (CGFloat)scrollViewCurrentOffsetFromSide:(UIScrollView *)scrollView {
    return scrollView.contentOffset.y;
}

- (CGFloat)scrollViewOuterOffsetForSide:(UIScrollView *)scrollView {
    return -PULL_TRIGGER_HEIGHT;
}

- (void)scrollView:(UIScrollView *)scrollView setContentInsetSideTo:(CGFloat)value {
    scrollView.contentInset = PullTableUIEdgeInsetsSetTop(scrollView.contentInset, value);
}

- (CGFloat)rotationForState:(PullTableState)aState {
    if (aState == PullTableStateNormal) {
        return 0.0f;
    } else {
        return M_PI;
    }
}

- (void)setState:(PullTableState)aState {
    [super setState:aState];
    
    if (aState == PullTableStateNormal) {
        [self refreshLastUpdatedDate];
    }
}

- (void)pullTableWillBeginDragging:(UIScrollView *)scrollView {
    [self refreshLastUpdatedDate];
}

@end
