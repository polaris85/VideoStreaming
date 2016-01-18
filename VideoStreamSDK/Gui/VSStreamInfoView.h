//
//  VSStreamInfoView.h
//  VideoStream
//
//  Created by Tarum Nadus on 08.02.2013.
//  Copyright (c) 2013 MobileTR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSStreamInfoView : UIView

//update info view with stream's related info
- (void)updateSubviewsWithInfo:(NSDictionary *)info;

@end
