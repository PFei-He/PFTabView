//
//  RootVC.h
//  PFTabView
//
//  Created by PFei_He on 14-10-24.
//  Copyright (c) 2014年 PFei_He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFTabView.h"
#import "BaseVC.h"

@interface RootVC : UIViewController

@property (nonatomic, strong) PFTabView *tabView;
@property (nonatomic, strong) BaseVC    *home;
@property (nonatomic, strong) BaseVC    *news;
@property (nonatomic, strong) BaseVC    *hotspot;
@property (nonatomic, strong) BaseVC    *reply;

@end
