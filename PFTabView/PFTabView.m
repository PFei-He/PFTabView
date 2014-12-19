//
//  PFTabView.m
//  PFTabView
//
//  Created by PFei_He on 14-10-24.
//  Copyright (c) 2014年 PF-Lib. All rights reserved.
//
//  https://github.com/PFei-He/PFTabView
//
//  vesion: 0.2.1
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

typedef NSInteger (^numberOfItemBlock)(PFTabView *);
typedef UIViewController *(^viewControllerBlock)(PFTabView *, NSInteger);
typedef CGSize (^textSizeBlock)(PFTabView *);
typedef void (^animationsBlock)(PFTabView *);
typedef void (^resetItemButtonBlock)(PFTabView *, UIButton *, NSInteger);
typedef void (^scrollToEdgeBlock)(PFTabView *, UIPanGestureRecognizer *, NSString *);
typedef void (^didSelectItemBlock)(PFTabView *, NSInteger);

@interface PFTabView () <UIScrollViewDelegate>
{
    UIScrollView    *itemScrollView;        //标签视图
    UIScrollView    *rootScrollView;        //主视图
    UIView          *line;                  //下边线

    NSInteger       selectedItem;           //被选的标签

    CGFloat         itemWidth;              //标签总宽度

    BOOL            isRootScroll;           //是否主视图滑动
}

///标签总数
@property (nonatomic, copy)     numberOfItemBlock       numberOfItemBlock;

///视图控制器
@property (nonatomic, copy)     viewControllerBlock     viewControllerBlock;

///文本尺寸
@property (nonatomic, copy)     textSizeBlock           textSizeBlock;

///动画
@property (nonatomic, copy)     animationsBlock         animationsBlock;

///按钮
@property (nonatomic, copy)     resetItemButtonBlock    resetItemButtonBlock;

///滑动到边缘事件
@property (nonatomic, copy)     scrollToEdgeBlock       scrollToEdgeBlock;

///点击事件
@property (nonatomic, copy)     didSelectItemBlock      didSelectItemBlock;

///代理
@property (nonatomic, weak)     id<PFTabViewDelegate>   delegate;

@end

@implementation PFTabView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame delegate:(id<PFTabViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //标签滚动视图
        [self setupItemScrollView];
        
        //主滚动视图
        [self setupRootScrollView];
        
        //设置代理
        if (delegate) self.delegate = delegate;
        
        //底部边线
        [self setupBottomBorderline];
    }
    return self;
}

#pragma mark - Views Management

//设置标签滚动视图
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

//设置下边线
- (void)setupBottomBorderline
{
    line = [[UIView alloc] initWithFrame:CGRectMake(line.frame.origin.x, itemScrollView.frame.size.height - 0.5f, itemWidth, 0.5f)];
    line.backgroundColor = [UIColor blackColor];
    [itemScrollView addSubview:line];
}

//设置主滚动视图
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
        [rootScrollView.panGestureRecognizer addTarget:self action:@selector(pan:)];
    }
}

#pragma mark - Private Methods

//布局视图
- (void)layoutSubviews
{
    NSInteger number;
    self.delegate?
    (number = [self.delegate numberOfItemInTabView:self]):
    self.numberOfItemBlock?
    (number = self.numberOfItemBlock(self)):
    (NSLog(@"Missing value number of item"));

    CGSize textSize;
    self.delegate?
    (textSize = [self.delegate textSizeOfItemInTabView:self]):
    self.textSizeBlock?
    (textSize = self.textSizeBlock(self)):
    (NSLog(@"Missing value text size"));
    
    //加载子视图
    [self loadSubviewsWithNumber:number textSize:textSize];

    //设置标签视图尺寸
    itemScrollView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, textSize.height);

    //设置主视图尺寸
    rootScrollView.frame = CGRectMake(self.bounds.origin.x, textSize.height, self.bounds.size.width, self.bounds.size.height - textSize.height);

    //设置下边线尺寸
    line.frame = CGRectMake(line.frame.origin.x, itemScrollView.frame.size.height - 0.5f, itemWidth, 0.5f);

    //设置主视图滚动页尺寸
    rootScrollView.contentSize = CGSizeMake(self.bounds.size.width * number, 0);

    //滚动到被选视图
    [rootScrollView setContentOffset:CGPointMake((selectedItem - kTag) * self.bounds.size.width, 0) animated:NO];

    //调整标签被选位置
    UIButton *button = (UIButton *)[itemScrollView viewWithTag:selectedItem];
    [self adjustItemScrollViewPointX:button];
}

//加载子视图
- (void)loadSubviewsWithNumber:(NSInteger)number textSize:(CGSize)textSize
{
    for (int i = 0; i < number; i++) {//加载视图控制器
        UIViewController *viewController = (self.delegate ? [self.delegate tabView:self setupViewControllerAtIndex:i] : self.viewControllerBlock(self, i));
        viewController.view.frame = CGRectMake(0 + rootScrollView.bounds.size.width * i, 0, rootScrollView.bounds.size.width, rootScrollView.bounds.size.height);
        [rootScrollView addSubview:viewController.view];


        //加载标签
        [self loadItemWithViewController:viewController textSize:textSize index:i];
    }
}

