//
//  SplashViewController.h
//  fotografia
//
//  Created by Adam on 12/12/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MokriyaUITabBarController.h"

#import "MBProgressHUD.h"
@interface SplashViewController : UIViewController<MBProgressHUDDelegate>
@property (nonatomic, strong) MokriyaUITabBarController *customTabBarController;

@property(nonatomic, retain) MBProgressHUD *HUD;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, retain) NSDictionary *responseArray;
@property(nonatomic, retain) NSMutableArray *mutablenextarray;
@end
