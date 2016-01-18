//
//  VSGLES2View.m
//  VideoStream
//
//  Created by Tarum Nadus on 30.05.2013.
//  Copyright (c) 2013 Tarum Nadus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSDecodeManager;
@class VSVideoFrame;

@interface VSGLES2View : UIView

#pragma mark - public methods

/* initialize openGL view with DecodeManager */
- (int)initGLWithDecodeManager:(VSDecodeManager *)decoder;

// enable-disable retina frames if device has retina support, default is YES
- (void)enableRetina:(BOOL)value;

/* update the openGL screen with new frame */
- (void)updateScreenWithFrame:(VSVideoFrame *)vidFrame;

/* destroy openGL view */
- (void)shutdown;

@end