//加载标签
- (void)loadItemWithViewController:(UIViewController *)viewController textSize:(CGSize)textSize index:(NSInteger)index;
{
    //设置按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:viewController.title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(itemWidth, 0, textSize.width, textSize.height ? textSize.height : kHeightOfItem);
    button.tag = index + kTag;
    if (index == 0) button.selected = YES;
    
    //重设按钮
    if ([self.delegate respondsToSelector:@selector(tabView:resetItemButton:atIndex:)]) {//监听代理并回调
        [self.delegate tabView:self resetItemButton:button atIndex:index];
    } else if (self.resetItemButtonBlock) {//监听块并回调
        self.resetItemButtonBlock(self, button, index);
    }
    [itemScrollView addSubview:button];
    
    //标签总宽度
    itemWidth += textSize.width;
    
    //设置顶部滚动视图内容页尺寸
    itemScrollView.contentSize = CGSizeMake(itemWidth, textSize.height ? textSize.height : kHeightOfItem);
}

//调整标签视图的x坐标
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

#pragma mark -

//标签总数
- (void)numberOfItemUsingBlock:(NSInteger (^)(PFTabView *tabView))block;
{
    if (block) self.numberOfItemBlock = block;
}

//视图控制器
- (void)setupViewControllerUsingBlock:(UIViewController *(^)(PFTabView *, NSInteger))block
{
    if (block) self.viewControllerBlock = block;
}

//文本尺寸
- (void)textSizeOfItemUsingBlock:(CGSize (^)(PFTabView *))block
{
    if (block) self.textSizeBlock = block;
}

//动画效果
- (void)animationsWhenItemWillSelectUsingBlock:(void (^)(PFTabView *))block
{
    if (block) self.animationsBlock = block;
}

//按钮
- (void)resetItemButtonUsingBlock:(void (^)(PFTabView *, UIButton *, NSInteger))block
{
    if (block) self.resetItemButtonBlock = block;
}

//滑动到边缘
- (void)scrollViewDidScrollToEdgeUsingBlock:(void (^)(PFTabView *, UIPanGestureRecognizer *, NSString *))block
{
    if (block) self.scrollToEdgeBlock = block;
}

//点击标签
- (void)didSelectItemUsingBlock:(void (^)(PFTabView *, NSInteger))block
{
    if (block) self.didSelectItemBlock = block;
}

#pragma mark - Events Management

//点击标签的按钮
- (void)buttonTapped:(UIButton *)button
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
            //动画效果
            if ([self.delegate respondsToSelector:@selector(animationsWhenItemWillSelectInTabView:)]) {
                [self.delegate animationsWhenItemWillSelectInTabView:self];
            } else if (self.animationsBlock) {
                self.animationsBlock(self);
            }
        } completion:^(BOOL finished) {
            if (finished) {
                if (!isRootScroll) {//设置新标签页出现
                    [rootScrollView setContentOffset:CGPointMake((button.tag - kTag) * self.bounds.size.width, 0) animated:YES];
                }
                isRootScroll = NO;

                //响应点击事件
                if ([self.delegate respondsToSelector:@selector(tabView:didSelectItemAtIndex:)]) {//监听代理并回调
                    [self.delegate tabView:self didSelectItemAtIndex:selectedItem - kTag];
                } else if (self.didSelectItemBlock) {//监听块并回调
                    self.didSelectItemBlock(self, selectedItem - kTag);
                }
            }
        }];
    } else {//重复点击选中按钮

    }
}

//滑动事件
-(void)pan:(UIPanGestureRecognizer *)recognizer
{
    if (rootScrollView.contentOffset.x <= 0) {//滑道左边缘时
        if ([self.delegate respondsToSelector:@selector(tabView:scrollViewDidScrollToEdgeWithRecognizer:orientation:)]) {//监听代理并回调
            [self.delegate tabView:self scrollViewDidScrollToEdgeWithRecognizer:recognizer orientation:@"left"];
        } else if (self.scrollToEdgeBlock) {//监听块并回调
            self.scrollToEdgeBlock(self, recognizer, @"left");
        }
    } else if (rootScrollView.contentOffset.x >= rootScrollView.contentSize.width - rootScrollView.bounds.size.width) {//滑道右边缘时
        if ([self.delegate respondsToSelector:@selector(tabView:scrollViewDidScrollToEdgeWithRecognizer:orientation:)]) {//监听代理并回调
            [self.delegate tabView:self scrollViewDidScrollToEdgeWithRecognizer:recognizer orientation:@"right"];
        } else if (self.scrollToEdgeBlock) {//监听块并回调
            self.scrollToEdgeBlock(self, recognizer, @"right");
        }
    }
}

#pragma mark - UIScrollViewDelegate

//停止减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == rootScrollView) {
        //设置为主视图滚动
        isRootScroll = YES;
        
        //调整顶部滑条按钮状态
        UIButton *button = (UIButton *)[itemScrollView viewWithTag:(NSInteger)scrollView.contentOffset.x / self.bounds.size.width + kTag];
        [self buttonTapped:button];
    }
}

#pragma mark - Memory Management

- (void)dealloc
{
#if __has_feature(objc_arc)
    self.numberOfItemBlock      = nil;
    self.viewControllerBlock    = nil;
    self.textSizeBlock          = nil;
    self.animationsBlock        = nil;
    self.resetItemButtonBlock   = nil;
    self.scrollToEdgeBlock      = nil;
    self.didSelectItemBlock     = nil;
    
    self.delegate               = nil;
#else
#endif
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
