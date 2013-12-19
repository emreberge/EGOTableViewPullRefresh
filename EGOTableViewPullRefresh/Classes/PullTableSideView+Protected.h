//
//  PullTableSideView+Protected.h
//  
//  Created by Marius Rackwitz on 10/18/12.
//  Copyright 2012 Marius Rackwitz.
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


#define PULL_TABLE_ABSTRACT_SEL { \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason: \
        [NSString stringWithFormat:@"%@ has to be overwritten!", NSStringFromSelector(_cmd)]  userInfo:nil];\
    }


static inline UIEdgeInsets PullTableUIEdgeInsetsSetTop(UIEdgeInsets insets, CGFloat top) {
    insets.top = top;
    return insets;
}

static inline UIEdgeInsets PullTableUIEdgeInsetsSetBottom(UIEdgeInsets insets, CGFloat bottom) {
    insets.bottom = bottom;
    return insets;
}


@interface PullTableSideView (Protected)

- (CGFloat)innerViewsCenterY;
- (CGFloat)scrollViewCurrentOffsetFromSide:(UIScrollView *)scrollView;
- (CGFloat)scrollViewOuterOffsetForSide:(UIScrollView *)scrollView;
- (void)scrollView:(UIScrollView *)scrollView setContentInsetSideTo:(CGFloat)value;
- (CGFloat)rotationForState:(PullTableState)aState;
- (void)setState:(PullTableState)state;

@end