//
//  PFTabView.m
//  PFTabView
//
//  Created by PFei_He on 14-10-24.
//  Copyright (c) 2014年 PFei_He. All rights reserved.
//

#import "PFTabView.h"

static const CGFloat kHeightOfItem = 44.0f;
static const CGFloat kWidthOfButton = 7.0f;
static const CGFloat kFontSizeOfItemButton = 17.0f;
static const NSUInteger kTagOfMoreButton = 999;

//标签个数
typedef NSUInteger (^numberOfItemBlock)(PFTabView *);

//视图控制器
typedef UIViewController *(^viewControllerOfItemBlock)(PFTabView *, NSUInteger);

//文本尺寸
typedef CGSize (^textSizeOfItemBlock)(PFTabView *);

//滑动到边缘事件
typedef void (^slideToEdgeBlock)(PFTabView *, UIPanGestureRecognizer *);

//点击事件
typedef void (^didSelectItemBlock)(PFTabView *, NSUInteger);

@interface PFTabView () <UIScrollViewDelegate>
{
    UIScrollView    *rootScrollView;        //主视图
    UIScrollView    *itemScrollView;        //标签视图
    UIImageView     *shadowImageView;       //阴影图层
    UIImage         *shadowImage;           //阴影图片

    NSMutableArray  *viewsArray;            //子视图数组
    NSInteger       selectedItem;           //被选的标签

    CGFloat         contentOffsetX;         //内容位移的x坐标

    BOOL            isLeftScroll;           //是否左滑动
    BOOL            isRootScroll;           //是否主视图滑动
    BOOL            isLoadSubviews;         //是否加载了子视图
}

///标签个数
@property (nonatomic, copy) numberOfItemBlock           numberOfItemBlock;

///视图控制器
@property (nonatomic, copy) viewControllerOfItemBlock   viewControllerOfItemBlock;

///文本尺寸
@property (nonatomic, copy) textSizeOfItemBlock         textSizeOfItemBlock;

///滑动到左边缘事件
@property (nonatomic, copy) slideToEdgeBlock            slideToLeftEdgeBlock;

///滑动到右边缘事件
@property (nonatomic, copy) slideToEdgeBlock            slideToRightEdgeBlock;

///点击事件
@property (nonatomic, copy) didSelectItemBlock          didSelectItemBlock;

@end

@implementation PFTabView

- (id)initWithFrame:(CGRect)frame delegate:(id<PFTabViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {

        //标签滚动视图
        itemScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, kHeightOfItem)];
        itemScrollView.delegate = self;
        itemScrollView.pagingEnabled = NO;
        itemScrollView.backgroundColor = [UIColor clearColor];
        itemScrollView.showsHorizontalScrollIndicator = NO;
        itemScrollView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth;
        [self addSubview:itemScrollView];

        //标记被选的标签为100
        selectedItem = 100;

        //主滚动视图
        rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, kHeightOfItem, self.bounds.size.width, self.bounds.size.height - kHeightOfItem)];
        rootScrollView.delegate = self;
        rootScrollView.pagingEnabled = YES;
        rootScrollView.userInteractionEnabled = YES;
        rootScrollView.bounces = NO;
        rootScrollView.showsHorizontalScrollIndicator = NO;
        rootScrollView.showsVerticalScrollIndicator = NO;
        rootScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        contentOffsetX = 0;
        [self addSubview:rootScrollView];

        //视图数组
        viewsArray = [[NSMutableArray alloc] init];

        //设置为未加载了子视图
        isLoadSubviews = NO;

        //添加滑动事件
        [rootScrollView.panGestureRecognizer addTarget:self action:@selector(slideToEdge:)];

        //设置代理
        if (delegate) self.delegate = delegate;
    }
    return self;
}

#pragma mark - Property Methods

//标签高度的setter方法
- (void)setHeightOfItem:(CGFloat)heightOfItem
{
    if (heightOfItem) {
        _heightOfItem = heightOfItem;
        itemScrollView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, heightOfItem);
        rootScrollView.frame = CGRectMake(self.bounds.origin.x, heightOfItem, self.bounds.size.width, self.bounds.size.height - heightOfItem);
    }
}

//更多按钮的Setter方法
- (void)setMoreButton:(UIButton *)moreButton
{
    UIButton *button = (UIButton *)[self viewWithTag:kTagOfMoreButton];
    [button removeFromSuperview];
    if (NULL == moreButton) return;
    moreButton.tag = kTagOfMoreButton;
    _moreButton = moreButton;
    [self addSubview:_moreButton];
}

#pragma mark - Public Methods

