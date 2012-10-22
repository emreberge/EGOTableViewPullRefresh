//
//  PullTableView.m
//
//  Created by Emre Ergenekon on 07/30/11.
//  Extended by Marius Rackwitz on 10/18/12.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "PullTableView.h"


@interface PullTableView (Private) <UIScrollViewDelegate>

- (void) config;
- (void) configDisplayProperties;

@end



@implementation PullTableView

@synthesize pullDelegate;
@synthesize emptyView;
@synthesize pullArrowImage;
@synthesize pullBackgroundColor;
@synthesize pullTextColor;
@synthesize pullLastRefreshDate;
@synthesize pullTableIsLoadingMore;
@synthesize pullTableIsRefreshing;
@dynamic pullTableIsRefreshingEnabled;
@dynamic pullTableIsLoadingMoreEnabled;


# pragma mark - Initialization / Deallocation

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self config];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self config];
}

- (void)dealloc {
    emptyView            = nil;
    pullArrowImage       = nil;
    pullBackgroundColor  = nil;
    pullTextColor        = nil;
    pullLastRefreshDate  = nil;
    refreshView          = nil;
    loadMoreView         = nil;
    delegateInterceptor  = nil;
}


# pragma mark - Custom view configuration

- (void)config {
    // Message interceptor to intercept scrollView delegate messages
    delegateInterceptor = [MessageInterceptor messageInterceptorOver:self to:self.delegate];
    super.delegate = (id)delegateInterceptor;
    
    // Status properties
    pullTableIsRefreshing  = NO;
    pullTableIsLoadingMore = NO;
    
    const CGSize sideViewSize = self.bounds.size;
    
    // Refresh view
    refreshView = [[RefreshTableHeaderView alloc] initWithFrame:(CGRect){{0, -self.bounds.size.height}, sideViewSize}];
    refreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    refreshView.delegate = self;
    [self addSubview:refreshView];
    
    // Load more view init
    loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:(CGRect){{0, -self.bounds.size.height}, sideViewSize}];
    loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    loadMoreView.delegate = self;
    [self addSubview:loadMoreView];
}


#pragma mark - Empty view

- (bool)tableViewHasRows {
    NSArray* indexPathsForVisibleRows = self.indexPathsForVisibleRows;
    return indexPathsForVisibleRows.count > 0;
}

- (void)updateEmptyPage {
    emptyView.frame = (CGRect){CGPointZero, self.frame.size};
    
    const bool shouldShowEmptyView = self.tableViewHasRows;
    const bool emptyViewShown      = emptyView.superview != nil;
    
    if (shouldShowEmptyView == emptyViewShown) {
        return;
    }
    
    CATransition* animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[self layer] addAnimation:animation forKey:kCATransitionReveal];
    
    if (shouldShowEmptyView) {
        savedSeparatorStyle = self.separatorStyle; 
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:emptyView];
    } else {
        self.separatorStyle = savedSeparatorStyle;
        [emptyView removeFromSuperview];
    }
}

- (void)setEmptyView:(UIView *)newView {
    if (newView == emptyView) {
        return;
    }
    
    [emptyView removeFromSuperview];
    emptyView = newView;
    
    [self updateEmptyPage];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // Prevent any interaction when the empty view is shown
    // TODO: Sure, maybe we want to pull?!
    return emptyView.superview != nil ? nil : [super hitTest:point withEvent:event];
}


# pragma mark - View changes

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateEmptyPage];
    
    // Layout footer
    const CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
    CGRect loadMoreFrame = loadMoreView.frame;
    loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
    loadMoreView.frame = loadMoreFrame;
}


#pragma mark - Preserving the original behaviour

- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    if (delegateInterceptor) {
        super.delegate = nil;
        delegateInterceptor.receiver = delegate;
        super.delegate = (id)delegateInterceptor;
    } else {
        super.delegate = delegate;
    }
}

- (void)reloadData {
    [super reloadData];
    
    // Check if we need to add, keep or remove empty page
    [self updateEmptyPage];
    
    // Give the footers a chance to fix it self.
    [loadMoreView pullTableViewDidScroll:self];
}


#pragma mark - Status Propreties

- (void)setPullTableIsRefreshing:(BOOL)isRefreshing {
    pullTableIsRefreshing = [self stateFrom:pullTableIsRefreshing to:isRefreshing forPullTableSideView:refreshView];
}

- (void)setPullTableIsLoadingMore:(BOOL)isLoadingMore {
    pullTableIsLoadingMore = [self stateFrom:pullTableIsLoadingMore to:isLoadingMore forPullTableSideView:loadMoreView];
}

- (BOOL)stateFrom:(BOOL)wasActive to:(BOOL)isActive forPullTableSideView:(PullTableSideView *)sideView {
    if (wasActive == isActive) {
        return wasActive;
    }
    if (isActive) {
        // If not already active, start animation
        [sideView pullTableViewStartAnimating:self];
        return YES;
    } else {
        // If was active and finished, stop animation
        [sideView pullTableViewDataSourceDidFinishedLoading:self];
        return NO;
    }
}


#pragma mark - Display properties

- (void)configDisplayProperties {
    [refreshView  setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
    [loadMoreView setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
}

- (void)setPullArrowImage:(UIImage *)aPullArrowImage {
    if (aPullArrowImage != pullArrowImage) {
        pullArrowImage = aPullArrowImage;
        [self configDisplayProperties];
    }
}

- (void)setPullBackgroundColor:(UIColor *)aColor {
    if (aColor != pullBackgroundColor) {
        pullBackgroundColor = aColor;
        [self configDisplayProperties];
    }
}

- (void)setPullTextColor:(UIColor *)aColor {
    if (aColor != pullTextColor) {
        pullTextColor = aColor;
        [self configDisplayProperties];
    } 
}

- (void)setPullLastRefreshDate:(NSDate *)aDate {
    if (aDate != pullLastRefreshDate) {
        pullLastRefreshDate = aDate;
        [refreshView refreshLastUpdatedDate];
    }
}

- (void)setPullTableIsRefreshingEnabled:(BOOL)enabled {
    if (enabled) {
        [refreshView setState:PullTableStateNormal];
    } else {
        [refreshView setState:PullTableStateDisabled];
    }
}

- (void)setPullTableIsLoadingMoreEnabled:(BOOL)enabled {
    if (enabled) {
        [loadMoreView setState:PullTableStateNormal];
    } else {
        [loadMoreView setState:PullTableStateDisabled];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [refreshView  pullTableViewDidScroll:scrollView];
    [loadMoreView pullTableViewDidScroll:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [delegateInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [refreshView  pullTableViewDidEndDragging:scrollView];
    [loadMoreView pullTableViewDidEndDragging:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [delegateInterceptor.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [refreshView  pullTableViewWillBeginDragging:scrollView];
    [loadMoreView pullTableViewWillBeginDragging:scrollView];
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [delegateInterceptor.receiver scrollViewWillBeginDragging:scrollView];
    }
}


#pragma mark - PullTableSideViewDelegate

- (void)pullTableSideViewDidTrigger:(PullTableSideView *)view {
    if (view == refreshView) {
        pullTableIsRefreshing = YES;
        [pullDelegate pullTableViewDidTriggerRefresh:self];
    } else if (view == loadMoreView) {
        pullTableIsLoadingMore = YES;
        [pullDelegate pullTableViewDidTriggerLoadMore:self];    
    }
}

- (NSDate *)pullTableSideViewDataSourceLastUpdated:(PullTableSideView *)view {
    return self.pullLastRefreshDate;
}

@end
