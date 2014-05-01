//
//  UINavigationController+iOS7Support.m
//  CoExistOfScrollViewAndBackGesture
//
//  Created by 乐星宇 on 14-5-1.
//  Copyright (c) 2014年 Lxy. All rights reserved.
//

#import "UINavigationController+iOS7Support.h"

@implementation UINavigationController (iOS7Support)

@dynamic screenEdgePanGestureRecognizer;

- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer
{
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = nil;
    if (self.view.gestureRecognizers.count > 0)
    {
        for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
        {
            if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
            {
                screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
                break;
            }
        }
    }
    
    return screenEdgePanGestureRecognizer;
}


@end
