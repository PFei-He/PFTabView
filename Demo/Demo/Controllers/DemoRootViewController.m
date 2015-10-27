//
//  DemoRootViewController.m
//  Demo
//
//  Created by PFei_He on 15/10/27.
//  Copyright © 2015年 PFei_He. All rights reserved.
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

#import "DemoRootViewController.h"
#import "DemoTabViewController.h"
#import "PFTabView.h"

@interface DemoRootViewController () <PFTabViewDelegate>

@property (strong, nonatomic) DemoTabViewController *firstTab;
@property (strong, nonatomic) DemoTabViewController *secondTab;

@property (weak, nonatomic) IBOutlet PFTabView *tabView;

@end

@implementation DemoRootViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (NSArray *)viewControllers
{
    self.firstTab = [[DemoTabViewController alloc] init];
    self.firstTab.model = 1;
    self.secondTab = [[DemoTabViewController alloc] init];
    self.secondTab.model = 2;
    return @[self.firstTab, self.secondTab];
}

#pragma mark - PFTabViewDelegate Methods

- (NSInteger)numberOfItemInTabView:(PFTabView *)tabView
{
    return 2;
}

- (CGSize)sizeOfItemInTabView:(PFTabView *)tabView
{
    return CGSizeMake(self.view.bounds.size.width/2, 40);
}

- (UIViewController *)tabView:(PFTabView *)tabView setupViewControllerAtIndex:(NSInteger)index
{
    return self.viewControllers[index];
}

@end
