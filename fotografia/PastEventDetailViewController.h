//
//  PastEventDetailViewController.h
//  fotografia
//
//  Created by Adam on 12/5/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJObjManager.h"
#import "HJManagedImageV.h"
#import "MBProgressHUD.h"

@interface PastEventDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>


@property(nonatomic, strong) NSString *event_title;
@property(nonatomic, strong) NSString *event_id;

@property(nonatomic, retain) IBOutlet UIImageView *bannerview;
@property(nonatomic, retain) IBOutlet UILabel *eventtitlelbl;
@property(nonatomic, retain) IBOutlet UITableView *pasteventvideotbl;
@property(nonatomic, retain) IBOutlet UIView *playview;
@property(nonatomic, retain) IBOutlet UIView *otherview;

@property (nonatomic,retain) HJObjManager *objmanager;
@property(nonatomic, retain) MBProgressHUD *HUD;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, retain) NSDictionary *responseArray;
@property(nonatomic, retain) NSMutableArray *mutablenextarray;

- (IBAction)backbtnclick:(id)sender;
@end
