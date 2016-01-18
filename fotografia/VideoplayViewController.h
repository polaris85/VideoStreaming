//
//  VideoplayViewController.h
//  fotografia
//
//  Created by Adam on 11/28/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJObjManager.h"
#import "HJManagedImageV.h"

@interface VideoplayViewController : UIViewController

@property(nonatomic, retain) IBOutlet UIImageView *bannerview;
@property(nonatomic, retain) IBOutlet UIView *videoplayview;
@property(nonatomic, retain) IBOutlet UILabel *titlelbl;
@property(nonatomic, retain) IBOutlet HJManagedImageV *eventlogo_imageview;
@property(nonatomic, retain) IBOutlet UILabel *eventlinklbl;
@property(nonatomic, retain) IBOutlet UILabel *eventdescriptionlbl;
@property(nonatomic, retain) IBOutlet UIView *otherview;

//@property(nonatomic, strong) NSString *event_islive;
@property(nonatomic, strong) NSString *event_title;
@property(nonatomic, strong) NSString *event_videochannel;
@property(nonatomic, strong) NSString *event_logoimageurl;
@property(nonatomic, strong) NSString *event_description;
@property(nonatomic, strong) NSString *event_linkurl;

@property (nonatomic,retain) HJObjManager *objmanager;
@end
