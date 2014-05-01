//
//  UIScrollView+AllowPanGestureEventPass.m
//  CoExistOfScrollViewAndBackGesture
//
//  Created by 乐星宇 on 14-5-1.
//  Copyright (c) 2014年 Lxy. All rights reserved.
//

#import "UIScrollView+AllowPanGestureEventPass.h"

@implementation UIScrollView (AllowPanGestureEventPass)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
        && [otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
    {
        return YES;
    }
    else
    {
        return  NO;
    }
}



@end
