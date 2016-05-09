//
//  ViewController.m
//  Demo
//
//  Created by PFei_He on 16/5/9.
//  Copyright © 2016年 PFei_He. All rights reserved.
//

#import "ViewController.h"
#import "TabController.h"
#import "PFTabView.h"

@interface ViewController ()

@property (strong, nonatomic) TabController *firstTab;
@property (strong, nonatomic) TabController *secondTab;
@property (strong, nonatomic) TabController *thirdTab;
@property (strong, nonatomic) TabController *fourthTab;

@property (nonatomic, strong) PFTabView *tabView;
@property (nonatomic, strong) TabController    *home;
@property (nonatomic, strong) TabController    *news;
@property (nonatomic, strong) TabController    *hotspot;
@property (nonatomic, strong) TabController    *reply;

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
    
    if (!self.tabView) self.tabView = [[PFTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height - 64) delegate:nil];
    
    @weakify_self
    [self.tabView numberOfItemUsingBlock:^NSInteger{
        @strongify_self
        return self.viewControllers.count;
    }];
    [self.tabView setupViewControllerUsingBlock:^UIViewController *(NSInteger index) {
        @strongify_self
        return self.viewControllers[index];
    }];
    [self.tabView textSizeOfItemUsingBlock:^CGSize{
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

- (NSArray *)viewControllers
{
    self.home = [[TabController alloc] init];
    self.home.title = @"首页";
    self.home.view.backgroundColor = [UIColor cyanColor];
    self.home.tabModel = 0;
    
    self.news = [[TabController alloc] init];
    self.news.title = @"新闻";
    self.news.view.backgroundColor = [UIColor magentaColor];
    self.news.tabModel = 1;
    
    self.hotspot = [[TabController alloc] init];
    self.hotspot.title = @"热点";
    self.hotspot.view.backgroundColor = [UIColor yellowColor];
    self.hotspot.tabModel = 2;
    
    self.reply = [[TabController alloc] init];
    self.reply.title = @"评论";
    self.reply.view.backgroundColor = [UIColor greenColor];
    self.reply.tabModel = 3;
    
    return @[self.home, self.news, self.hotspot, self.reply];
}

//- (NSArray *)viewControllers
//{
//    self.firstTab = [[TabController alloc] init];
//    self.firstTab.tabModel = 1;
//    self.secondTab = [[TabController alloc] init];
//    self.secondTab.tabModel = 2;
//    self.thirdTab = [[TabController alloc] init];
//    self.thirdTab.tabModel = 1;
//    self.fourthTab = [[TabController alloc] init];
//    self.fourthTab.tabModel = 2;
//    return @[self.firstTab, self.secondTab, self.thirdTab, self.fourthTab];
//}

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
