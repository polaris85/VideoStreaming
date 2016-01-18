//
//  FourthtabViewController.h
//  fotografia
//
//  Created by Adam on 11/27/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface FourthtabViewController : UIViewController<MBProgressHUDDelegate>


@property(nonatomic, retain) MBProgressHUD *HUD;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, retain) NSDictionary *responseArray;
@property(nonatomic, retain) NSMutableArray *mutablenextarray;


@property(nonatomic, retain) IBOutlet UIImageView *bannerview;
@property(nonatomic, retain) IBOutlet UIImageView *logoview;
@property(nonatomic, retain) IBOutlet UILabel *emaillbl;
@property(nonatomic, retain) IBOutlet UILabel *addresslbl;
@property(nonatomic, retain) IBOutlet UILabel *telefonelbl;
@property(nonatomic, retain) IBOutlet UILabel *mobilelbl;
@property(nonatomic, retain) IBOutlet UIView *otherview;
@end
