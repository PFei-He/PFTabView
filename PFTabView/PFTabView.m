//
//  PFTabView.m
//  PFTabView
//
//  Created by PFei_He on 14-10-24.
//  Copyright (c) 2014年 PF-Lib. All rights reserved.
//
//  https://github.com/PFei-He/PFTabView
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

/**
 *  自动生成.m文件的代码块方法
 *  参数：
 *  __name__:       方法名
 *  __returned__:   返回值
 *  __class__:      需要传递的参数的类名
 *  __block__:      接收的代码块
 *  __statement__:  代码块方法执行的代码（建议只执行简单代码）
 *
 *  示例：
 *  kBLOCK1(name, void, NSString *, b, do something...)
 */
#define kBLOCK1(__name__, __returned__, __class__, __block__, __statement__)\
- (void)__name__##UsingBlock:(__returned__ (^)(__class__))block\
{\
    __block__ = block;\
    __statement__;\
}

/**
 *  自动生成.m文件的代码块方法
 *  参数：
 *  __name__:       方法名
 *  __returned__:   返回值
 *  __class1__:     需要传递的参数的类名
 *  __class2__:     需要传递的参数的类名
 *  __block__:      接收的代码块
 *  __statement__:  代码块方法执行的代码（建议只执行简单代码）
 *
 *  示例：
 *  kBLOCK2(name, void, NSString *, NSString*, b, do something...)
 */
#define kBLOCK2(__name__, __returned__, __class1__, __class2__, __block__, __statement__)\
- (void)__name__##UsingBlock:(__returned__ (^)(__class1__, __class2__))block\
{\
    __block__ = block;\
    __statement__;\
}

static const CGFloat kHeightOfItem = 44.0f;
static const NSUInteger kTag = 88888888;

typedef NSInteger(^block1)();
typedef CGSize(^block2)();
typedef UIView *(^block3)();
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
@property (nonatomic, copy) block1 numberBlock;
///视图控制器
@property (nonatomic, copy) block3 viewBlock;
///文本尺寸
@property (nonatomic, copy) block2 sizeBlock;
///动画
@property (nonatomic, copy) block4 animationsBlock;
///按钮
@property (nonatomic, copy) block4 itemBlock;
///滑动到边缘事件
@property (nonatomic, copy) block4 scrollToEdgeBlock;
///点击事件
@property (nonatomic, copy) block4 didSelectBlock;

@end

@implementation PFTabView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //标签滚动视图
        [self setupItemScrollView];
        
        //主滚动视图
        [self setupRootScrollView];
        
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
    _bottomBorderline = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, itemScrollView.frame.size.height - 0.5f, itemWidth, 0.5f)];
    _bottomBorderline.backgroundColor = [UIColor blackColor];
    [itemScrollView addSubview:_bottomBorderline];
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

//加载子视图
- (void)loadSubviewsWithNumber:(NSInteger)number textSize:(CGSize)textSize
{
    for (int i = 0; i < number; i++) {//加载视图控制器
        UIView *view;
        if ([self.delegate respondsToSelector:@selector(tabView:viewForItemAtIndex:)]) {
            view = [self.delegate tabView:self viewForItemAtIndex:i];
        } else if (self.viewBlock) {
            view = self.viewBlock(i);
        } else {
            NSLog(@"Missing value view controller");
            return;
        }
        view.frame = CGRectMake(0 + rootScrollView.bounds.size.width * i, 0, rootScrollView.bounds.size.width, rootScrollView.bounds.size.height);
        [rootScrollView addSubview:view];
        
        //加载标签
        [self loadItemWithViewController:view textSize:textSize index:i];
    }
}

