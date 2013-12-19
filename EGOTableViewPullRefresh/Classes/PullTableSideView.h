//
//  PullTableSideView.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


#define DEFAULT_BACKGROUND_COLOR          [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0]
#define DEFAULT_TEXT_COLOR                [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define DEFAULT_ACTIVITY_INDICATOR_STYLE  UIActivityIndicatorViewStyleGray
#define DEFAULT_SHADOW_ALPHA              0.2f
#define FLIP_ANIMATION_DURATION           0.5f
#define PULL_AREA_HEIGHT                  60.0f
#define PULL_TRIGGER_HEIGHT               (PULL_AREA_HEIGHT + 5.0f)
#define PULL_SHOW_DURATION                0.2f
#define PULL_HIDE_DURATION                0.3f


typedef enum {
	PullTableStatePulling = 0,
	PullTableStateNormal,
	PullTableStateLoading,
	PullTableStateDisabled,
} PullTableState;

@protocol PullTableSideViewDelegate;


@interface PullTableSideView : UIView {
    UILabel*                 statusLabel;
	CALayer*                 arrowLayer;
	UIActivityIndicatorView* activityView;
    
    // Set this to YES when pullTableSideViewDidTrigger delegate
    // is called and to NO with pullTableViewDataSourceDidFinishedLoading
    BOOL isLoading;
}

@property (nonatomic, retain) UILabel*                 statusLabel;
@property (nonatomic, retain) CALayer*                 arrowLayer;
@property (nonatomic, retain) UIActivityIndicatorView* activityView;

@property(nonatomic, assign) NSObject<PullTableSideViewDelegate>* delegate;
@property(nonatomic, assign) PullTableState state;
@property(nonatomic, assign) BOOL hidesOnDragEnd;

- (void)pullTableViewDidScroll:(UIScrollView *)scrollView;
- (void)pullTableViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)pullTableViewDidEndDragging:(UIScrollView *)scrollView;
- (void)pullTableViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)pullTableViewStartAnimating:(UIScrollView *)scrollView;

- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor arrowImage:(UIImage *)arrowLayer;

@end


@protocol PullTableSideViewDelegate

- (void)pullTableSideViewDidTrigger:(PullTableSideView *)view;

@optional
- (NSDate*)pullTableSideViewDataSourceLastUpdated:(PullTableSideView *)view;

@end
