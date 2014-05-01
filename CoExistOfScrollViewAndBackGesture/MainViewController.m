//
//  MainViewController.m
//  CoExistOfScrollViewAndBackGesture
//
//  Created by 乐星宇 on 14-5-1.
//  Copyright (c) 2014年 Lxy. All rights reserved.
//

#import "MainViewController.h"
#import "ViewController.h"


@interface MainViewController ()<UIGestureRecognizerDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    UIButton *hintButton = [[UIButton alloc] initWithFrame:self.view.bounds];
    [hintButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [hintButton setTitle:@"点我进下一级测试滑动返回" forState:UIControlStateNormal];
    [hintButton addTarget:self action:@selector(enterScrollVC) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:hintButton];
}

- (void)enterScrollVC
{
    ViewController *vc = [[ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.navigationController.viewControllers.count > 1)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
