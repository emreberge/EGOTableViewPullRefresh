//
//  LoadMoreTableFooterView.m
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

#import "LoadMoreTableFooterView.h"
#import "PullTableSideView+Protected.h"


@implementation LoadMoreTableFooterView


#pragma mark - Protected helpers

- (CGFloat)innerViewsCenterY {
    return PULL_AREA_HEIGHT/2;
}

- (void)scrollView:(UIScrollView *)scrollView setContentInsetSideTo:(CGFloat)value {
    if (value != 0) {
        // Add difference between visible table height and bounds height
        // => adjust to real bottom edge
        value += scrollView.bounds.size.height - MIN(scrollView.bounds.size.height, scrollView.contentSize.height);
    }
    scrollView.contentInset = PullTableUIEdgeInsetsSetBottom(scrollView.contentInset, value);
}

- (CGFloat)rotationForState:(PullTableState)aState {
    if (aState == PullTableStateNormal) {
        return M_PI;
    } else {
        return 0.0f;
    }
}

- (CGFloat)scrollViewCurrentOffsetFromSide:(UIScrollView *)scrollView {
    const CGFloat scrollViewContentHeight = scrollView.contentSize.height;
    
    // The bottom edge of visible content
    const CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, scrollViewContentHeight);
    
    // If scrolled all the way down this should add up to the content height
    const CGFloat scrolledDistance = scrollView.contentOffset.y + visibleTableHeight;
    
    const CGFloat normalizedOffset = scrollViewContentHeight - scrolledDistance;
    
    return normalizedOffset;
}

- (CGFloat)scrollViewOuterOffsetForSide:(UIScrollView *)scrollView {
    return scrollView.contentOffset.y + PULL_TRIGGER_HEIGHT;
}

@end