//加载子视图
- (void)loadSubviews
{
    //设置视图数
    NSUInteger number;
    if (!self.delegate && self.numberOfItemBlock) number = self.numberOfItemBlock(self);
    else number = [self.delegate numberOfItemInTabView:self];

    for (int i = 0; i < number; i++) {
        //加载视图控制器
        UIViewController *vc;
        if (!self.delegate && self.viewControllerOfItemBlock) vc = self.viewControllerOfItemBlock(self, i);
        else vc = [self.delegate tabView:self viewControllerOfItemAtIndex:i];
        [viewsArray addObject:vc];
        [rootScrollView addSubview:vc.view];
    }

    //加载标签
    [self loadItem];

    //设置为已加载子视图
    isLoadSubviews = YES;

    //创建子视图完成后调整布局
    [self setNeedsDisplay];
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

//标签的个数
- (void)numberOfItemInTabViewUsingBlock:(NSUInteger (^)(PFTabView *))block
{
    if (block) self.numberOfItemBlock = block, block = nil;
}

//设置视图控制器
- (void)viewControllerOfItemAtIndexUsingBlock:(UIViewController *(^)(PFTabView *, NSUInteger))block
{
    if (block) self.viewControllerOfItemBlock = block, block = nil;
}

//调整文本尺寸
- (void)textSizeOfItemInTabViewUsingBlock:(CGSize (^)(PFTabView *))block
{
    if (block) self.textSizeOfItemBlock = block, block = nil;
}

//滑动到左边缘事件
- (void)slideToLeftEdgeUsingBlock:(void (^)(PFTabView *, UIPanGestureRecognizer *))block
{
    if (block) self.slideToLeftEdgeBlock = block, block = nil;
}

//滑动到右边缘事件
- (void)slideToRightEdgeUsingBlock:(void (^)(PFTabView *, UIPanGestureRecognizer *))block
{
    if (block) self.slideToRightEdgeBlock = block, block = nil;
}

//点击标签事件
- (void)didSelectItemAtIndexUsingBlock:(void (^)(PFTabView *, NSUInteger))block
{
    if (block) self.didSelectItemBlock = block, block = nil;
}

#pragma mark - Private Methods

//设置视图（此方法会被执行多次，当横竖屏切换时可通过此方法调整布局）
- (void)layoutSubviews
{
    //子视图加载后调整布局
    if (isLoadSubviews) {
        //如果有设置右侧视图，缩小顶部滚动视图的宽度以适应按钮
        if (self.moreButton.bounds.size.width > 0) {
            self.moreButton.frame = CGRectMake(self.bounds.size.width - self.moreButton.bounds.size.width, 0, self.moreButton.bounds.size.width, self.moreButton.bounds.size.height);
            if (!self.heightOfItem) itemScrollView.frame = CGRectMake(0, 0, self.bounds.size.width - self.moreButton.bounds.size.width, kHeightOfItem);
            else itemScrollView.frame = CGRectMake(0, 0, self.bounds.size.width - self.moreButton.bounds.size.width, self.heightOfItem);
        }

        //更新主视图的总宽度
        rootScrollView.contentSize = CGSizeMake(self.bounds.size.width * viewsArray.count, 0);

        //更新主视图各个子视图的宽度
        for (int i = 0; i < [viewsArray count]; i++) {
            UIViewController *listVC = viewsArray[i];
            listVC.view.frame = CGRectMake(0 + rootScrollView.bounds.size.width * i, 0, rootScrollView.bounds.size.width, rootScrollView.bounds.size.height);
        }

        //滚动到选中的视图
        [rootScrollView setContentOffset:CGPointMake((selectedItem - 100)*self.bounds.size.width, 0) animated:NO];

        //调整标签到选中的位置
        UIButton *button = (UIButton *)[itemScrollView viewWithTag:selectedItem];
        [self adjustItemScrollViewPointX:button];
    }
}

//加载标签
- (void)loadItem
{
    //下边框着色
    UIImageView *bottomBorderImageView = [[UIImageView alloc] init];
    float height = itemScrollView.frame.size.height - 0.5f;
    float width = itemScrollView.frame.size.width;
    bottomBorderImageView.frame = CGRectMake(0, height, width, 0.5f);
    bottomBorderImageView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0f];
    [itemScrollView addSubview:bottomBorderImageView];

    //阴影图层
    shadowImageView = [[UIImageView alloc] init];
    [shadowImageView setImage:shadowImage];
    [itemScrollView addSubview:shadowImageView];

    //标签长度
    CGFloat itemWidth = kWidthOfButton;

    //位移长度
    CGFloat xOffset = kWidthOfButton;

    //自定义文本尺寸
    CGSize textSize;
    if (!self.delegate && self.textSizeOfItemBlock) {//监听块并回调
        textSize = self.textSizeOfItemBlock(self);
    } else if ([self.delegate respondsToSelector:@selector(textSizeOfItemInTabView:)]) {//监听代理并回调
        textSize = [self.delegate textSizeOfItemInTabView:self];
    } else {
        if (!self.heightOfItem) textSize = CGSizeMake(320 / 4, kHeightOfItem);
        else textSize = CGSizeMake(320 / 4, self.heightOfItem);
    }

    for (int i = 0; i < viewsArray.count; i++) {
        UIViewController *vc = viewsArray[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

        //累计每个标签文字的长度
        itemWidth += kWidthOfButton + textSize.width;

        //设置按钮尺寸
        if (!self.heightOfItem) button.frame = CGRectMake(xOffset, 0, textSize.width, kHeightOfItem);
        else button.frame = CGRectMake(xOffset, 0, textSize.width, self.heightOfItem);

        //计算下一个标签的位移
        xOffset += kWidthOfButton + textSize.width;

        //设置按钮的标记值
        button.tag = i + 100;

        if (i == 0) {
            shadowImageView.frame = CGRectMake(kWidthOfButton, 0, textSize.width, shadowImage.size.height);
            button.selected = YES;
        }
        [button setTitle:vc.title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:kFontSizeOfItemButton];
        [button setTitleColor:self.itemNormalColor forState:UIControlStateNormal];
        [button setTitleColor:self.itemSelectedColor forState:UIControlStateSelected];
        [button setBackgroundImage:self.itemNormalBackgroundImage forState:UIControlStateNormal];
        [button setBackgroundImage:self.itemSelectedBackgroundImage forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [itemScrollView addSubview:button];
    }
    //设置顶部滚动视图的内容总尺寸
    if (!self.heightOfItem) itemScrollView.contentSize = CGSizeMake(itemWidth, kHeightOfItem);
    else itemScrollView.contentSize = CGSizeMake(itemWidth, self.heightOfItem);
}

//调整标签视图的x坐标
- (void)adjustItemScrollViewPointX:(UIButton *)button
{
    //如果 当前显示的最后一个标签文字超出右边界
    if (button.frame.origin.x - itemScrollView.contentOffset.x > self.bounds.size.width - (kWidthOfButton + button.bounds.size.width)) {
        //向左滚动视图，显示完整标签文字
        [itemScrollView setContentOffset:CGPointMake(button.frame.origin.x - (itemScrollView.bounds.size.width -  (kWidthOfButton + button.bounds.size.width)), 0)  animated:YES];
    }

    //如果（标签的文字坐标 - 当前滚动视图左边界所在整个视图的x坐标）< 按钮的隔间 ，代表标签文字已超出边界
    if (button.frame.origin.x - itemScrollView.contentOffset.x < kWidthOfButton) {
        //向右滚动视图（标签文字的x坐标 - 按钮间隔 = 新的滚动视图左边界在整个视图的x坐标），显示完整标签文字
        [itemScrollView setContentOffset:CGPointMake(button.frame.origin.x - kWidthOfButton, 0)  animated:YES];
    }
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

    //按钮选中状态
    if (!button.selected) {
        button.selected = YES;

        [UIView animateWithDuration:0.25 animations:^{
            [shadowImageView setFrame:CGRectMake(button.frame.origin.x, 0, button.frame.size.width, shadowImage.size.height)];
        } completion:^(BOOL finished) {
            if (finished) {
                //设置新标签页出现
                if (!isRootScroll) {
                    [rootScrollView setContentOffset:CGPointMake((button.tag - 100) * self.bounds.size.width, 0) animated:YES];
                }
                isRootScroll = NO;

                //响应点击事件
                if (!self.delegate && self.didSelectItemBlock) {//监听块并回调
                    self.didSelectItemBlock(self, selectedItem - 100);
                } else if ([self.delegate respondsToSelector:@selector(tabView:didSelectItemAtIndex:)]) {//监听代理并回调
                    [self.delegate tabView:self didSelectItemAtIndex:selectedItem - 100];
                }
            }
        }];
    }
    //重复点击选中按钮
    else {

    }
}

//传递滑动事件
-(void)slideToEdge:(UIPanGestureRecognizer *)recognizer
{
    //当滑道左边缘时
    if (rootScrollView.contentOffset.x <= 0) {
        if (!self.delegate && self.slideToLeftEdgeBlock) {//监听块并回调
            self.slideToLeftEdgeBlock(self, recognizer);
        } else if ([self.delegate respondsToSelector:@selector(tabView:slideToLeftEdge:)]) {//监听代理并回调
            [self.delegate tabView:self slideToLeftEdge:recognizer];
        }
    }

    //当滑道右边缘时
    else if (rootScrollView.contentOffset.x >= rootScrollView.contentSize.width - rootScrollView.bounds.size.width) {
        if (!self.delegate && self.slideToRightEdgeBlock) {//监听块并回调
            self.slideToRightEdgeBlock(self, recognizer);
        } else if ([self.delegate respondsToSelector:@selector(tabView:slideToRightEdge:)]) {//监听代理并回调
            [self.delegate tabView:self slideToRightEdge:recognizer];
        }
    }
}

#pragma mark - UIScrollViewDelegate

//开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == rootScrollView) contentOffsetX = scrollView.contentOffset.x;
}

//停止减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == rootScrollView) {
        //设置为主视图滚动
        isRootScroll = YES;
        //调整顶部滑条按钮状态
        int tag = (int)scrollView.contentOffset.x / self.bounds.size.width + 100;
        UIButton *button = (UIButton *)[itemScrollView viewWithTag:tag];
        [self buttonTapped:button];
    }
}

//滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == rootScrollView) {
        //判断是左滚动还是右滚动
        if (contentOffsetX < scrollView.contentOffset.x) isLeftScroll = YES;
        else isLeftScroll = NO;
    }
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
