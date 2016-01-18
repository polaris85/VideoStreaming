//
//  PastEventSearchController.h
//  fotografia
//
//  Created by Adam on 12/12/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "HJObjManager.h"
#import "HJManagedImageV.h"

@interface PastEventSearchController : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>

@property(nonatomic, retain) MBProgressHUD *HUD;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, retain) NSDictionary *responseArray;
@property(nonatomic, retain) NSMutableArray *mutablenextarray;
@property(nonatomic, retain) NSString *pasteventurl;

@property (nonatomic,retain) HJObjManager *objmanager;

@property(nonatomic, retain) IBOutlet UIView *otherview;
@property(nonatomic, retain) IBOutlet UIImageView *bannerview;
@property(nonatomic, retain) IBOutlet UITableView *pasteventstbl;
@end
