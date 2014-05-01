CoExistOfScrollViewAndBackGesture
=================================
 

【前情回顾】

去年的时候，写了这篇帖子iOS7滑动返回。文中提到，对于多页面结构的应用，可以替换interactivePopGestureRecognizer的delegate以统一管理应用中所有页面滑动返回的开关，比如在UINavigationController的派生类中

 1 //我是一个NavigationController的派生类
 2 - (id)initWithRootViewController:(UIViewController *)rootViewController
 3 {
 4     self = [super initWithRootViewController:rootViewController];
 5     if (self)
 6     {
 7         //在naviVC中统一处理栈中各个vc是否支持滑动返回的情况
 8         //当前仅最底层的vc关闭滑动返回
 9         self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
10     }
11     
12     return self;
13 }
然后在委托中控制滑动返回的开关

 1 - (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
 2 {
 3     if (self.viewControllers.count == 1)//关闭主界面的右滑返回
 4     {
 5         return NO;
 6     }
 7     else
 8     {
 9         return YES;
10     }
11 }
 

【问题所在】

看上去挺美好的。。。。直到遇到了ScrollView。

替换了delegate后，在使用时ScrollView，在屏幕左边缘就无法触发滑动返回效果了，如图



 

【问题原因】

滑动返回事实上也是由存在已久的UIPanGestureRecognizer来识别并响应的，它直接与UINavigationController的view（方便起见，下文中以UINavigationController.view表示）进行绑定，因此上图中存在如下关系：
UIPanGestureRecognizer 　　　　     ——bind——  UIScrollView

UIScreenEdgePanGestureRecognizer ——bind——  UINavigationController.view

滑动返回无法触发，说明UIScreenEdgePanGestureRecognizer并没有接收到手势事件。

 

根据apple君的官方文档，UIGestureRecognizer和UIView是多对一的关系（具体点这里），UIGestureRecognizer一定要和view进行绑定才能发挥作用。因此不难想象，UIGestureRecognizer对于屏幕上的手势事件，其接收顺序和UIView的层次结构是一致的。同样以上图为例

 

(我是Z轴)-------------------------------------------------------------------------------------------------------------------------------------->

 

UINavigationController.view —>  UIViewController.view —>  UIScrollView —>  Screen and User's finger

 

即UIScrollView的panGestureRecognizer先接收到了手势事件，直接就地处理而没有往下传递。

 

实际上这就是两个panGestureRecognizer共存的问题。

 

【解决方案】

苹果以UIGestureRecognizerDelegate的形式，支持多个UIGestureRecognizer共存。其中的一个方法是：

1 // called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
2 // return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
3 //
4 // note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
5 - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
 一句话总结就是此方法返回YES时，手势事件会一直往下传递，不论当前层次是否对该事件进行响应。

 

看看UIScrollView的头文件，有如下描述：

1 // Use these accessors to configure the scroll view's built-in gesture recognizers.
2 // Do not change the gestures' delegates or override the getters for these properties.
3 @property(nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer NS_AVAILABLE_IOS(5_0);
UIScrollView本身是其panGestureRecognizer的delegate，且apple君明确表明不能修改它的delegate（修改的时候也会有警告）。

那么只好曲线救国。

UIScrollView作为delegate，说明UIScrollView中实现了上文提到的shouldRecognizeSimultaneouslyWithGestureRecognizer方法，返回了NO。创建一个UIScrollView的category，由于category中的同名方法会覆盖原有.m文件中的实现，使得可以自定义手势事件的传递，如下：

 1 @implementation UIScrollView (AllowPanGestureEventPass)
 2 
 3 - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
 4 {
 5     if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
 6         && [otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
 7     {
 8         return YES;
 9     }
10     else
11     {
12         return  NO;
13     }
14 }
再次运行demo，看看效果：


嗯，滑动返回已经成功触发，鼓掌！

等会等会。。。

好像不太对。。。

scrollView怎么也滚动了！！！！！

O。。。只是做到了将手势事件往下传递，而没有关闭掉在边缘时UIScrollView对事件的响应。

 

事实上，对UIGestureRecognizer来说，它们对事件的接收顺序和对事件的响应是可以分开设置的，即存在接收链和响应链。接收链如上文所述，和UIView绑定，由UIView的层次决定接收顺序。

而响应链在apple君的定义下，逻辑出奇的简单，只有一个方法可以设置多个gestureRecognizer的响应关系：

// create a relationship with another gesture recognizer that will prevent this gesture's actions from being called until otherGestureRecognizer transitions to UIGestureRecognizerStateFailed
// if otherGestureRecognizer transitions to UIGestureRecognizerStateRecognized or UIGestureRecognizerStateBegan then this recognizer will instead transition to UIGestureRecognizerStateFailed
// example usage: a single tap may require a double tap to fail
- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer;
每个UIGesturerecognizer都是一个有限状态机，上述方法会在两个gestureRecognizer间建立一个依托于state的依赖关系，当被依赖的gestureRecognizer.state = failed时，另一个gestureRecognizer才能对手势进行响应。

 

所以，只需要

[_scrollView.panGestureRecognizer requireGestureRecognizerToFail:screenEdgePanGestureRecognizer];
即可。



再次运行demo，看看效果：

 Works like a Charm！！



P.S：screenEdgePanGestureRecognizer是和UINavigationController.view绑定的，因此可以遍历UINavigationController.view.gestureRecognizers来获取，如下：

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
 

【总结】

写了这么多，只是为了最初统一管理滑动返回的一点点便利，似乎很有些得不偿失。

我并不建议直接在项目中使用这种非常规手段，但使用apple君提供的积木，自己拼出系统中的新功能，也是iOS开发的乐趣之一啊。

demo地址：



 
