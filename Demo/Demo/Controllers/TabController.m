//
//  TabController.m
//  Demo
//
//  Created by PFei_He on 16/5/9.
//  Copyright © 2016年 PFei_He. All rights reserved.
//

#import "TabController.h"
#import "TabModel1.h"
#import "TabModel2.h"

@interface TabController ()

@end

@implementation TabController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.tabModel == 1) {
        TabModel1 *model = [[TabModel1 alloc] init];
        [model modelWithViewController:self];
    } else {
        TabModel2 *model = [[TabModel2 alloc] init];
        [model modelWithViewController:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
