//
//  ViewController.m
//  Demo
//
//  Created by PFei_He on 16/5/9.
//  Copyright © 2016年 PFei_He. All rights reserved.
//

#import "ViewController.h"
#import "TabView.h"
#import "PFTabView.h"

@interface ViewController ()

@property (nonatomic, strong) PFTabView     *tabView;
@property (nonatomic, strong) TabView       *home;
@property (nonatomic, strong) TabView       *news;
@property (nonatomic, strong) TabView       *hotspot;
@property (nonatomic, strong) TabView       *reply;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
#else
    //取消全屏效果
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    if (!self.tabView) self.tabView = [[PFTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height)];
    
    @weakify_self
    [self.tabView numberOfItemUsingBlock:^NSInteger{
        @strongify_self
        return self.views.count;
    }];
    [self.tabView viewForItemUsingBlock:^UIView *(NSInteger index) {
        @strongify_self
        return self.views[index];
    }];
    [self.tabView sizeOfItemUsingBlock:^CGSize{
        @strongify_self
        return CGSizeMake((self.view.frame.size.width) / 2, 40.0f);
    }];
    [self.tabView didSelectItemUsingBlock:^(NSInteger index) {
        if (index == 0) {
            NSLog(@"首页");
        } else if (index == 1) {
            NSLog(@"新闻");
        } else if (index == 2) {
            NSLog(@"热点");
        } else if (index == 3) {
            NSLog(@"回复");
        }
    }];
    [self.tabView open];
    [self.view addSubview:self.tabView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)views
{
    self.home = [[TabView alloc] init];
    self.home.backgroundColor = [UIColor cyanColor];
    self.home.tabModel = 0;
    
    self.news = [[TabView alloc] init];
    self.news.backgroundColor = [UIColor magentaColor];
    self.news.tabModel = 1;
    
    self.hotspot = [[TabView alloc] init];
    self.hotspot.backgroundColor = [UIColor yellowColor];
    self.hotspot.tabModel = 2;
    
    self.reply = [[TabView alloc] init];
    self.reply.backgroundColor = [UIColor greenColor];
    self.reply.tabModel = 3;
    
    return @[self.home, self.news, self.hotspot, self.reply];
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
    return self.views[index];
}

@end