//加载标签
- (void)loadItemWithViewController:(UIView *)view textSize:(CGSize)textSize index:(NSInteger)index;
{
    //设置标签
    UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
    [item setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [item setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [item addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    item.frame = CGRectMake(itemWidth, 0, textSize.width, textSize.height ? textSize.height : kHeightOfItem);
    item.tag = index + kTag;
    if (index == 0) item.selected = YES;
    
    //重设按钮
    if ([self.delegate respondsToSelector:@selector(tabView:resetItem:atIndex:)]) {//监听代理并回调
        [self.delegate tabView:self resetItem:item atIndex:index];
    } else if (self.itemBlock) {//监听块并回调
        self.itemBlock(item, index);
    }
    [itemScrollView addSubview:item];
    
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

//打开标签
- (void)open
{
    NSInteger number = 0;//总数
    if ([self.delegate respondsToSelector:@selector(numberOfItemInTabView:)]) {
        number = [self.delegate numberOfItemInTabView:self];
    } else if (self.numberBlock) {
        number = self.numberBlock();
    } else {
        NSLog(@"Missing value number of item");
        return;
    }
    
    CGSize size;//标签尺寸
    if ([self.delegate respondsToSelector:@selector(sizeOfItemInTabView:)]) {
        size = [self.delegate sizeOfItemInTabView:self];
    } else if (self.sizeBlock) {
        size = self.sizeBlock();
    } else {
        NSLog(@"Missing value text size");
        return;
    }
    
    //加载子视图
    [self loadSubviewsWithNumber:number textSize:size];
    
    //设置标签视图尺寸
    itemScrollView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, size.height);
    
    //设置主视图尺寸
    rootScrollView.frame = CGRectMake(self.bounds.origin.x, size.height, self.bounds.size.width, self.bounds.size.height - size.height);
    
    //设置下边线尺寸
    _bottomBorderline.frame = CGRectMake(_bottomBorderline.frame.origin.x, itemScrollView.frame.size.height - 0.5f, itemWidth, 0.5f);
    
    //设置主视图滚动页尺寸
    rootScrollView.contentSize = CGSizeMake(self.bounds.size.width * number, 0);
    
    //滚动到被选视图
    [rootScrollView setContentOffset:CGPointMake((selectedItem - kTag) * self.bounds.size.width, 0) animated:NO];
    
    //调整标签被选位置
    UIButton *button = (UIButton *)[itemScrollView viewWithTag:selectedItem];
    [self adjustItemScrollViewPointX:button];
}

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

//版本号
- (NSString *)version
{
    return [NSString stringWithFormat:@"[ %@ ] current version: 0.4.0-beta3", self.classForCoder];
}

#pragma mark -

kBLOCK1(numberOfItem, NSInteger, void, self.numberBlock, nil)
kBLOCK1(viewForItem, UIView *, NSInteger, self.viewBlock, nil)
kBLOCK1(sizeOfItem, CGSize, void, self.sizeBlock, nil)
kBLOCK1(animationsWhenItemWillSelect, void, void, self.animationsBlock, nil)
kBLOCK2(resetItem, void, UIButton *, NSInteger, self.itemBlock, nil)
kBLOCK2(scrollViewDidScrollToEdge, void, UIPanGestureRecognizer *, NSString *, self.scrollToEdgeBlock, nil)
kBLOCK1(didSelectItem, void, NSInteger, self.didSelectBlock, nil)

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
                self.animationsBlock();
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
                } else if (self.didSelectBlock) {//监听块并回调
                    self.didSelectBlock(selectedItem - kTag);
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
            self.scrollToEdgeBlock(recognizer, @"left");
        }
    } else if (rootScrollView.contentOffset.x >= rootScrollView.contentSize.width - rootScrollView.bounds.size.width) {//滑道右边缘时
        if ([self.delegate respondsToSelector:@selector(tabView:scrollViewDidScrollToEdgeWithRecognizer:orientation:)]) {//监听代理并回调
            [self.delegate tabView:self scrollViewDidScrollToEdgeWithRecognizer:recognizer orientation:@"right"];
        } else if (self.scrollToEdgeBlock) {//监听块并回调
            self.scrollToEdgeBlock(recognizer, @"right");
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

@end
