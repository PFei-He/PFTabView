//
//  RootVC.m
//  Demo
//
//  Created by PFei_He on 14-11-28.
//  Copyright (c) 2014年 PF-Lib. All rights reserved.
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

#pragma mark - Views Management

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
    if (!self.tabView) self.tabView = [[PFTabView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 64) delegate:nil];

    [self.tabView numberOfItemUsingBlock:^NSInteger(PFTabView *tabView) {
        return self.viewControllers.count;
    }];
    [self.tabView setupViewControllerUsingBlock:^UIViewController *(PFTabView *tabView, NSInteger index) {
        return self.viewControllers[index];
    }];
    [self.tabView textSizeOfItemUsingBlock:^CGSize(PFTabView *tabView) {
        return CGSizeMake((self.view.frame.size.width) / 4, 30.0f);
    }];
    [self.tabView didSelectItemUsingBlock:^(PFTabView *tabView, NSInteger index) {
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
    [self.view addSubview:self.tabView];
}

- (NSArray *)viewControllers
{
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

    return @[self.home, self.news, self.hotspot, self.reply];
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
