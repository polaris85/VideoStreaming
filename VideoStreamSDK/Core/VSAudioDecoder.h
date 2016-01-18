//
//  VSAudioDecoder.h
//  VideoStream
//
//  Created by Tarum Nadus on 11/16/12.
//  Copyright (c) 2012 MobileTR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSDecoder.h"

@interface VSAudioDecoder : VSDecoder {
    BOOL _waitingForPackets;
}

/* Initialize audio decoder with AVCodecContext, AVStream, stream, and index parameters */
- (id)initWithCodecContext:(AVCodecContext*)cdcCtx
                    stream:(AVStream *)strm streamId:(NSInteger)sId;

/* Shutdown audio decoder */
- (void)shutdown;

/* end threads */
- (void)unlockQueues;

/* AV syncing */
- (double)audioClock;

/* Audio Unit */
- (void)startAU;
- (void)stopAU;

@property (nonatomic, readonly) BOOL isWaitingForPackets;

@end
