//
//  PFTabView.h
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

#import <UIKit/UIKit.h>

#import "PFConfigure.h"

@class PFTabView;

@protocol PFTabViewDelegate <NSObject>

/**
 *  @brief 设置标签总数
 *  @note
 *  @param
 *  @return 标签总数
 */
- (NSInteger)numberOfItemInTabView:(PFTabView *)tabView;

/**
 *  @brief 设置标签尺寸
 *  @note
 *  @param
 *  @return 标签尺寸
 */
- (CGSize)sizeOfItemInTabView:(PFTabView *)tabView;

/**
 *  @brief 设置视图控制器
 *  @note
 *  @param index: 标签的序号
 *  @return 视图控制器
 */
- (UIViewController *)tabView:(PFTabView *)tabView setupViewControllerAtIndex:(NSInteger)index;

@optional

/**
 *  @brief 动画效果
 *  @note 当标签即将被选中时
 *  @param
 *  @detail
 *  @return
 */
- (void)animationsWhenItemWillSelectInTabView:(PFTabView *)tabView;

/**
 *  @brief 重设标签按钮
 *  @note
 *  @param button: 按钮
 *  @param index: 标签的序号
 *  @return
 */
- (void)tabView:(PFTabView *)tabView resetItemButton:(UIButton *)button atIndex:(NSInteger)index;

/**
 *  @brief 滑动到边缘
 *  @note
 *  @param recognizer: 滑动手势
 *  @param orientation: 滑动方向（`left`为左边缘，`right`为右边缘）
 *  @return
 */
- (void)tabView:(PFTabView *)tabView scrollViewDidScrollToEdgeWithRecognizer:(UIPanGestureRecognizer *)recognizer orientation:(NSString *)orientation;

/**
 *  @brief 点击标签
 *  @note
 *  @param index: 标签的序号
 *  @return
 */
- (void)tabView:(PFTabView *)tabView didSelectItemAtIndex:(NSInteger)index;

/**
 *  @brief 重复点击标签
 *  @note
 *  @param index: 标签的序号
 *  @return
 */
- (void)tabView:(PFTabView *)tabView repeatSelectItemAtIndex:(NSInteger)index;

@end

@interface PFTabView : UIView

///标签下边线
@property (nonatomic, strong, readonly) UIView *bottomBorderline;
///代理
@property (weak, nonatomic) id<PFTabViewDelegate> delegate;

/**
 *  @brief 设置颜色（通过16进制计算）
 *  @note
 *  @param
 *  @return
 */
+ (UIColor *)colorFromHexRGB:(NSString *)string;

#pragma mark - Block Methods

/**
 *  @brief 设置标签总数
 *  @note
 *  @param
 *  @return 标签总数
 */
- (void)numberOfItemUsingBlock:(NSInteger (^)(void))block;

/**
 *  @brief 设置标签尺寸
 *  @note
 *  @param
 *  @return 标签尺寸
 */
- (void)sizeOfItemUsingBlock:(CGSize (^)(void))block;

/**
 *  @brief 设置视图控制器
 *  @note
 *  @param index: 标签的序号
 *  @return 视图控制器
 */
- (void)setupViewControllerUsingBlock:(UIViewController *(^)(NSInteger index))block;

/**
 *  @brief 动画效果
 *  @note 当标签即将被选中时
 *  @param
 *  @return
 */
- (void)animationsWhenItemWillSelectUsingBlock:(void (^)(void))block;

/**
 *  @brief 重设标签按钮
 *  @note
 *  @param button: 按钮
 *  @param index: 标签的序号
 *  @return
 */
- (void)resetItemButtonUsingBlock:(void (^)(UIButton *button, NSInteger index))block;

/**
 *  @brief 滑动到边缘
 *  @note
 *  @param recognizer: 滑动手势
 *  @param orientation: 滑动方向（`left`为左边缘，`right`为右边缘）
 *  @return
 */
- (void)scrollViewDidScrollToEdgeUsingBlock:(void (^)(UIPanGestureRecognizer *recognizer, NSString *orientation))block;

/**
 *  @brief 点击标签
 *  @note
 *  @param index: 标签的序号
 *  @return
 */
- (void)didSelectItemUsingBlock:(void (^)(NSInteger index))block;

/**
 *  @brief 重复点击标签
 *  @note
 *  @param index: 标签的序号
 *  @return
 */
- (void)repeatSelectItemUsingBlock:(void (^)(NSInteger index))block;

@end
