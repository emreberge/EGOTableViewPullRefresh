//
//  PullTableView.h
//
//  Created by Emre Ergenekon on 07/30/11.
//  Extended by Marius Rackwitz on 10/18/12.
//  Copyright 2011 Emre Berge Ergenekon. All rights reserved.
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
#import "MessageInterceptor.h"
#import "RefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"


@class PullTableView;


@protocol PullTableViewDelegate <NSObject>

/* After one of the delegate methods is invoked a loading animation is started, to end it use the respective status update property */
- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView;
- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView;

@end


@interface PullTableView : UITableView<PullTableSideViewDelegate> {
    // Since we use the contentInsets to manipulate the view we need to store the the content insets originally specified.
    UIEdgeInsets realContentInsets;
    
    // Restore for empty view
    UITableViewCellSeparatorStyle savedSeparatorStyle;
    
    // For intercepting the scrollView delegate messages.
    MessageInterceptor* delegateInterceptor;
}

// Side views
@property (nonatomic, retain) RefreshTableHeaderView*  refreshView;
@property (nonatomic, retain) LoadMoreTableFooterView* loadMoreView;

// Shown if there is no content
@property (nonatomic, retain) UIView* emptyView;

// The configurable display properties of PullTableView. Set to nil for default values
@property (nonatomic, retain) UIImage* pullArrowImage;
@property (nonatomic, retain) UIColor* pullBackgroundColor;
@property (nonatomic, retain) UIColor* pullTextColor;

// Set to nil to hide last modified text
@property (nonatomic, retain) NSDate* pullLastRefreshDate;

// Properties to set the status of the refresh/loadMore operations. */
/*
 After the delegate methods are triggered the respective properties are automatically set to YES.
 After a refresh/reload is done it is necessary to set the respective property to NO, otherwise the
 animation won't disappear. You can also set the properties manually to YES to show the animations.
 */
@property (nonatomic, assign) BOOL pullTableIsRefreshing;
@property (nonatomic, assign) BOOL pullTableIsLoadingMore;

// Enable or disable
@property (nonatomic, assign) BOOL pullTableIsRefreshingEnabled;
@property (nonatomic, assign) BOOL pullTableIsLoadingMoreEnabled;

@property(nonatomic, assign) BOOL hidesOnLoading;

// Delegate
@property (nonatomic, assign) IBOutlet id<PullTableViewDelegate> pullDelegate;

@end
