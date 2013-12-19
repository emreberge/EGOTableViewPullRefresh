//
//  NSDate+LastUpdatedTime.m
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

#import "NSDate+LastUpdatedTime.h"


#define aMinute 60
#define anHour  3600
#define aDay    86400


@implementation NSDate (LastUpdatedTime)

- (NSString *)describeTimeIntervalSinceNowAsTimeSinceLastUpdate {
    NSTimeInterval timeSinceLastUpdate = -[self timeIntervalSinceNow];
    long timeToDisplay = 0;
    
    if (timeSinceLastUpdate < anHour) {
        timeToDisplay = (NSInteger) (timeSinceLastUpdate / aMinute);
        if (timeToDisplay == 1) {
            // Singular
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld minute ago", @"PullTableViewLan", @"Last update in minutes singular"), timeToDisplay];
        } else {
            // Plural
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld minutes ago", @"PullTableViewLan", @"Last update in minutes plural"), timeToDisplay];
        }
        
    } else if (timeSinceLastUpdate < aDay) {
        timeToDisplay = (NSInteger) (timeSinceLastUpdate / anHour);
        if (timeToDisplay == 1) {
            // Singular
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld hour ago", @"PullTableViewLan", @"Last update in hours singular"), timeToDisplay];
        } else {
            // Plural
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld hours ago", @"PullTableViewLan", @"Last update in hours plural"), timeToDisplay];
        }
    } else {
        timeToDisplay = (NSInteger) (timeSinceLastUpdate / aDay);
        if (timeToDisplay == 1) {
            // Singular
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld day ago", @"PullTableViewLan", @"Last update in days singular"), timeToDisplay];
        } else {
            // Plural
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld days ago", @"PullTableViewLan", @"Last update in days plural"), timeToDisplay];
        }
    }
    
    return @"";
}

@end
