//
//  ViewController.m
//  CoExistOfScrollViewAndBackGesture
//
//  Created by 乐星宇 on 14-5-1.
//  Copyright (c) 2014年 Lxy. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+AllowPanGestureEventPass.h"
#import "UINavigationController+iOS7Support.h"


@interface ViewController ()
{
    UIScrollView *_scrollView;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3, _scrollView.contentSize.height);
    _scrollView.pagingEnabled = YES;
    
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = self.navigationController.screenEdgePanGestureRecognizer;
    [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:screenEdgePanGestureRecognizer];
    
    for (NSInteger i = 0; i < 3 ; ++i)
    {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width * i, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
        
        if (i == 0)
        {
        contentView.backgroundColor = [UIColor redColor];
        }
        else if (i == 1)
        {
            contentView.backgroundColor = [UIColor blueColor];
        }
        else
        {
            contentView.backgroundColor = [UIColor greenColor];
        }
        
        [_scrollView addSubview:contentView];
    }
    
    [self.view addSubview:_scrollView];
}


@end
