//
//  PFTabView.h
//  PFTabView
//
//  Created by PFei_He on 14-10-24.
//  Copyright (c) 2014年 PF-Lib. All rights reserved.
//
//  https://github.com/PFei-He/PFTabView
//
//  vesion: 0.2.1-beta1
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

#import <UIKit/UIKit.h>

/**
 *  弱引用`self`。用于解决代码块（block）与强引用self之间的循环引用问题
 *  调用方式: `@weakify_self`实现弱引用转换，而后使用`weakSelf`代替`self`
 *
 *  示例:
 *  @weakify_self
 *  [obj block:^{
 *      weakSelf.property = something;
 *  }];
 *
 */
#ifndef	weakify_self
    #if __has_feature(objc_arc)
        #define weakify_self autoreleasepool{} __weak __typeof__(self) weakSelf = self;
    #else
        #define weakify_self autoreleasepool{} __block __typeof__(self) blockSelf = self;
    #endif
#endif

@class PFTabView;

@protocol PFTabViewDelegate <NSObject>

/**
 *  @brief 设置标签总数
 *  @return 标签总数
 */
- (NSInteger)numberOfItemInTabView:(PFTabView *)tabView;

/**
 *  @brief 设置文本尺寸
 *  @return 文本尺寸
 */
- (CGSize)textSizeOfItemInTabView:(PFTabView *)tabView;

/**
 *  @brief 设置视图控制器
 *  @param index: 序号
 *  @return 视图控制器
 */
- (UIViewController *)tabView:(PFTabView *)tabView setupViewControllerAtIndex:(NSInteger)index;

@optional

/**
 *  @brief 动画效果
 *  @detail 当标签即将被选中时
 */
- (void)animationsWhenItemWillSelectInTabView:(PFTabView *)tabView;

/**
 *  @brief 重设标签按钮
 *  @param button: 按钮
 *  @param index: 序号
 */
- (UIButton *)tabView:(PFTabView *)tabView resetItemButton:(UIButton *)button atIndex:(NSInteger)index;

/**
 *  @brief 滑动到边缘
 *  @param recognizer: 滑动手势
 *  @param orientation: 滑动方向（`left`为左边缘，`right`为右边缘）
 */
- (void)tabView:(PFTabView *)tabView scrollViewDidScrollToEdgeWithRecognizer:(UIPanGestureRecognizer *)recognizer orientation:(NSString *)orientation;

/**
 *  @brief 点击标签
 *  @param index: 序号
 */
- (void)tabView:(PFTabView *)tabView didSelectItemAtIndex:(NSInteger)index;

@end

@interface PFTabView : UIView

/**
 *  @brief 初始化
 *  @param delegate: 代理（不使用代理方法时设为nil）
 */
- (id)initWithFrame:(CGRect)frame delegate:(id<PFTabViewDelegate>)delegate;

/**
 *  @brief 设置颜色（通过16进制计算）
 */
+ (UIColor *)colorFromHexRGB:(NSString *)string;

#pragma mark -

/**
 *  @brief 设置标签总数（使用块方法时必须执行该方法）
 *  @return 标签总数
 */
- (void)numberOfItemUsingBlock:(NSInteger (^)(PFTabView *tabView))block;

/**
 *  @brief 设置视图控制器（使用块方法时必须执行该方法）
 *  @param index: 序号
 *  @return 视图控制器
 */
- (void)setupViewControllerUsingBlock:(UIViewController *(^)(PFTabView *tabView, NSInteger index))block;

/**
 *  @brief 设置文本尺寸（使用块方法时必须执行该方法）
 *  @return 文本尺寸
 */
- (void)textSizeOfItemUsingBlock:(CGSize (^)(PFTabView *tabView))block;

/**
 *  @brief 动画效果
 *  @detail 当标签即将被选中时
 */
- (void)animationsWhenItemWillSelectUsingBlock:(void (^)(PFTabView *tabView))block;

/**
 *  @brief 重设标签按钮
 *  @param button: 按钮
 *  @param index: 序号
 */
- (void)resetItemButtonUsingBlock:(void (^)(PFTabView *tabView, UIButton *button, NSInteger index))block;

/**
 *  @brief 滑动到边缘
 *  @param recognizer: 滑动手势
 *  @param orientation: 滑动方向（`left`为左边缘，`right`为右边缘）
 */
- (void)scrollViewDidScrollToEdgeUsingBlock:(void (^)(PFTabView *tabView, UIPanGestureRecognizer *recognizer, NSString *orientation))block;

/**
 *  @brief 点击标签
 *  @param index: 序号
 */
- (void)didSelectItemUsingBlock:(void (^)(PFTabView *tabView, NSInteger index))block;

@end
