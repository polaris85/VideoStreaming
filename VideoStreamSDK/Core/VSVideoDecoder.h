//
//  VSVideoDecoder.h
//  VideoStream
//
//  Created by Tarum Nadus on 11/16/12.
//  Copyright (c) 2012 MobileTR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSDecoder.h"

@class VSAudioDecoder;

@interface VSVideoDecoder : VSDecoder

/* initialize video decoder with AVCodecContext, AVStream, stream index, and audioIsOK parameters */
- (id)initWithFormatContext:(AVFormatContext*)avFmtCtx codecContext:(AVCodecContext*)cdcCtx stream:(AVStream *)strm
                    streamId:(NSInteger)sId
                audioDecoder:(VSAudioDecoder *)audioDecoder;

/* Shutdown video decoder */
- (void)shutdown;

/* end threads */
- (void)unlockQueues;

/* AV syncing */
- (void) schedulePicture;
- (double)videoClock;

/* decoder action on state change */
- (void)onStreamPaused;

@property (nonatomic, readonly) BOOL decodeJobIsDone;
@property (nonatomic, readonly) BOOL schedulePictureJobIsDone;
@property (nonatomic, readonly) BOOL refreshPictureJobIsDone;

@end
