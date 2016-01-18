//
//  ThirdtabViewController.h
//  fotografia
//
//  Created by Adam on 11/27/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ThirdtabViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate, UIActionSheetDelegate>
{
    BOOL start_endlbl_chooseflag;
}


@property(nonatomic,retain) UIDatePicker *datePicker;
@property(nonatomic, retain) IBOutlet UIImageView *bannerview;
@property(nonatomic, retain) IBOutlet UIView *playview;

@property(nonatomic, retain) IBOutlet UILabel *startdatelbl;
@property(nonatomic, retain) IBOutlet UILabel *enddatalbl;
@property(nonatomic, retain) IBOutlet UIView *otherview;
@end
