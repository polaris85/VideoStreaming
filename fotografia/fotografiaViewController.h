//
//  fotografiaViewController.h
//  fotografia
//
//  Created by Adam on 11/24/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
@interface fotografiaViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>

@property(nonatomic, retain) MBProgressHUD *HUD;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, retain) NSDictionary *responseArray;
@property(nonatomic, retain) NSMutableArray *mutablenextarray;
@property(nonatomic, retain) NSString *bannerurl;
@property(nonatomic, retain) NSString *autovideourl;

@property(nonatomic, retain) IBOutlet UIImageView *bannerview;
@property(nonatomic, retain) IBOutlet UIView *logoview;
@property(nonatomic, retain) IBOutlet UITableView *nexteventstbl;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *imageviewload;
@property(nonatomic, retain) IBOutlet UIView *otherview;


@end
