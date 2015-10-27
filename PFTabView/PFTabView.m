//
//  PFTabView.m
//  PFTabView
//
//  Created by PFei_He on 14-10-24.
//  Copyright (c) 2014年 PF-Lib. All rights reserved.
//
//  https://github.com/PFei-He/PFTabView
//
//  vesion: 0.4.0-beta
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

#import "PFTabView.h"

static const CGFloat kHeightOfItem = 44.0f;
static const NSUInteger kTag = 88888888;

typedef NSInteger(^block1)();
typedef CGSize(^block2)();
typedef UIViewController *(^block3)();
typedef void(^block4)();

@interface PFTabView () <UIScrollViewDelegate>
{
    UIScrollView    *itemScrollView;        //标签视图
    UIScrollView    *rootScrollView;        //主视图

    NSInteger       selectedItem;           //被选的标签

    CGFloat         itemWidth;              //标签总宽度

    BOOL            isRootScroll;           //是否主视图滑动
}

///标签总数
@property (copy, nonatomic) block1 numberBlock;
///标签尺寸
@property (copy, nonatomic) block2 sizeBlock;
///视图控制器
@property (copy, nonatomic) block3 viewControllerBlock;
///标签切换动画
@property (copy, nonatomic) block4 animationsBlock;
///标签按钮
@property (copy, nonatomic) block4 buttonBlock;
///滑动到边缘事件
@property (copy, nonatomic) block4 scrollToEdgeBlock;
///点击
@property (copy, nonatomic) block4 didSelectBlock;
///重复点击
@property (copy, nonatomic) block4 repeatSelectBlock;

@end

@implementation PFTabView

#pragma mark - Views Management

///设置标签滚动视图
- (void)setupItemScrollView
{
    if (!itemScrollView) {
        itemScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, kHeightOfItem)];
        itemScrollView.delegate = self;
        itemScrollView.pagingEnabled = NO;
        itemScrollView.backgroundColor = [UIColor clearColor];
        itemScrollView.showsHorizontalScrollIndicator = NO;
        itemScrollView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth;
        [self addSubview:itemScrollView];
    }
    
    //标记被选标签
    selectedItem = kTag;
}

///设置主滚动视图
- (void)setupRootScrollView
{
    if (!rootScrollView) {
        rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, kHeightOfItem, self.bounds.size.width, self.bounds.size.height - kHeightOfItem)];
        rootScrollView.delegate = self;
        rootScrollView.pagingEnabled = YES;
        rootScrollView.userInteractionEnabled = YES;
        rootScrollView.bounces = NO;
        rootScrollView.showsHorizontalScrollIndicator = NO;
        rootScrollView.showsVerticalScrollIndicator = NO;
        rootScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:rootScrollView];
        
        //添加滑动事件
        [rootScrollView.panGestureRecognizer addTarget:self action:@selector(panAction:)];
    }
}

///设置下边线
- (void)setupBottomBorderline
{
    _bottomBorderline = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, itemScrollView.frame.size.height - 10.f, itemWidth, 2.f)];
    _bottomBorderline.backgroundColor = [UIColor blackColor];
    [itemScrollView addSubview:_bottomBorderline];
}

#pragma mark - Events Management

//点击标签的按钮
- (void)buttonAction:(UIButton *)button
{
    //如果点击的标签文字显示不全，调整滚动视图x坐标使用使标签文字显示完整
    [self adjustItemScrollViewPointX:button];
    
    //如果更换按钮
    if (button.tag != selectedItem) {
        //取之前的按钮
        UIButton *lastButton = (UIButton *)[itemScrollView viewWithTag:selectedItem];
        lastButton.selected = NO;
        //赋值按钮ID
        selectedItem = button.tag;
    }
    
    if (!button.selected) {//按钮选中状态
        button.selected = YES;
        
        [UIView animateWithDuration:0.25 animations:^{
            kCALLBACK1(animationsWhenItemWillSelectInTabView:, self, self.animationsBlock)
        } completion:^(BOOL finished) {
            if (finished) {
                if (!isRootScroll) {//设置新标签页出现
                    [rootScrollView setContentOffset:CGPointMake((button.tag - kTag) * self.bounds.size.width, 0) animated:YES];
                }
                isRootScroll = NO;
                
                kCALLBACK2(tabView:, self, didSelectItemAtIndex:, selectedItem - kTag, self.didSelectBlock)
            }
        }];
    } else {//重复点击选中按钮
        kCALLBACK2(tabView:, self, repeatSelectItemAtIndex:, selectedItem - kTag, self.repeatSelectBlock)
    }
}

//滑动事件
-(void)panAction:(UIPanGestureRecognizer *)recognizer
{
    if (rootScrollView.contentOffset.x <= 0) {//滑道左边缘时
        kCALLBACK3(tabView:, self, scrollViewDidScrollToEdgeWithRecognizer:, recognizer, orientation:, @"left", self.scrollToEdgeBlock)
    } else if (rootScrollView.contentOffset.x >= rootScrollView.contentSize.width - rootScrollView.bounds.size.width) {//滑道右边缘时
        kCALLBACK3(tabView:, self, scrollViewDidScrollToEdgeWithRecognizer:, recognizer, orientation:, @"right", self.scrollToEdgeBlock)
    }
}

#pragma mark - Private Methods

//即将加载到父视图
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    UIViewController *controller;
    UIResponder *responder = newSuperview.nextResponder;
    if ([responder isKindOfClass:[UIViewController class]]) {
        controller = (UIViewController *)responder;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
#else
    //取消全屏效果
    if ([controller respondsToSelector:@selector(edgesForExtendedLayout)])
        controller.edgesForExtendedLayout = UIRectEdgeNone;
#endif
}

