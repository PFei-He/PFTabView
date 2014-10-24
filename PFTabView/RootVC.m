//
//  RootVC.m
//  PFTabView
//
//  Created by PFei_He on 14-10-24.
//  Copyright (c) 2014年 PFei_He. All rights reserved.
//

#import "RootVC.h"

@interface RootVC ()

@end

@implementation RootVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
#else
    //取消全屏效果
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif

    [self loadTabView];
}

- (void)loadTabView
{
    self.tabView = [[PFTabView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 64) delegate:nil];
    self.tabView.heightOfItem = 35;

    self.tabView.itemNormalColor = [UIColor blackColor];
    self.tabView.itemSelectedColor = [UIColor cyanColor];

    self.home = [[BaseVC alloc] init];
    self.home.title = @"首页";
    self.home.view.backgroundColor = [UIColor cyanColor];
    self.home.type = 0;

    self.news = [[BaseVC alloc] init];
    self.news.title = @"新闻";
    self.news.view.backgroundColor = [UIColor magentaColor];
    self.news.type = 1;

    self.hotspot = [[BaseVC alloc] init];
    self.hotspot.title = @"热点";
    self.hotspot.view.backgroundColor = [UIColor yellowColor];
    self.hotspot.type = 2;

    self.reply = [[BaseVC alloc] init];
    self.reply.title = @"评论";
    self.reply.view.backgroundColor = [UIColor greenColor];
    self.reply.type = 3;

    [self.tabView numberOfItemInTabViewUsingBlock:^NSUInteger(PFTabView *tabView) {
        return 4;
    }];
    [self.tabView viewControllerOfItemAtIndexUsingBlock:^UIViewController *(PFTabView *tabView, NSUInteger index) {
        if (index == 0) {
            return self.home;
        } else if (index == 1) {
            return self.news;
        } else if (index == 2) {
            return self.hotspot;
        } else if (index == 3) {
            return self.reply;
        } else {
            return nil;
        }
    }];
    [self.tabView textSizeOfItemInTabViewUsingBlock:^CGSize(PFTabView *tabView) {
        return CGSizeMake((self.view.frame.size.width - 40) / 4, 30.0f);
    }];
    [self.tabView didSelectItemAtIndexUsingBlock:^(PFTabView *tabView, NSUInteger index) {
        if (index == 0) {
            BaseVC *home = nil;
            home = self.home;
            NSLog(@"首页");
        } else if (index == 1) {
            BaseVC *news = nil;
            news = self.news;
            NSLog(@"新闻");
        } else if (index == 2) {
            BaseVC *hotspot = nil;
            hotspot = self.hotspot;
            NSLog(@"热点");
        } else if (index == 3) {
            BaseVC *reply = nil;
            reply = self.reply;
            NSLog(@"回复");
        }
    }];
    [self.tabView loadSubviews];
    [self.view addSubview:self.tabView];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
