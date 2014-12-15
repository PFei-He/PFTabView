//
//  PFTabView.h
//  PFTabView
//
//  Created by PFei_He on 14-10-24.
//  Copyright (c) 2014年 PF-Lib. All rights reserved.
//
//  https://github.com/PFei-He/PFTabView
//
//  vesion: 0.1.0
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

@class PFTabView;

@protocol PFTabViewDelegate <NSObject>

/**
 *  @brief 标签的个数
 *  @return 返回标签的个数
 */
- (NSUInteger)numberOfItemInTabView:(PFTabView *)tabView;

/**
 *  @brief 设置视图控制器
 *  @param index: 视图的序号
 *  @return 返回视图控制器
 */
- (UIViewController *)tabView:(PFTabView *)tabView viewControllerOfItemAtIndex:(NSUInteger)index;

@optional

/**
 *  @brief 调整文本尺寸
 *  @return 返回文本尺寸
 */
- (CGSize)textSizeOfItemInTabView:(PFTabView *)slideSwitchView;

/**
 *  @brief 滑动到左边缘
 *  @param recognizer: 滑动事件
 */
- (void)tabView:(PFTabView *)tabView slideToLeftEdge:(UIPanGestureRecognizer *)recognizer;

/**
 *  @brief 滑动到右边缘
 *  @param recognizer: 滑动事件
 */
- (void)tabView:(PFTabView *)tabView slideToRightEdge:(UIPanGestureRecognizer *)recognizer;

/**
 *  @brief 点击标签
 *  @param index: 点击事件的序号
 */
- (void)tabView:(PFTabView *)tabView didSelectItemAtIndex:(NSUInteger)index;

@end

@interface PFTabView : UIView

///标签的高度
@property (nonatomic, assign) CGFloat               heightOfItem;

///更多按钮
@property (nonatomic, strong) UIButton              *moreButton;

///正常时标签文字颜色
@property (nonatomic, strong) UIColor               *itemNormalColor;

///选中时标签文字颜色
@property (nonatomic, strong) UIColor               *itemSelectedColor;

///正常时标签的背景
@property (nonatomic, strong) UIImage               *itemNormalBackgroundImage;

///选中时标签的背景
@property (nonatomic, strong) UIImage               *itemSelectedBackgroundImage;

///代理
@property (nonatomic, weak) id<PFTabViewDelegate>   delegate;

/**
 *  @brief 初始化
 *  @param delegate: 代理（使用块方法时设为nil）
 */
- (id)initWithFrame:(CGRect)frame delegate:(id<PFTabViewDelegate>)delegate;

/**
 *  @brief 加载子视图
 */
- (void)loadSubviews;

/**
 *  @brief 设置颜色（通过16进制计算）
 */
+ (UIColor *)colorFromHexRGB:(NSString *)string;

/**
 *  @brief 标签的个数（使用块方法时必须执行该方法）
 *  @return 返回标签的个数
 */
- (void)numberOfItemInTabViewUsingBlock:(NSUInteger (^)(PFTabView *tabView))block;

/**
 *  @brief 设置视图控制器（使用块方法时必须执行该方法）
 *  @param index: 视图的序号
 *  @return 返回视图控制器
 */
- (void)viewControllerOfItemAtIndexUsingBlock:(UIViewController *(^)(PFTabView *tabView, NSUInteger index))block;

/**
 *  @brief 调整文本尺寸
 *  @return 返回文本尺寸
 */
- (void)textSizeOfItemInTabViewUsingBlock:(CGSize (^)(PFTabView *tabView))block;

/**
 *  @brief 滑动到左边缘
 *  @param recognizer: 滑动事件
 */
- (void)slideToLeftEdgeUsingBlock:(void (^)(PFTabView *tabView, UIPanGestureRecognizer *recognizer))block;

/**
 *  @brief 滑动到右边缘
 *  @param recognizer: 滑动事件
 */
- (void)slideToRightEdgeUsingBlock:(void (^)(PFTabView *tabView, UIPanGestureRecognizer *recognizer))block;

/**
 *  @brief 点击标签
 *  @param index: 点击事件的序号
 */
- (void)didSelectItemAtIndexUsingBlock:(void (^)(PFTabView *tabView, NSUInteger index))block;

@end