//布局视图
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setupItemScrollView];
    [self setupRootScrollView];
    [self setupBottomBorderline];
    
    NSInteger number = 0;//标签总数
    kCALLBACK4(numberOfItemInTabView:, self, self.numberBlock, number, {
        NSLog(@"Missing value number of item");
        return;
    })
    
    CGSize size;//标签尺寸
    kCALLBACK4(sizeOfItemInTabView:, self, self.sizeBlock, size, {
        NSLog(@"Missing value size of item");
        return;
    })
    
    //加载子视图
    [self loadSubviewsWithNumber:number size:size];

    itemScrollView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, size.height);
    rootScrollView.frame = CGRectMake(self.bounds.origin.x, size.height, self.bounds.size.width, self.bounds.size.height - size.height);
    rootScrollView.contentSize = CGSizeMake(self.bounds.size.width * number, 0);
    rootScrollView.contentOffset = CGPointMake((selectedItem - kTag) * self.bounds.size.width, 0);
//    _bottomBorderline.frame = CGRectMake(_bottomBorderline.frame.origin.x, itemScrollView.frame.size.height - 0.5f, itemWidth, 0.5f);

    UIButton *button = (UIButton *)[itemScrollView viewWithTag:selectedItem];
    [self adjustItemScrollViewPointX:button];
}

///加载子视图
- (void)loadSubviewsWithNumber:(NSInteger)number size:(CGSize)textSize
{
    for (int i = 0; i < number; i++) {//加载视图控制器
        UIViewController *viewController;
        kCALLBACK5(tabView:, self, setupViewControllerAtIndex:, i, self.viewControllerBlock, viewController, {
            NSLog(@"Missing value view controller");
            return;
        })
        viewController.view.frame = CGRectMake(0 + rootScrollView.bounds.size.width * i, 0, rootScrollView.bounds.size.width, rootScrollView.bounds.size.height);
        [rootScrollView addSubview:viewController.view];

        [self loadItemWithViewController:viewController textSize:textSize index:i];
    }
}

///加载标签
- (void)loadItemWithViewController:(UIViewController *)viewController textSize:(CGSize)textSize index:(NSInteger)index;
{
    //设置按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:viewController.title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(itemWidth, 0, textSize.width, textSize.height ? textSize.height : kHeightOfItem);
    button.tag = index + kTag;
    if (index == 0) button.selected = YES;
    
    kCALLBACK3(tabView:, self, resetItemButton:, button, atIndex:, index, self.buttonBlock)
    
    [itemScrollView addSubview:button];
    
    //标签总宽度
    itemWidth += textSize.width;
    
    //设置顶部滚动视图内容页尺寸
    itemScrollView.contentSize = CGSizeMake(itemWidth, textSize.height ? textSize.height : kHeightOfItem);
}

///调整标签视图的x坐标
- (void)adjustItemScrollViewPointX:(UIButton *)button
{
    //标签文字超出右边界
    if (button.frame.origin.x - itemScrollView.contentOffset.x > self.bounds.size.width - button.bounds.size.width) {
        //向左滚动视图，显示完整标签文字
        [itemScrollView setContentOffset:CGPointMake(button.frame.origin.x - (itemScrollView.bounds.size.width - button.bounds.size.width), 0) animated:YES];
    }
    //如果（标签的文字坐标 - 当前滚动视图左边界所在整个视图的x坐标）< 按钮的隔间 ，代表标签文字已超出边界
    if (button.frame.origin.x - itemScrollView.contentOffset.x < 0.0f) {
        //向右滚动视图（标签文字的x坐标 - 按钮间隔 = 新的滚动视图左边界在整个视图的x坐标），显示完整标签文字
        [itemScrollView setContentOffset:CGPointMake(button.frame.origin.x, 0)  animated:YES];
    }
}

#pragma mark - Public Methods

//通过16进制计算颜色
+ (UIColor *)colorFromHexRGB:(NSString *)string
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;

    if (nil != string) {
        NSScanner *scanner = [NSScanner scannerWithString:string];
        (void) [scanner scanHexInt:&colorCode]; //忽略错误
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); //屏蔽高位色
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte / 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

kBLOCK1(numberOfItem, NSInteger, void, self.numberBlock, nil)
kBLOCK1(setupViewController, UIViewController *, NSInteger, self.viewControllerBlock, nil)
kBLOCK1(sizeOfItem, CGSize, void, self.sizeBlock, nil)
kBLOCK1(animationsWhenItemWillSelect, void, void, self.animationsBlock, nil)
kBLOCK2(resetItemButton, void, UIButton *, NSInteger, self.buttonBlock, nil)
kBLOCK2(scrollViewDidScrollToEdge, void, UIPanGestureRecognizer *, NSString *, self.scrollToEdgeBlock, nil)
kBLOCK1(didSelectItem, void, NSInteger, self.didSelectBlock, nil)
kBLOCK1(repeatSelectItem, void, NSInteger, self.repeatSelectBlock, nil)

#pragma mark - UIScrollViewDelegate Methods

//停止减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == rootScrollView) {
        //设置为主视图滚动
        isRootScroll = YES;
        
        //调整顶部滑条按钮状态
        UIButton *button = (UIButton *)[itemScrollView viewWithTag:(NSInteger)scrollView.contentOffset.x / self.bounds.size.width + kTag];
        [self buttonAction:button];
    }
}

@end
