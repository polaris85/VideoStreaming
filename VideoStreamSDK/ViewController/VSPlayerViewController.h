//
//  VSPlayerViewController.h
//  VideoStream
//
//  Created by Tarum Nadus on 11/16/12.
//  Copyright (c) 2012 MobileTR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSDecodeManager.h"

/* VSPlayer state changed notifications */
extern NSString* kVSPlayerStateChangedNotification;
extern NSString *kVSPlayerStateChangedUserInfoStateKey;
extern NSString *kVSPlayerStateChangedUserInfoErrorCodeKey;


// VSDecoder decode option keys
extern NSString *VSDECODER_OPT_KEY_RTSP_TRANSPORT;   //Defining RTSP protocol transport layer. Values are predefined under "VSDecoder decode option values"
extern NSString *VSDECODER_OPT_KEY_AUD_STRM_DEF_IDX; //Selection of audio default stream by index. Value must be an NSNumber object. (High priorty)
extern NSString *VSDECODER_OPT_KEY_AUD_STRM_DEF_STR; //Selection of audio default stream by string. Value must be an NSString object (normal priorty)
extern NSString *VSDECODER_OPT_KEY_FORCE_MJPEG; //ffmpeg can not determine some formats, so we force ffmpeg to use mjpeg format. Value must be NSNumber object with bool primitive

// VSDecoder decode option values
extern NSString *VSDECODER_OPT_VALUE_RTSP_TRANSPORT_UDP; //RTSP uses UDP transport layer - advantage fast, disadvantage packets can be lost
extern NSString *VSDECODER_OPT_VALUE_RTSP_TRANSPORT_TCP; //RTSP uses TCP transport layer, advantage no packet loss, disadvantage slow
extern NSString *VSDECODER_OPT_VALUE_RTSP_TRANSPORT_UDP_MULTICAST;
extern NSString *VSDECODER_OPT_VALUE_RTSP_TRANSPORT_HTTP; //RTSP uses http tunnelling
extern NSString *VSDECODER_OPT_VALUE_FORCE_MJPEG; //force ffmpeg to use mjpeg format

@class VSGLES2View;
@interface VSPlayerViewController : UIViewController <VSDecoderDelegate> {
    NSString *_barTitle;
    BOOL _statusBarHidden;
    VSGLES2View *_renderView;
    CGRect saverect;
}

/* init Player View Controller with url & protocol options
 For ex: rtsp protocol has transport layer options, this can be used like below 
 [NSDictionary dictionaryWithObject:@"udp" forKey:@"rtsp_transport"] for more info please see documentation */


- (id)initWithURL:(NSURL *)url decoderOptions:(NSDictionary *)options;

@property (nonatomic) CGRect *videosize;
@property (nonatomic, retain) NSString *barTitle;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL back_check_flag;
@property (nonatomic, assign) BOOL check_fullscreen;
@property (nonatomic, readonly) VSGLES2View *renderView;

- (void)close:(id)sender;
@end
