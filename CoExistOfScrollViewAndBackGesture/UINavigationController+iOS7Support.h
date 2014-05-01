//
//  UINavigationController+iOS7Support.h
//  CoExistOfScrollViewAndBackGesture
//
//  Created by 乐星宇 on 14-5-1.
//  Copyright (c) 2014年 Lxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (iOS7Support)

@property (nonatomic, readonly) UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer;

@end
