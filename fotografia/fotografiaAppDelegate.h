//
//  fotografiaAppDelegate.h
//  fotografia
//
//  Created by Adam on 11/24/14.
//  Copyright (c) 2014 fotografia. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface fotografiaAppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableArray *autovideoarray;
@property BOOL video_fullscreen;
@property (strong, nonatomic) NSString *banneimgrurl;
@property (strong, nonatomic) NSString *bannerlinkurl;
@end
